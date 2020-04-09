% This funion is for generating brain networks that has no 
% parameter to optimize and then doing classification. 

% Note that this function uses the LOOCV. If user wants to use 
% 10-fold cross validation, use GUI.

% 
% Input:
%     result_dir: the directory you want to store all the results in;
%     meth_Net: the brain network construction method;
%     meth_FEX: feature extraction method
%     meth_FS: feature selection method
%     BOLD: time courses extracted;
%     label: the label for each subject; e.g., -1 for normal controls and 1 for patients;
%     
% Output:
%     AUC,SEN,SPE,F1,Acc,Youden,BalanceAccuracy: model performance;
%     w: weight of each selected features;
%     plot_ROC: used to plot the ROC curve


% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill

function [AUC,SEN,SPE,F1,Acc,cpred,score,w,plot_ROC]=no_param_select_demo(result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label,lambda_lasso)

%clc; clear; close all;

% root=cd;
% addpath(genpath([root '/Function']));
% addpath(genpath([root '/Toolbox']));


%% Load BOLD signals
% load('demo_param_select_toydata.mat');    % This is just an example data including 10 subjects only
%                         % You can replace this by your larger dataset
%                         % BOLD: A cell array, each matrix includes BOLD signals (137 volumes x 116 ROIs) of one subject 
%                         % label: class labels, 1 for MCI and -1 for NC
% BOLD = cell(size(data,1),1);
% label = zeros(size(data,1),1);
% for i=1:size(data,1)
%     BOLD{i,1} = data{i,1};
%     label(i,1) = data{i,2};
% end
                       
[~,nROI]=size(BOLD{1});
nSubj=length(BOLD);


%% Construct FC network(s): BrainNet (nROIs x nROIs x subjects)

%meth_Net='dHOFC';

% PC: Pearson's correlation
% SR: Sparse representation
% WSR: Weighted SR
% SGR: Sparse group representation
% WSGR: Weighted SGR
% GSR: Group sparse represenation
% SSGSR: Strength and similarity guided GSR
% tHOFC: Topographical high-order FC
% aHOFC: Associated high-order FC
% dHOFC: Dynamic high-order FC
fprintf('Begin network construction\n');
switch meth_Net
    case 'PC'       % Pearson's correlation
        BrainNet=PC(BOLD);
    case 'tHOFC'    % Topographical high-order FC
        BrainNet=tHOFC(BOLD);
    case 'aHOFC'    % Associated high-order FC
        BrainNet=aHOFC(BOLD);
end
fprintf('Network construction finished\n');

    
%% Feature extraction

%meth_FEX='coef';

% coef: directly use correlation coefficients in network as feautres
% clus: compute weighted local clustering coefficients as features

idxtu=triu(ones(nROI,nROI),1);
switch meth_FEX
    case 'coef'
        Feat=zeros(nSubj,nROI*(nROI-1)/2);
        for i=1:nSubj
            tempNet=BrainNet(:,:,i);
            Feat(i,:)=tempNet(idxtu~=0); % only use the upper trangle coefficients since 
                                        % brain network has been symmetric
        end
    case 'clus'
        Feat=zeros(nSubj,nROI);
        flag=2;     % flag=1, 2, or 3, see function wlcc.m for more details
        for i=1:nSubj
            %temp=wlcc(BrainNet(:,:,i),flag); 
            Feat(i,:)=wlcc(BrainNet(:,:,i),flag);   % compute weighted local clustering coefficient
        end
end


%% Feature selection and Classification

%meth_FS={'lasso'};

% ttest: two sample t-test
% Lasso: least absolute shrinkage and selection operator

% Leave-one-out cross-validation for performance evaluation
cpred=zeros(nSubj,1);
score=zeros(nSubj,1);
fprintf('Begin calculation process\n');
for i=1:nSubj
    idtr=1:nSubj;
    idtr(i)=[];
    trlabel=label(idtr);
    trFe=Feat(idtr,:);
    teFe=Feat(i,:);
    
    % Feature selection %
    % t-test
    if any(strcmp(meth_FS,'t-test'))
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
        trFe=trFe(:,p<pval);
        teFe=teFe(:,p<pval);
        ttest_p{i}=p;
    end
    % Lasso
    if any(strcmp(meth_FS,'LASSO'))
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        midw_lasso{i}=midw;
    end
    
    if any(strcmp(meth_FS,'t-test + LASSO'))
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
        trFe=trFe(:,p<pval);
        teFe=teFe(:,p<pval);
        
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        ttest_p{i}=p;
        midw_lasso{i}=midw;       
    end
    
    
    % SVM classification %
    % Feature normalization
    Mtr=mean(trFe);
    Str=std(trFe);
    trFe=trFe-repmat(Mtr,size(trFe,1),1);
    trFe=trFe./repmat(Str,size(trFe,1),1);
    teFe=teFe-Mtr;
    teFe=teFe./Str;
    % train SVM model
    classmodel=svmtrain(trlabel,trFe,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
    % classify
    w{i}=classmodel.SVs'*classmodel.sv_coef;
    [cpred(i,1),acc,score(i,1)]=svmpredict(label(i),teFe,classmodel,'-q');
end
Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,Youden,BalanceAccuracy,plot_ROC]=perfeval(label,cpred,score,result_dir);
fprintf('End calculation process\n');


k_times=10; %%it is not used.

switch meth_FS
    case 'LASSO'
        [result_features]=back_find_low_node_Nopara(result_dir,nSubj,k_times,nROI,w,'loocv',meth_FEX,meth_FS,midw_lasso);
    case 't-test'
        [result_features]=back_find_low_node_Nopara(result_dir,nSubj,k_times,nROI,w,'loocv',meth_FEX,meth_FS,ttest_p);
    case 't-test + LASSO'
        [result_features]=back_find_low_node_Nopara(result_dir,nSubj,k_times,nROI,w,'loocv',meth_FEX,meth_FS,ttest_p,midw_lasso);
end
write_log(result_dir,meth_Net,'loocv',AUC,SEN,SPE,F1,Acc,Youden,BalanceAccuracy,meth_FEX,meth_FS,k_times,lambda_lasso);
save (char(strcat(result_dir,'/result_features.mat')),'result_features');    
