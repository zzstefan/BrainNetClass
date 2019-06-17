function [BrainNet]=WSR(BOLD,lambda)
% FC Network Construction using Weighted Sparse Representation (WSR)
% 
% Inpute:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% lambda. parameter for sparsity
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
%       3. Renping Yu, Han Zhang, et al. Outcome prediction of weak 
%          consciousness based on weighted sparse brain network construction,
%          Unsubmited paper.
% 

%% Main code
nSubj=length(BOLD);
[TimePoint,RegionNum]=size(BOLD{1});
BrainNet=zeros(RegionNum,RegionNum,nSubj,'single');
parameter=lambda;
Total_Data=zeros(nSubj,TimePoint,RegionNum,'single');
Corr_Record=zeros(nSubj,RegionNum,RegionNum-1,'single');
for i=1:nSubj
    R=zeros(RegionNum,RegionNum-1,'single');
    tmp=BOLD{i};
    subject=tmp(:,1:RegionNum);
    [r,~]=corrcoef(subject);
    for j=1:RegionNum
        Index=1:RegionNum;
        Index(j)=[];
        R(j,:)=r(j,Index);
    end
    %% mean std (0 1)
    subject=subject-repmat(mean(subject),TimePoint,1);
    subject=subject./(repmat(std(subject),TimePoint,1));
    
    Total_Data(i,:,:)=subject;
    Corr_Record(i,1:RegionNum,1:RegionNum-1)=R;
    clear tmp;
end
opts=[];
opts.init=2;% Starting point: starting from a zero point here
opts.tFlag=0;% termination criterion
% abs( funVal(i)- funVal(i-1) ) ¡Ü .tol=10e?4 (default)
%For the tFlag parameter which has 6 different termination criterion.
% 0 ? abs( funVal(i)- funVal(i-1) ) ¡Ü .tol.
% 1 ? abs( funVal(i)- funVal(i-1) ) ¡Ü .tol ¡Á max(funVal(i),1).
% 2 ? funVal(i) ¡Ü .tol.
% 3 ? kxi ? xi?1k2 ¡Ü .tol.
% 4 ? kxi ? xi?1k2 ¡Ü .tol ¡Á max(||xi||_2, 1).
% 5 ? Run the code for .maxIter iterations.
opts.nFlag=0;% normalization option: 0-without normalization
opts.rFlag=1;% regularization % the input parameter 'rho' is a ratio in (0, 1)
opts.rsL2=0; % the squared two norm term in min  1/2 || A x - y||^2 + 1/2 rsL2 * ||x||_2^2 + z * ||x||_1
%fprintf('\n mFlag=0, lFlag=0 \n');
opts.mFlag=0;% treating it as compositive function
opts.lFlag=0;% Nemirovski's line search

for i=1:nSubj
    r=zeros(RegionNum,RegionNum-1,'single');
    r(:,:)=abs(Corr_Record(i,:,:));
    %% exp
    r_std=std(r(:));
    %r_std=0.2;
    r=exp((r.^2)/r_std);
    %% weighted sparse representation
    X=zeros(RegionNum);
    for j=1:RegionNum
        Index=1:RegionNum;
        Index(j)=[];
        Cube=zeros(TimePoint,RegionNum-1,'single');
        Region=zeros(TimePoint,1,'single');
        Cube(:,:)=Total_Data(i,:,Index);
        Region(:,1)=Total_Data(i,:,j);
        Weight=diag(r(j,:));
        [x, ~, ~]= LeastR(Cube*Weight, Region, parameter, opts);
        X(j,Index)=Weight*x;
        clear  Weight x ;
%         fprintf('Done the %d subject/%d region networks!\n',i,j);
    end
    BrainNet(:,:,i)=(X+X')/2;   % form symmetric adjancency matrix (main diag are zeros)
end

