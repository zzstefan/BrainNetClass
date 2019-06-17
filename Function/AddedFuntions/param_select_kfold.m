% This function is for classification problem that has parameter(s) to
% optimize. If more parameters to be optimized, more inner LOOCV runs
% (additional for-loop) should be used. All networks corresponding to
% different combinations of parameters should be prepared beforehand. Note
% that this function uses the 10-fold repeated by several times.

% 
% Input:
%     result_dir: the directory you want to store all the results in;
%     meth_Net: the brain network construction method;
%     BOLD: time courses extracted using a template;
%     label: the label for each subject; e.g., -1 for normal controls and 1 for patients;
%     para_test_flag: whether or not to perform parameter sensitivity test.
%     varargin: the different parameters for different brain network construction method;
%     
% Output:
%     opt_paramt: the best parameter combination in the parameter sensitivity test;
%     opt_t: the selected parameter combination in each parameter optimization fold;
%     AUC,SEN,SPE,F1,Acc,Youden,BalanceAccuracy: model performance;
%     w: weight of each selected features@email.unc.edu
%     varargout: the feature selection index for the following finding features section.

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill


function [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc,w,Youden,BalanceAccuracy,varargout]=param_select_kfold(k_fold,result_dir,meth_Net,BOLD,label,para_test_flag,varargin)
switch meth_Net
    case {'SR','WSR','GSR'}
        lambda_1=varargin{1};
        lambda_lasso=varargin{2};
    case {'SLR','SGR','WSGR','SSGSR'}
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lambda_lasso=varargin{3};
    case 'dHOFC'
        W=varargin{1};
        s=varargin{2};
        C=varargin{3};
        lambda_lasso=varargin{4};
end
%clear; close all;
%meth_Net='WSR'
root=pwd;
addpath(genpath([root '/Function']));
addpath(genpath([root '/Toolbox']));


%% Load BOLD signals
%load('demo_param_select_toydata.mat');    % This is just an example data including 10 subjects only
%load('demo_framwk_toydata.mat');
% You can replace this by your own dataset
% BOLD: A cell array, each matrix includes BOLD signals (137 volumes x 116 ROIs) of one subject
% label: class labels, 1 for patient and -1 for healthy controls


[~,nROI]=size(BOLD{1});
nSubj=length(BOLD);

fprintf('Begin network construction\n');
switch meth_Net
    case 'SR'       % Sparse representation
        lambda=lambda_1; % parameter for sparsity
        parfor i=1:length(lambda)
            BrainNet{i}=SR(BOLD,lambda(i));
            disp('.');
        end
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
    case 'WSR'      % PC weighted SR
        lambda=lambda_1; % parameter for sparsity
        parfor i=1:length(lambda)
            BrainNet{i}=WSR(BOLD,lambda(i));
            disp('.');
        end
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');

    case 'SLR'      % Sparse low-rank representation
        lambda1=lambda_1;
        lambda2=lambda_2;
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SLR(BOLD,lambda1(i),lambda2(j));
                disp('.');
            end 
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'SGR'      % Sparse group representation
        lambda1=lambda_1; % parameter for sparsity
        lambda2=lambda_2; % parameter for group sparsity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SGR(BOLD,lambda1(i),lambda2(j));
                disp('.');
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'WSGR'     % PC weighted SGR
        lambda1=lambda_1; % parameter for sparsity
        lambda2=lambda_2; % parameter for group sparsity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=WSGR(BOLD,lambda1(i),lambda2(j));
                disp('.');
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'GSR'      % Group sparse representation
        lambda=lambda_1;
        parfor i=1:length(lambda)
            BrainNet{i}=GSR(BOLD,lambda(i));
            disp('.');
        end
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'SSGSR'    % Strength and Similarity guided GSR
        lambda1=lambda_1; % parameter for group sparsity
        lambda2=lambda_2; % parameter for inter-subject LOFC-pattern similarity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SSGSR(BOLD,lambda1(i),lambda2(j));
                disp('.');
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'dHOFC'    % Dynamic high-order FC
        num_C=length(C);
        num_W=length(W);
        parfor i=1:num_W % number of clusters
            for j=1:num_C
                [BrainNet{i,j},IDX{i,j}]=dHOFC(BOLD,W(i),s,C(j));
                disp('.');
            end
        end
        BrainNet=reshape(BrainNet,1,num_W*num_C);
        nROI=C;
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
end
fprintf('Network construction finished\n');

% lambda=[0.001 0.005 0.01 0.02];
% for i=1:length(lambda) % parameter for sparsity constraint
%     BrainNet{i}=SR(BOLD,lambda(i));
% end
% Note, usually, multiple networks with different parameters will be
% established beforehand so that the results can be stored and called
% during parameter selection to save computational time

% Extract features from FC networks under different parameters
if ~strcmpi(meth_Net,'dHOFC')
    idxtu=triu(ones(nROI,nROI));
    for i=1:length(BrainNet)
        Feat=zeros(nSubj,nROI*(nROI-1)/2);  % choose FC strengths as features
        for j=1:nSubj
            tempNet=BrainNet{i}(:,:,j);
            %tempA=tempNet(idxtu~=0);
            Feat(j,:)=tempNet(idxtu==0); % only use the upper trangle coefficients since
            % brain network has been symmetric
        end
        All_Feat{i} = Feat;
    end
    
else
    %idxtu=triu(ones(nROI,nROI),1);
    for i=1:length(BrainNet)
        temp=ceil(i/length(W));
        Feat=zeros(nSubj,nROI(temp)); 
        flag=2;
        for j=1:nSubj
            Feat(j,:)=wlcc(BrainNet{i}(:,:,j),flag);
        end
        All_Feat{i} = Feat;
    end
end

fold_times=k_fold;
kfoldout=10;

%e = 1:nSubj;
%indx = floor(nSubj*[1:10]/10);


rng('shuffle');
for i=1:fold_times
    fprintf(1,'Begin 10-fold cross-validation time %d...\n',i);
    switch meth_Net
        case {'SR','WSR','GSR','SLR','SGR','WSGR','SSGSR'}
            [opt_t(i,:),AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),Youden(i),BalanceAccuracy(i),feature_index_ttest(i,:),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,All_Feat,meth_Net,label,lambda_lasso);
        case 'dHOFC'
            [opt_t(i,:),AUC(i),SEN(i),SPE(i),F1(i),Acc(i),plot_ROC{i},w(i,:),Youden(i),BalanceAccuracy(i),feature_index_lasso(i,:)]=cal_kfold_times(nSubj,kfoldout,All_Feat,meth_Net,label,lambda_lasso);
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

fprintf('Testing set AUC: %g\n',AUC);
fprintf(1,'Testing set Sens: %3.2f%%\n',SEN);
fprintf(1,'Testing set Spec: %3.2f%%\n',SPE);
fprintf(1,'Testing set Youden: %3.2f%%\n',Youden);
fprintf(1,'Testing set F-score: %3.2f%%\n',F1);
fprintf(1,'Testing set BAC: %3.2f%%\n',BalanceAccuracy);
ROC_kfold(plot_ROC,result_dir,fold_times);


switch meth_Net
    case {'SR','WSR','GSR','SLR','SGR','WSGR','SSGSR'}
        varargout{1}=feature_index_ttest;
        varargout{2}=feature_index_lasso;
    case {'dHOFC'}
        varargout{1}=feature_index_lasso;
        varargout{2}=IDX;
end


if para_test_flag==1
    fprintf('Begin parameter sensitivity test\n');
    for i=1:length(All_Feat)
        Acc_para(i)=parameter_sensitivity_test_loocv(All_Feat{i},nSubj,label,meth_Net,lambda_lasso);
    end
    %save ./result/Acc_para.mat Acc_para;
      switch meth_Net
            case {'SR','WSR','GSR'}
                [opt_paramt]=select_para(meth_Net,Acc_para,lambda);
                save_model(BrainNet,meth_Net,label,result_dir,opt_paramt,Acc_para,lambda_lasso);
                x=lambda;
                for j=1:length(x)
                    x_label{j}=num2str(x(j));
                end
                ind=1:length(x);
                y=Acc_para;
                figure('visible','off');
                bar(ind,y);
                ylim([0,100]);
                set(gca,'XTickLabel',x_label);
                xlabel(sprintf('\x3bb_1'));
                ylabel('Accuracy');
                title('Parameter sensitivity test');
                print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/para_sensitivity.tiff')));
             case {'SLR','SGR','WSGR','SSGSR'}
                 [opt_paramt]=select_para(meth_Net,Acc_para,lambda1,lambda2);
                 save_model(BrainNet,meth_Net,label,result_dir,opt_paramt,Acc_para,lambda_lasso);
                 x=lambda1;
                 y=lambda2;
                 for i=1:length(x)
                    x_label{i}=num2str(x(i));
                 end
                 for j=1:length(y)
                    y_label{j}=num2str(y(j));
                 end
                 z=reshape(Acc_para,num_lambda1,num_lambda2);
                 figure('visible','off');
                 Bar1=bar3(z);
                 for Element = 1:length(Bar1)
                    ZData = get(Bar1(Element),'ZData');
                    set(Bar1(Element), 'CData', ZData,...
                        'FaceColor', 'interp');
                 end
                 colorbar
                 zlim([0,100]);
                 xlabel(sprintf('\x3bb_2'));
                 ylabel(sprintf('\x3bb_1'));
                 zlabel(sprintf('Accuracy'));
                 if length(x)>=8
                     ind_x=1:2:length(x);
                     set(gca,'XTick',ind_x,'XTickLabel',x_label(1:2:end));
                 else
                     ind_x=1:length(x);
                     set(gca,'XTick',ind_x,'XTickLabel',x_label);
                 end
                 if length(y)>=8
                     ind_y=1:2:length(y);
                     set(gca,'YTick',ind_y,'YTickLabel',y_label(1:2:end));
                 else
                     ind_y=1:length(y);
                     set(gca,'YTick',ind_y,'YTickLabel',y_label);
                 end
                 title('Parameter sensitivity test');
                 print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/para_sensitivity.tiff')));
             case 'dHOFC'
                 [opt_paramt]=select_para(meth_Net,Acc_para,W,C);
                 save_model(BrainNet,meth_Net,label,result_dir,opt_paramt,Acc_para,lambda_lasso);
                 x=W;
                 y=C;
                 for i=1:length(x)
                    x_label{i}=num2str(x(i));
                 end
                 for j=1:length(y)
                    y_label{j}=num2str(y(j));
                 end
                 z=reshape(Acc_para,length(W),length(C));
                 figure('visible','off');
                 Bar1=bar3(z');
                 for Element = 1:length(Bar1)
                     ZData = get(Bar1(Element),'ZData');
                     set(Bar1(Element), 'CData', ZData,...
                         'FaceColor', 'interp');
                 end
                 colorbar
                 zlim([0,100]);
                 xlabel(sprintf('Window Length'));
                 ylabel(sprintf('Number of Clusters'));
                 zlabel(sprintf('Accuracy'));
                 if length(x)>=8
                     ind_x=1:2:length(x);
                     set(gca,'XTick',ind_x,'XTickLabel',x_label(1:2:end));
                 else
                     ind_x=1:length(x);
                     set(gca,'XTick',ind_x,'XTickLabel',x_label);
                 end
                 if length(y)>=8
                     ind_y=1:2:length(y);
                     set(gca,'YTick',ind_y,'YTickLabel',y_label(1:2:end));
                 else
                     ind_y=1:length(y);
                     set(gca,'YTick',ind_y,'YTickLabel',y_label);
                 end
                 title('Parameter sensitivity test');
                 print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/para_sensitivity.tiff')));
      end
      fprintf('End parameter sensitivity test\n');
      save_optimal_network(meth_Net,BrainNet,label,result_dir,Acc_para);
      
else
    opt_paramt=[];
    return;
end




function [opt_t,AUC,SEN,SPE,F1,Acc,plot_ROC,w,Youden,BalanceAccuracy,varargout]=cal_kfold_times(nSubj,kfoldout,All_Feat,meth_Net,label,lambda_lasso)
cpred = zeros(nSubj,1);
acc = zeros(nSubj,1);
score = zeros(nSubj,1);
Test_res=zeros(1,kfoldout);
c_out = cvpartition(nSubj,'k', kfoldout);
kfoldin=kfoldout-1;
% LOOCV for testing
for fdout=1:c_out.NumTestSets
    
    %fprintf(1,'Begin process %d%%...\n',fdout*10);
    % Nested LOOCV on Train data for Model selection
    max_acc = 0;
    for t = 1:length(All_Feat)
        % Feature generation
        Feat = All_Feat{t};
        
        Train_data=Feat(training(c_out,fdout),:);
        Train_lab=label(training(c_out,fdout));
        %         Test_data=Feat(test(c_out,fdout),:);
        %         Test_lab=label(test(c_out,fdout));
        tmpTestCorr = zeros(length(Train_lab),1);
        c_in=cvpartition(length(Train_lab),'k',kfoldin);
        for fdin=1:c_in.NumTestSets
            
            InTrain_data=Train_data(training(c_in,fdin),:);
            InTrain_lab=Train_lab(training(c_in,fdin));
            Vali_data=Train_data(test(c_in,fdin),:);
            Vali_lab=Train_lab(test(c_in,fdin));
            
            % Feature selection using t-test
            if ~strcmpi(meth_Net,'dHOFC')
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(InTrain_data(InTrain_lab==-1,:),InTrain_data(InTrain_lab==1,:));
                InTrain_data=InTrain_data(:,p<pval);
                Vali_data=Vali_data(:,p<pval);
                
                midw=lasso(InTrain_data,InTrain_lab,'Lambda',lambda_lasso);  % parameter lambda for sparsity
                InTrain_data=InTrain_data(:,midw~=0);
                Vali_data=Vali_data(:,midw~=0);
            else
                midw=lasso(InTrain_data,InTrain_lab,'Lambda',lambda_lasso);  % parameter lambda for sparsity
                InTrain_data=InTrain_data(:,midw~=0);
                Vali_data=Vali_data(:,midw~=0);
            end
            
            % Feature normalization
            Mtr=mean(InTrain_data);
            Str=std(InTrain_data);
            InTrain_data=InTrain_data-repmat(Mtr,size(InTrain_data,1),1);
            InTrain_data=InTrain_data./repmat(Str,size(InTrain_data,1),1);
            Vali_data=Vali_data-repmat(Mtr,size(Vali_data,1),1);
            Vali_data=Vali_data./repmat(Str,size(Vali_data,1),1);
            
            % train SVM model
            classmodel=svmtrain(InTrain_lab,InTrain_data,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
            % classify
            [~,acc,~]=svmpredict(Vali_lab,Vali_data,classmodel,'-q');
            tmpTestCorr(fdin,1) = acc(1);
        end
        mTestCorr = sum(tmpTestCorr)/length(tmpTestCorr);
        if mTestCorr>max_acc
            max_acc = mTestCorr;
            opt_t(fdout) = t;
        end
    end
    % Feature generation
    Feat = All_Feat{opt_t(fdout)};
    Train_data = Feat(training(c_out,fdout),:);
    Train_lab = label(training(c_out,fdout));
    Test_data=Feat(test(c_out,fdout),:);
    Test_lab=label(test(c_out,fdout));
    
    % Feature selection ag
    if ~strcmpi(meth_Net,'dHOFC')
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [h,p]=ttest2(Train_data(Train_lab==-1,:),Train_data(Train_lab==1,:));
        Train_data=Train_data(:,p<pval);
        Test_data=Test_data(:,p<pval);
        
        midw=lasso(Train_data,Train_lab,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        Train_data=Train_data(:,midw~=0);
        Test_data=Test_data(:,midw~=0);
        feature_index_ttest{fdout}=p;
        feature_index_lasso{fdout}=midw;
    else
        midw=lasso(Train_data,Train_lab,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        Train_data=Train_data(:,midw~=0);
        Test_data=Test_data(:,midw~=0);
        feature_index_lasso{fdout}=midw;
    end
    % Feature normalization ag
    Mtr=mean(Train_data);
    Str=std(Train_data);
    Train_data=Train_data-repmat(Mtr,size(Train_data,1),1);
    Train_data=Train_data./repmat(Str,size(Train_data,1),1);
    Test_data=Test_data-repmat(Mtr,size(Test_data,1),1);
    Test_data=Test_data./repmat(Str,size(Test_data,1),1);
    
    % train SVM model ag
    classmodel=svmtrain(Train_lab,Train_data,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
    % classify ag
    %[A,V,C]=svmpredict(telabel,teFe,classmodel,'-q');
    w{fdout}=classmodel.SVs'*classmodel.sv_coef;
    [cpred(test(c_out,fdout)),~,score(test(c_out,fdout))]=svmpredict(Test_lab,Test_data,classmodel,'-q');
end

Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,Youden,BalanceAccuracy,plot_ROC]=perfeval_kfold(label,cpred,score);
switch meth_Net
    case {'SR','WSR','GSR','SLR','SGR','WSGR','SSGSR'}
        varargout{1}=feature_index_ttest;
        varargout{2}=feature_index_lasso;
    case {'dHOFC'}
        varargout{1}=feature_index_lasso;
end

    