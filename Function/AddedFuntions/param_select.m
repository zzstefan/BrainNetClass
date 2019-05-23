% This demo script is for classification problem that has parameter(s) to
% optimize. If more parameters to be optimized, more inner LOOCV runs
% (additional for-loop) should be used. All networks corresponding to
% different combinations of parameters should be prepared beforehand. This
% demo use network constructed by sparse representation (1 parameter to be
% optimized), feature selection uses the simplest strategy (ttest2). 
%
% The inputs are networks and labels for all subjects, the output is
% classification performance and the optimzed parameter(s).
%
% Created by Xiaobo Chen, 7/15/2017 xbchen82@gmail.com
% Modified by Han Zhang, 8/2/2017 hanzhang@med.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill

%% without sparse matrix
function [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc,w,varargout]=param_select(result_dir,meth_Net,BOLD,label,para_test_flag,varargin)
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
        %save (char(strcat(dir,meth_Net,'_net.mat')),'BrainNet','-v7.3');
        
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
                [BrainNet{i,j},IDX{i,j}]=dHOFC(BOLD,W(i),s,C(j));
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
        
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        feature_index_ttest{i}=p;
        feature_index_lasso{i}=midw;
    else
        midw=lasso(trFe,trlabel,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        teFe=teFe(:,midw~=0);
        feature_index_lasso{i}=midw;
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
[AUC,SEN,SPE,F1,~]=perfeval(label,cpred,score,result_dir);

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
    %save (char(strcat(result_dir,'/Acc_para.mat')),'Acc_para');
      switch meth_Net
            case {'SR','WSR','GSR'}
                [opt_paramt]=select_para(meth_Net,Acc_para,lambda);
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
                print(gcf,'-dtiffn',char(strcat(result_dir,'/para_sensitivity.tiff')));
                %print(gcf,'-depsc',char(strcat(result_dir,'/para_sensitivity.eps')));
             case {'SLR','SGR','WSGR','SSGSR'}
                 [opt_paramt]=select_para(meth_Net,Acc_para,lambda1,lambda2);
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
                 bar3(z');
                 zlim([0,100]);
                 xlabel(sprintf('\x3bb_1'));
                 ylabel(sprintf('\x3bb_2'));
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
                 print(gcf,'-dtiffn',char(strcat(result_dir,'/para_sensitivity.tiff')));
                 %print(gcf,'-depsc',char(strcat(result_dir,'/para_sensitivity.eps')));
             case 'dHOFC'
                 [opt_paramt]=select_para(meth_Net,Acc_para,W,C);
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
                 bar3(z');
                 zlim([0,100]);
                 xlabel(sprintf('clusters'));
                 ylabel(sprintf('windows length'));
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
                 print(gcf,'-dtiffn',char(strcat(result_dir,'/para_sensitivity.tiff')));
                 %print(gcf,'-depsc',char(strcat(result_dir,'/para_sensitivity_eps.eps')));
      end
      fprintf('End parameter sensitivity test\n');
else 
    opt_paramt=[];
end


[~,B]=max(Acc_para);
opt_BrainNet=BrainNet{B(1)};
label_negative=find(label==-1);
label_positive=find(label==1);
BrainNet_negative_mean=mean(opt_BrainNet(:,:,label_negative),3);
BrainNet_positive_mean=mean(opt_BrainNet(:,:,label_positive),3);

figure;
%figure('visible','off');
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
print(gcf,'-dtiffn',char(strcat(result_dir,'/Mean_optimal_network.tiff')));  
    

