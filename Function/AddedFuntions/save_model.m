function []=save_model(BrainNet,meth_Net,label,result_dir,varargin)

switch meth_Net
    case {'SR','SLR','SGR','GSR','WSR','WSGR','SSGSR'}
        meth_FEX='coef';
        meth_FS='ttest + lasso';
        opt_paramt=varargin{1};
        Acc_para=varargin{2};
        lambda_lasso=varargin{3};
        [~,B]=max(Acc_para);
        opt_BrainNet=BrainNet{B};
        [nROI,~,nSubj]=size(opt_BrainNet);
        Feat=zeros(nSubj,nROI*(nROI-1)/2);  % choose FC strengths as features
        idxtu=triu(ones(nROI,nROI));
        for i=1:nSubj
            tempNet=opt_BrainNet(:,:,i);
            Feat(i,:)=tempNet(idxtu==0); % only use the upper trangle coefficients since
        end
        pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
        [~,p]=ttest2(Feat(label==-1,:),Feat(label==1,:));
        trFe=Feat(:,p<pval);
        midw=lasso(trFe,label,'Lambda',lambda_lasso);  % parameter lambda for sparsity
        trFe=trFe(:,midw~=0);
        
        result.feature_index_ttest=p;
        result.feature_index_lasso=midw;
    case 'dHOFC'
        meth_FEX='clus';
        meth_FS='lasso';
        opt_paramt=varargin{1};
         Acc_para=varargin{2};
         lambda_lasso=varargin{3};
        [~,B]=max(Acc_para);
        opt_BrainNet=BrainNet{B};
        [nCluster,~,nSubj]=size(opt_BrainNet);
        Feat=zeros(nSubj,nCluster); 
        flag=2;
        for i=1:nSubj
            Feat(i,:)=wlcc(opt_BrainNet(:,:,i),flag);
        end
        midw=lasso(Feat,label,'Lambda',lambda_lasso);
        trFe=Feat(:,midw~=0);
        
        result.feature_index_lasso=midw;
    case {'PC','tHOFC','aHOFC'}
        meth_FEX=varargin{1};
        meth_FS=varargin{2};
        lambda_lasso=varargin{3};
        opt_BrainNet=BrainNet;
        [nROI,~,nSubj]=size(opt_BrainNet);
        switch meth_FEX
            case 'coef'
                Feat=zeros(nSubj,nROI*(nROI-1)/2);
                idxtu=triu(ones(nROI,nROI),1);
                for i=1:nSubj
                    tempNet=opt_BrainNet(:,:,i);
                    Feat(i,:)=tempNet(idxtu~=0); % only use the upper trangle coefficients since
                    % brain network has been symmetric
                end
            case 'clus'
                Feat=zeros(nSubj,nROI);
                flag=2;     % flag=1, 2, or 3, see function wlcc.m for more details
                for i=1:nSubj
                    %temp=wlcc(BrainNet(:,:,i),flag);
                    Feat(i,:)=wlcc(opt_BrainNet(:,:,i),flag);   % compute weighted local clustering coefficient
                end
        end
        
        switch meth_FS
            case 't-test'
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(Feat(label==-1,:),Feat(label==1,:));
                trFe=Feat(:,p<pval);
                
                result.feature_index_ttest=p;
            case 'LASSO'
                midw=lasso(Feat,label,'Lambda',lambda_lasso);
                trFe=Feat(:,midw~=0);
                
                result.feature_index_lasso=midw;
            case 't-test + LASSO'
                pval=0.05;  % generally use pval<0.05 as a threshold for feature selection
                [~,p]=ttest2(Feat(label==-1,:),Feat(label==1,:));
                trFe=Feat(:,p<pval);
                midw=lasso(trFe,label,'Lambda',lambda_lasso);
                trFe=trFe(:,midw~=0);
                
                result.feature_index_ttest=p;
                result.feature_index_lasso=midw;
        end
end


classmodel=svmtrain(label,trFe,'-t 0 -c 1 -q'); % linear SVM (require LIBSVM toolbox)

result.model=classmodel;
result.meth_Net=meth_Net;
result.meth_FEX=meth_FEX;
result.meth_FS=meth_FS;
switch meth_Net
    case {'SR','SLR','SGR','GSR','WSR','WSGR','SSGSR','dHOFC'}
        result.opt_paramt=opt_paramt;
    case {'PC','tHOFC','aHOFC'}
end  
save (char(strcat(result_dir,'/result_model.mat')),'result');