% This is a demo including the whole framework of brain network-based
% classification, including network construction (different algorithms to
% choose), feature extraction (connectivity strength or graph theoretical 
% analysis-based local clustering coefficient), feature selection (ttest2 
% or lasso) and classification (LOOCV-based performance evaluation). 
% This demo does not include any model parameter optimization, if you have 
% parameter to be optimized, please refer to another demo "demo_param_select.m".
%
% Created by Yu Zhang, 7/26/2017 zhangyu0112@gmail.com
% Modified by Han Zhang, 8/2/2017 hanzhang@med.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill

function [AUC,SEN,SPE,F1,Acc,w,varargout]=demo_framwk_kfold(k_fold,result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label)
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

% 10-fold cross-validation for performance evaluation
fold_times=k_fold;
kfoldout=10;
fprintf('Begin calculation process\n');
rng('shuffle');
for i=1:fold_times
    switch meth_FS
        case 't-test'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),feature_index_ttest(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
        case 'LASSO'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
        case 't-test + LASSO'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),feature_index_ttest(i,:),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
    end       
end
rng('default');
AUC=mean(AUC);
SEN=mean(SEN);
SPE=mean(SPE);
F1=mean(F1);
Acc=mean(Acc);
ROC_kfold(plot_ROC,result_dir,fold_times);
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

opt_BrainNet=BrainNet;
label_negative=find(label==-1);
label_positive=find(label==1);
BrainNet_negative_mean=mean(opt_BrainNet(:,:,label_negative),3);
BrainNet_positive_mean=mean(opt_BrainNet(:,:,label_positive),3);

%figure;
figure('visible','off');
subplot(1,2,1);
imagesc(BrainNet_positive_mean);
colormap jet
colorbar
axis square
xlabel('ROI');
ylabel('ROI');
title('label = -1');

subplot(1,2,2);
imagesc(BrainNet_negative_mean);
colormap jet
colorbar
axis square
xlabel('ROI');
ylabel('ROI');
title('label = 1');
print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/Mean_optimal_network.tiff')));  
save (char(strcat(result_dir,'/Mean_optimal_negativeLabel_network_.mat')),'BrainNet_negative_mean');
save (char(strcat(result_dir,'/Mean_optimal_positiveLabel_network_.mat')),'BrainNet_positive_mean');    


function [AUC,SEN,SPE,F1,Acc,plot_ROC,w,varargout]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS)
c_out = cvpartition(nSubj,'k', kfoldout);
cpred=zeros(nSubj,1);
score=zeros(nSubj,1);

for fdout=1:c_out.NumTestSets
    Train_data=Feat(training(c_out,fdout),:);
    Train_lab=label(training(c_out,fdout));
    Test_data=Feat(test(c_out,fdout),:);
    Test_lab=label(test(c_out,fdout));
    % Feature selection %
    % t-test
    if any(strcmp(meth_FS,'t-test'))
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(Train_data(Train_lab==-1,:),Train_data(Train_lab==1,:));
        Train_data=Train_data(:,p<pval);
        Test_data=Test_data(:,p<pval);
        feature_index_ttest{fdout}=p;
    end
    % Lasso
    if any(strcmp(meth_FS,'LASSO'))
        midw=lasso(Train_data,Train_lab,'Lambda',0.1);  % parameter lambda for sparsity
        Train_data=Train_data(:,midw~=0);
        Test_data=Test_data(:,midw~=0);
        feature_index_lasso{fdout}=midw;
    end
    
    if any(strcmp(meth_FS,'t-test + LASSO'))
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(Train_data(Train_lab==-1,:),Train_data(Train_lab==1,:));
        Train_data=Train_data(:,p<pval);
        Test_data=Test_data(:,p<pval);
        
        midw=lasso(Train_data,Train_lab,'Lambda',0.1);  % parameter lambda for sparsity
        Train_data=Train_data(:,midw~=0);
        Test_data=Test_data(:,midw~=0);
        
        feature_index_ttest{fdout}=p;
        feature_index_lasso{fdout}=midw;
    end
    
    
    % SVM classification %
    % Feature normalization
    Mtr=mean(Train_data);
    Str=std(Train_data);
    Train_data=Train_data-repmat(Mtr,size(Train_data,1),1);
    Train_data=Train_data./repmat(Str,size(Train_data,1),1);
    Test_data=Test_data-repmat(Mtr,size(Test_data,1),1);
    Test_data=Test_data./repmat(Str,size(Test_data,1),1);
    % train SVM model
    classmodel=svmtrain(Train_lab,Train_data,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
    w{fdout}=classmodel.SVs'*classmodel.sv_coef;
    % classify
    [cpred(test(c_out,fdout)),~,score(test(c_out,fdout))]=svmpredict(Test_lab,Test_data,classmodel,'-q');
end
Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,plot_ROC]=perfeval_kfold(label,cpred,score);

switch meth_FS
    case 't-test'
        varargout{1}=feature_index_ttest;
    case 'LASSO'
        varargout{1}=feature_index_lasso;
    case 't-test + LASSO'
        varargout{1}=feature_index_ttest;
        varargout{2}=feature_index_lasso;
end
