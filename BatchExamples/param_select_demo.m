% This demo is for classification problem that has parameter(s) to
% optimize. If more parameters to be optimized, more inner LOOCV runs
% (additional for-loop) should be used. All networks corresponding to
% different combinations of parameters should be prepared beforehand. Note
% that this function uses the LOOCV.

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
%     w: weight of each selected features;
%     varargout: the feature selection index for the following finding features section.

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill

%% without sparse matrix
function [opt_paramt,AUC,SEN,SPE,F1,Acc,opt_t,ttest_p,midw_lasso,w,plot_ROC]=param_select_demo(result_dir,meth_Net,BOLD,label,para_test_flag,varargin)
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

% Construct FC networks under different parameters
% mkdir ./Generated_BrainNet_test
% dir=['./Generated_BrainNet_test/'];

fprintf('Begin network construction\n');
switch meth_Net
    case 'SR'       % Sparse representation
        lambda=lambda_1; % parameter for sparsity
        parfor i=1:length(lambda)
            BrainNet{i}=SR(BOLD,lambda(i));
        end
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
    case 'WSR'      % PC weighted SR
        lambda=lambda_1; % parameter for sparsity
        parfor i=1:length(lambda)
            BrainNet{i}=WSR(BOLD,lambda(i));
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
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        save (char(strcat(result_dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'WSGR'     % PC weighted SGR
        lambda1=lambda_1; % parameter for sparsity
        lambda2=lambda_2; % parameter for group sparsity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=WSGR(BOLD,lambda1(i),lambda2(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'GSR'      % Group sparse representation
        lambda=lambda_1;
        parfor i=1:length(lambda)
            BrainNet{i}=GSR(BOLD,lambda(i));
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
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
    case 'dHOFC'    % Dynamic high-order FC
        num_C=length(C);
        num_W=length(W);
        parfor i=1:num_W % number of clusters
            for j=1:num_C
                BrainNet{i,j}=dHOFC(BOLD,W(i),s,C(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_W*num_C);
        nROI=C;
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
end
fprintf('Network construction finished\n');


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
    

e = 1:nSubj;
indx = floor(nSubj*[1:10]/10);
cpred = zeros(nSubj,1);
acc = zeros(nSubj,1);
score = zeros(nSubj,1);

% LOOCV for testing
for i=1:nSubj
    ind = find(indx == i);
    if ~isempty(ind)
        fprintf(1,'Begin process %d%%...\n',ind*10);
    end
    
    Tst_ind = i;
    telabel = label(i);
    Trn_ind = e;
    Trn_ind(i) = [];
    trlabel = label;
    trlabel(i) = [];
    
    % Nested LOOCV on Train data for Model selection
    max_acc = 0;
    for t = 1:length(All_Feat)
        % Feature generation
        Feat = All_Feat{t};
        tmpTestCorr = zeros(length(trlabel),1);
        for j =1:length(trlabel)
            % LOOCV on Training Set
            Tst1_ind = Trn_ind(j);
            telabel1 = trlabel(j);
            Trn1_ind = Trn_ind;
            Trn1_ind(j) = [];
            trlabel1 = trlabel;
            trlabel1(j) = [];

            
            trFe = Feat(Trn1_ind,:);
            teFe = Feat(Tst1_ind,:);
            
            % Feature selection using t-test
            if ~strcmpi(meth_Net,'dHOFC')
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(trFe(trlabel1==-1,:),trFe(trlabel1==1,:));
                trFe=trFe(:,p<pval);
                teFe=teFe(:,p<pval);
                
                midw=lasso(trFe,trlabel1,'Lambda',lambda_lasso);  % parameter lambda for sparsity
                trFe=trFe(:,midw~=0);
                teFe=teFe(:,midw~=0);
            else
                midw=lasso(trFe,trlabel1,'Lambda',lambda_lasso);  % parameter lambda for sparsity
                trFe=trFe(:,midw~=0);
                teFe=teFe(:,midw~=0);
            end
            
            % Feature normalization
            Mtr=mean(trFe);
            Str=std(trFe);
            trFe=trFe-repmat(Mtr,size(trFe,1),1);
            trFe=trFe./repmat(Str,size(trFe,1),1);
            teFe=teFe-Mtr;
            teFe=teFe./Str;
            
            % train SVM model
            classmodel=svmtrain(trlabel1,trFe,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
            % classify
            [~,acc,~]=svmpredict(telabel1,teFe,classmodel,'-q');
            tmpTestCorr(j,1) = acc(1);
        end
        mTestCorr(t) = sum(tmpTestCorr)/length(tmpTestCorr);
        if mTestCorr(t)>max_acc
            max_acc = mTestCorr(t);
            opt_t(i) = t;
        end
    end
    % Feature generation
    Feat = All_Feat{opt_t(i)};
    trFe = Feat(Trn_ind,:);
    teFe = Feat(Tst_ind,:);
    
    % Feature selection ag
    if ~strcmpi(meth_Net,'dHOFC')
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [~,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
        trFe=trFe(:,p<pval);
        teFe=teFe(:,p<pval);
        ttest_p{i}=p;
        
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        midw_lasso{i}=midw;
    else
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        midw_lasso{i}=midw;
              ttest_p{i}=midw;

    end
    
    % Feature normalization ag
    Mtr=mean(trFe);
    Str=std(trFe);
    trFe=trFe-repmat(Mtr,size(trFe,1),1);
    trFe=trFe./repmat(Str,size(trFe,1),1);
    teFe=teFe-Mtr;
    teFe=teFe./Str;
    
    % train SVM model ag
    classmodel=svmtrain(trlabel,trFe,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)
    % classify ag
    w{i}=classmodel.SVs'*classmodel.sv_coef;
    [cpred(i),~,score(i)]=svmpredict(telabel,teFe,classmodel,'-q');
end

Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,plot_ROC]=perfeval(label,cpred,score,result_dir);



if para_test_flag==1
    fprintf('Begin parameter sensitivity test\n');
    for i=1:length(All_Feat)
        Acc_para(i)=parameter_sensitivity_test_loocv(All_Feat{i},nSubj,label,meth_Net,lambda_lasso);
    end
    save (char(strcat(result_dir,'/Acc_para.mat')),'Acc_para');
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
                %print(gcf,'-depsc',char(strcat(result_dir,'/para_sensitivity.eps')));
             case {'SLR','SGR','WSGR','SSGSR'}
                 [opt_paramt]=select_para(meth_Net,Acc_para,lambda1,lambda2);
                 save_model(BrainNet,meth_Net,label,result_dir,opt_paramt,Acc_para,lambda_lasso);
                 x=lambda2;
                 y=lambda1;
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
                 %print(gcf,'-depsc',char(strcat(result_dir,'/para_sensitivity.eps')));
             case 'dHOFC'
                 [opt_paramt]=select_para(meth_Net,Acc_para,W,C);
                 save_model(BrainNet,meth_Net,label,result_dir,opt_paramt,Acc_para,lambda_lasso);
                 x=C;
                 y=W;
                 for i=1:length(x)
                    x_label{i}=num2str(x(i));
                 end
                 for j=1:length(y)
                    y_label{j}=num2str(y(j));
                 end
                 z=reshape(Acc_para,length(W),length(C));
                 figure('visible','off');
                 Bar1=bar3(z);
                 for Element = 1:length(Bar1)
                    ZData = get(Bar1(Element),'ZData');
                    set(Bar1(Element), 'CData', ZData,...
                        'FaceColor', 'interp');
                 end
                 colorbar
                 zlim([0,100]);
                 xlabel(sprintf('Number of Clusters'));
                 ylabel(sprintf('Window Length'));
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
end
    

