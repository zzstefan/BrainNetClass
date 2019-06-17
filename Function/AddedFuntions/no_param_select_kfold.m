function [AUC,SEN,SPE,F1,Acc,w,Youden,BalanceAccuracy,varargout]=no_param_select_kfold(k_fold,result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label,lambda_lasso)
% This function is for classification problem that has no parameter(s) to
% optimize.  Note that this function uses the 10-fold.

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
    fprintf(1,'Begin 10-fold cross-validation time %d...\n',i);
    switch meth_FS
        case 't-test'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),Youden(i),BalanceAccuracy(i),feature_index_ttest(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
        case 'LASSO'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),Youden(i),BalanceAccuracy(i),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
        case 't-test + LASSO'
            [AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),Youden(i),BalanceAccuracy(i),feature_index_ttest(i,:),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS);
    end       
end
rng('default');
AUC=mean(AUC);
SEN=mean(SEN);
SPE=mean(SPE);
F1=mean(F1);
Acc=mean(Acc);
Youden=mean(Youden);
BalanceAccuracy=mean(BalanceAccuracy);
ROC_kfold(plot_ROC,result_dir,fold_times);
fprintf('Testing set AUC: %g\n',AUC);
fprintf(1,'Testing set Sens: %3.2f%%\n',SEN);
fprintf(1,'Testing set Spec: %3.2f%%\n',SPE);
fprintf(1,'Testing set Youden: %3.2f%%\n',Youden);
fprintf(1,'Testing set F-score: %3.2f%%\n',F1);
fprintf(1,'Testing set BAC: %3.2f%%\n',BalanceAccuracy);

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

function [AUC,SEN,SPE,F1,Acc,plot_ROC,w,Youden,BalanceAccuracy,varargout]=cal_kfold_times(nSubj,kfoldout,Feat,meth_Net,label,meth_FS)
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
[AUC,SEN,SPE,F1,Youden,BalanceAccuracy,plot_ROC]=perfeval_kfold(label,cpred,score);

switch meth_FS
    case 't-test'
        varargout{1}=feature_index_ttest;
    case 'LASSO'
        varargout{1}=feature_index_lasso;
    case 't-test + LASSO'
        varargout{1}=feature_index_ttest;
        varargout{2}=feature_index_lasso;
end
