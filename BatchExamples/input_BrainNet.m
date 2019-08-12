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
% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill

clear all
load ./Generated_BrainNet/tHOFC.mat; % All user self prepared networks should be prepared as a cell araay, each element's size is  nROI*nROI*nSubj 
load ./FED_NC_matched_label.mat; % nSubj*1 matrix
output_dir='./result/'; %this is the output directory;
meth_FEX='coef'; %you can choose 'coef' or 'clus';
meth_FS='ttest'; %you can choose 'ttest','lasso','ttest + lasso'; If lasso or ttest+lasso, user may need to define the lasso parameter, as the line below:
%lambda_lasso=0.05:0.01:0.1;  % In case lasso feature selection is used




nROI=size(BrainNet{1},1);
nSubj=length(label);


switch meth_FEX
    case 'coef'
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
    case 'clus'
        for i=1:length(BrainNet)
            Feat=zeros(nSubj,nROI);
            flag=2;     % flag=1, 2, or 3, see function wlcc.m for more details
            for j=1:nSubj
                %temp=wlcc(BrainNet(:,:,i),flag);
                Feat(j,:)=wlcc(BrainNet{i}(:,:,j),flag);   % compute weighted local clustering coefficient
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




if strcmpi(meth_FS,'ttest')
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
                
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(trFe(trlabel1==-1,:),trFe(trlabel1==1,:));
                trFe=trFe(:,p<pval);
                teFe=teFe(:,p<pval);
                
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
                tmpTestCorr(j)=acc(1);
            end
            mTestCorr(t,:) = sum(tmpTestCorr)/length(tmpTestCorr);
            if mTestCorr(t)>max_acc
                max_acc = mTestCorr(t);
                opt_t(i) = t;
            end
        end
        Feat = All_Feat{opt_t(i)};
        trFe = Feat(Trn_ind,:);
        teFe = Feat(Tst_ind,:);
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [~,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
        trFe=trFe(:,p<pval);
        teFe=teFe(:,p<pval);
        feature_index_ttest{i}=p;

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
else
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
                
                
                for k=1:length(lambda_lasso)
                    trFe = Feat(Trn1_ind,:);
                    teFe = Feat(Tst1_ind,:);
                    
                    switch meth_FS
                        case 'lasso'
                            midw=lasso(trFe,trlabel1,'Lambda',lambda_lasso(k));  % parameter lambda for sparsity
                            trFe=trFe(:,midw~=0);
                            teFe=teFe(:,midw~=0);
                        case 'ttest + lasso'
                            pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                            [~,p]=ttest2(trFe(trlabel1==-1,:),trFe(trlabel1==1,:));
                            trFe=trFe(:,p<pval);
                            teFe=teFe(:,p<pval);
                            
                            midw=lasso(trFe,trlabel1,'Lambda',lambda_lasso(k));  % parameter lambda for sparsity
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
                    tmpTestCorr(k,j)=acc(1);
                    
                end %% every lambda has been transversed
                %tmpTestCorr(j,1) = acc(1);
            end%%every subject has been tranversed in inner LOOCV
            mTestCorr(t,:) = (sum(tmpTestCorr,2)/size(tmpTestCorr,2))';
            
        end%%every brain network has been transversed
        new_ind=find(mTestCorr==max(mTestCorr(:)));
        [x,y]=ind2sub([t k],new_ind);
        F_lambda(i,1)=x(1);
        F_lambda(i,2)=y(1);
        % Feature generation
        Feat = All_Feat{x(1)};
        trFe = Feat(Trn_ind,:);
        teFe = Feat(Tst_ind,:);
        
        % Feature selection ag
        switch meth_FS
            case 'lasso'
                midw=lasso(trFe,trlabel,'Lambda',lambda_lasso(y(1)));  % parameter lambda for sparsity
                trFe=trFe(:,midw~=0);
                teFe=teFe(:,midw~=0);
                feature_index_lasso{i}=midw;
            case 'ttest + lasso'
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(trFe(trlabel==-1,:),trFe(trlabel==1,:));
                trFe=trFe(:,p<pval);
                teFe=teFe(:,p<pval);
                
                midw=lasso(trFe,trlabel,'Lambda',lambda_lasso(y(1)));  % parameter lambda for sparsity
                trFe=trFe(:,midw~=0);
                teFe=teFe(:,midw~=0);
                feature_index_ttest{i}=p;
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
end
Acc=100*sum(cpred==label)/nSubj;
[AUC,SEN,SPE,F1,plot_ROC]=perfeval(label,cpred,score,output_dir);




