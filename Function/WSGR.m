function [BrainNet]=WSGR(BOLD,lambda1,lambda2)
% FC Network Construction using Weighted Sparse Group Representation (WSGR)
% 
% Inpute:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% lambda1. parameter for sparsity
% lambda2. parameter for group sparsity
%
% Output:
% BrainNet. FC network (#ROIs x #ROIs x #Subjects)
%
% Requires SLEP toolbox: http://www.yelab.net/software/SLEP/
%
% By Renping Yu, yurenping91@163.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
%
% Cite: 1. Renping Yu, Han Zhang, et al. Correlation-Weighted Sparse Group 
%          Representation for Brain Network Construction in MCI Classification,
%          MICCAI 2016.
%       2. Renping Yu, Han Zhang, et al. Connectivity strength©\weighted sparse
%          group representation©\based brain network construction for MCI 
%          classification, Human Brain Mapping, 2017.
% 

%% basic setting, load data, basic statistics
nSubj=length(BOLD);
[TimePoint,RegionNum]=size(BOLD{1});
BrainNet=zeros(RegionNum,RegionNum,nSubj);
NodeNum=(RegionNum-1)*RegionNum;
Bins=100;
opts=[];
% Starting point
opts.init=2;        % starting from a zero point
% Termination
opts.tFlag=0;       % termination criterion
    % abs( funVal(i)- funVal(i-1) ) ? .tol=10e?4 (default)
    %For the tFlag parameter which has 6 different termination criterion.
    % 0 ? abs( funVal(i)- funVal(i-1) ) ? .tol.
    % 1 ? abs( funVal(i)- funVal(i-1) ) ? .tol ?? max(funVal(i),1).
    % 2 ? funVal(i) ? .tol.
    % 3 ? kxi ? xi?1k2 ? .tol.
    % 4 ? kxi ? xi?1k2 ? .tol ?? max(||xi||_2, 1).
    % 5 ? Run the code for .maxIter iterations.
%opts.maxIter=10000;   % maximum number of iterations
% regularization
opts.rFlag=1;       % regularization % the input parameter 'rho' is a ratio in (0, 1)
% Normalization
opts.nFlag=0;       % without normalization
for SubjectID=1:nSubj
    %tic;
    Dictionary=zeros(TimePoint*RegionNum,(RegionNum-1)*RegionNum);
    GroupSize=zeros(Bins,1);
    GroupWeight=zeros(Bins,1);
    ind=zeros(3,NodeNum+Bins);
    ind(1,1:NodeNum)=1:NodeNum;
    ind(2,1:NodeNum)=1:NodeNum;
    %% Correlation
    Total_Data=zeros(TimePoint,RegionNum);
    Group=zeros((RegionNum-1)*RegionNum,3);
    R=zeros(RegionNum-1,RegionNum);
    TIndex=zeros(RegionNum-1,RegionNum);
    tmp=BOLD{SubjectID};
    subject=tmp(:,1:RegionNum);
    [r,~]=corrcoef(subject);
    for j=1:RegionNum
        Index=1:RegionNum;
        Index(j)=[];
        TIndex(:,j)=Index;
        R(:,j)=r(Index,j);
    end
    %% Weight
    %R_std=std(R(:));
    %R_std=sqrt(sum(R(:).^2)/length(R(:)));
    R_std=0.2;
    WeightR=exp(-(R.^2)/R_std);
    %% mean std (0 1)
    subject=subject-repmat(mean(subject),TimePoint,1);
    subject=subject./(repmat(std(subject),TimePoint,1));
    Total_Data(:,:)=subject;
    clear tmp;
    %% Group
    Max=max(abs(R(:)));
    Min=min(abs(R(:)));
    step=(Max-Min)/Bins;
    Value=Min:step:Max;
    Value(1)=0;Value(end)=1;
    tmpNum=0;
    for k=2:Bins+1
        gk=k-1;
        index=find(abs(R)>Value(k-1)&abs(R)<=Value(k));
        kmean=mean(abs(R(index)));
        GroupWeight(gk,1)=exp(-(kmean.^2)/R_std);
        [krow,kcol]=find(abs(R)>Value(k-1)&abs(R)<=Value(k));
        oldindex=find(abs(R)>Value(k-1)&abs(R)<=Value(k));
        GroupSize(gk)=length(krow);
        NewIndex=(tmpNum+1):1:(tmpNum+length(krow));
        Group(NewIndex,1:3)=[krow,kcol,oldindex];
        for l=1:GroupSize(gk)
            j=kcol(l);
            ij=krow(l);
            newIndex=NewIndex(l);
            Dictionary((j-1)*TimePoint+1:j*TimePoint,newIndex)=subject(:,TIndex(ij,j));
            ind(3,newIndex)=WeightR(ij,j);
        end
        ind(1,gk+NodeNum)=tmpNum+1;
        tmpNum=tmpNum+length(krow);
        ind(2,gk+NodeNum)=tmpNum;
    end
    clear  subject
    Response=Total_Data(:);
    % Group Property
    ind(3,1+NodeNum:Bins+NodeNum)=GroupWeight(1:Bins);%last Bins is Group Weighted;
    EmptyGroup=find(GroupSize==0);
    ind(:,NodeNum+EmptyGroup)=[];
    opts.ind=ind;
    %% Network learning based on group sparse lasso
    Ration=lambda1/lambda2;
    opts.ind(3,1:NodeNum)=Ration*ind(3,1:NodeNum);
    brainnet=zeros(RegionNum-1,RegionNum);
    Brainnet=zeros(RegionNum,RegionNum);
    %tic;
    A=sparse(Dictionary);
    [x, funVal, ValueL]= tree_LeastR(A, Response, lambda2, opts);
    %toc;
    for kk=1:length(x)
        brainnet(Group(kk,1),Group(kk,2))=x(kk);
    end
    for j=1:RegionNum
        Index=1:RegionNum;
        Index(j)=[];
        Brainnet(Index,j)=brainnet(:,j);
    end
    opts.ind=[];
    clear ind;
    BrainNet(:,:,SubjectID)=(Brainnet+Brainnet')/2;     % form symmetric adjancency matrix (main diag are zeros)
end