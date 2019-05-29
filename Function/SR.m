function BrainNet=SR(BOLD,lambda)
% FC Network Construction using Sparse Representation (SR)
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
% By Yu Zhang, zhangyu0112@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill


%% Initialize parameters for SLEP toolbox
opts=[];
opts.init=2;    % starting point: starting from a zero point here
opts.tFlag=0;   % termination criterion
opts.nFlag=0;   % normalization option: 0-without normalization
opts.rFlag=1;   % regularization % the input parameter 'rho' is a ratio in (0, 1)
opts.rsL2=0;    % the squared two norm term in min  1/2 || A x - y||^2 + 1/2 rsL2 * ||x||_2^2 + z * ||x||_1
opts.mFlag=0;   % treating it as compositive function
opts.lFlag=0;   % Nemirovski's line search


%% Construct FC networks using sparse representation
[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
BrainNet=zeros(nROI,nROI,nSubj,'single');
for i=1:nSubj
    temp=BOLD{i};
    temp=temp-repmat(mean(temp,2),1,nROI);     % centralization
    tempNet=zeros(nROI,nROI);
    for j=1:nROI
        ndic=setdiff(1:nROI,j);
        y=temp(:,j);
        A=temp(:,ndic);
        x=LeastR(A,y,lambda,opts);
        tempNet(ndic,j)=x;
    end
    tempNet=(tempNet+tempNet')/2;              % form symmetric adjancency matrix (main diag are zeros)
    tempNet=tempNet-diag(diag(tempNet));       % ignore self connections
    BrainNet(:,:,i)=tempNet;
end
