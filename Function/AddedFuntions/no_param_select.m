function [AUC,SEN,SPE,F1,Acc,w,Youden,BalanceAccuracy,varargout]=no_param_select(result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label,lambda_lasso)
% This function is for classification problem that has no parameter(s) to
% optimize.  Note that this function uses the LOOCV.


% Input:
%     result_dir: the directory you want to store all the results in;
%     meth_Net: the brain network construction method;
%     meth_FEX: feature extraction method(connection coefficients or local clustering coefficients)
%     meth_FS: feature selection method (ttest,lasso,ttest+lasso);
%     BOLD: time courses extracted using a template;
%     label: the label for each subject; e.g., -1 for normal controls and 1 for patients;
%     
%     
% Output:
%     AUC,SEN,SPE,F1,Acc,Youden,BalanceAccuracy: model performance;
%     w: weight of each selected features@email.unc.edu
%     varargout: the feature selection index for the following finding features section.

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill




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
        feature_index_ttest{i}=p;
    end
    % Lasso
    if any(strcmp(meth_FS,'LASSO'))
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        feature_index_lasso{i}=midw;
    end
    
    if any(strcmp(meth_FS,'t-test + LASSO'))
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
        trFe=trFe(:,p<pval);
        teFe=teFe(:,p<pval);
        
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        feature_index_ttest{i}=p;
        feature_index_lasso{i}=midw;
    end
    
    
    % SVM classification %
    % Feature normalization
    Mtr=mean(trFe);
    Str=std(trFe);
    trFe=trFe-repmat(Mtr,size(trFe,1),1);
    tFrFe=trFe./repmat(Str,size(trFe,1),1);
    teFe=teFe-Mtr;
    teFe=teFe./Str;
    % train SVM model
    classmodel=svmtrain(trlabel,trFe,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
    w{i}=classmodel.SVs'*classmodel.sv_coef;
    % classify
    [cpred(i,1),acc,score(i,1)]=svmpredict(label(i),teFe,classmodel,'-q');
end
Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,Youden,BalanceAccuracy,~]=perfeval(label,cpred,score,result_dir);
fprintf('End calculation process\n');

switch meth_FS
    case 't-test'
        varargout{1}=feature_index_ttest;
    case 'LASSO'
        varargout{1}=feature_index_lasso;
    case 't-test + LASSO'
        varargout{1}=feature_index_ttest;
        varargout{2}=feature_index_lasso;
end
save_optimal_network(meth_Net,BrainNet,label,result_dir);


save_model(BrainNet,meth_Net,label,result_dir,meth_FEX,meth_FS,lambda_lasso);


