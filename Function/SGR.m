function BrainNet=SGR(BOLD,lambda1,lambda2)
% lambda1=0.01;
% lambda2=0.02

% FC Network Construction using Sparse Group Representation (SGR)
% 
% Input:
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
BrainNet=zeros(RegionNum,RegionNum,nSubj,'single');
Bins=100;
opts=[];
% Starting point
opts.init=2;        % starting from a zero point
% Termination
opts.tFlag=0;       % termination criterion
    % abs( funVal(i)- funVal(i-1) ) ? .tol=10e?4 (default)
    %For the tFlag parameter which has 6 different termination criterion.
    % 0 ? abs( funVal(i)- funVal(i-1) ) ? .tol.
    % 1 ? abs( funVal(i)- funVal(i-1) ) ? .tol ?max(funVal(i),1).
    % 2 ? funVal(i) ? .tol.
    % 3 ? kxi ? xi?1k2 ? .tol.
    % 4 ? kxi ? xi?1k2 ? .tol ?max(||xi||_2, 1).
    % 5 ? Run the code for .maxIter iterations.
%opts.maxIter=10000;   % maximum number of iterations
% regularization
opts.rFlag=1;       % regularization % the input parameter 'rho' is a ratio in (0, 1)
% Normalization
opts.nFlag=0;       % without normalization
for SubjectID=1:nSubj
    Dictionary=zeros(TimePoint*RegionNum,(RegionNum-1)*RegionNum);
    GroupSize=zeros(Bins,1);
    GroupWeight=zeros(Bins,1);
    ind=zeros(3,Bins);
    %% Correlation
    Total_Data=zeros(TimePoint,RegionNum);
    Group=zeros((RegionNum-1)*RegionNum,2,'single');
    R=zeros(RegionNum-1,RegionNum,'single');
    TIndex=zeros(RegionNum-1,RegionNum,'single');
    tmp=BOLD{SubjectID};
    subject=tmp(:,1:RegionNum);
    [r,~]=corrcoef(subject);
    for j=1:RegionNum
        Index=single(1:RegionNum);
        Index(j)=[];
        TIndex(:,j)=Index;
        R(:,j)=r(Index,j);
    end
    %% mean std (0 1)
    subject=subject-repmat(mean(subject),TimePoint,1);
    subject=subject./(repmat(std(subject),TimePoint,1));
    Total_Data(:,:)=subject;
    clear tmp;
    %% Group
    Max=max(abs(R(:)));
    Min=min(abs(R(:)));
    %Std=std(abs(R(:)));
    Std=0.2;
    step=(Max-Min)/Bins;
    Value=Min:step:Max;
    Value(1)=0;Value(end)=1;
    tmpNum=0;
    for k=2:Bins+1
        gk=k-1;
        index=find(abs(R)>Value(k-1)&abs(R)<=Value(k));
        kmean=mean(abs(R(index)));
        GroupWeight(gk,1)=exp(-kmean.^2/Std);
        [krow,kcol]=find(abs(R)>Value(k-1)&abs(R)<=Value(k));
        GroupSize(gk,1)=length(krow);
        NewIndex=(tmpNum+1):1:(tmpNum+length(krow));
        Group(NewIndex,1:2)=[krow,kcol];
        for l=1:GroupSize(gk,1)
            j=kcol(l);
            ij=krow(l);
            newIndex=NewIndex(l);
            Dictionary((j-1)*TimePoint+1:j*TimePoint,newIndex)=subject(:,TIndex(ij,j));
        end
        ind(1,gk)=tmpNum+1;
        tmpNum=tmpNum+length(krow);
        ind(2,gk)=tmpNum;
    end
    clear  subject
    Response=Total_Data(:);
    % Group Property
%     ind(1,1:Bins)=[1,(GroupSize(1:Bins-1,1)'+1)];
%     ind(2,1:Bins)=GroupSize(1:Bins,1);
    ind(3,1:Bins)=GroupWeight(1:Bins);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!group-wise weight 
    EmptyGroup=find(GroupSize==0);
    ind(:,EmptyGroup)=[];
    opts.ind=ind;
    %% Network learning based on group sparse lasso
    z=[lambda1,lambda2];
    A=sparse(Dictionary);
    clear Dictionary;
    brainnet=zeros(RegionNum-1,RegionNum,'single');
    Brainnet=zeros(RegionNum,RegionNum,'single');
    
    [x, ~, ~]= sgLeastR(A, Response, z, opts);
    
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
