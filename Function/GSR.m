function BrainNet=GSR(BOLD,lambda)
% FC Network Construction using Group Sparse Representation (GSR)
%
% Inpute:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% lambda. parameter for group sparsity
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
[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
opts=[];
opts.tol=10^-5;         % tolerance. 
opts.init=2;            % starting from a zero point
opts.tFlag=0;
opts.maxIter=500;       % maximum number of iterations
opts.nFlag=0;           % without normalization
opts.rFlag=1;           % 1 the input parameter 'rho' is a ratio in (0, 1)
opts.q=2;               % set the value for q
opts.ind=[0:nTime:nTime*nSubj];       % set the group indices


%% Construct FC networks using SSGSR
BrainNet=zeros(nROI,nROI,nSubj);
midNet=zeros(nROI-1,nROI,nSubj);

% Brain network modeling using SSGSR
r_std=0.2;
for nr=1:nROI
    tmpvec=[];
    tmpmat=[];
    ndic=setdiff(1:nROI,nr);
    for ns=1:nSubj
        tmpvec=[tmpvec; BOLD{ns}(:,nr)];
        tmpmat=[tmpmat; BOLD{ns}(:,ndic)];
    end
    % Estimate FC pattern at the nr-th ROI for all subjects
    [tmp,funcVal]=mtLeastR(tmpmat,tmpvec,lambda,opts);
    BrainNet(ndic,nr,:)=tmp;
end

% Symmetrization and remove link to oneself
for ns=1:nSubj
    tmp=BrainNet(:,:,ns);
    tmp=(tmp+tmp')/2;              % form symmetric adjancency matrix (main diag are zeros)
    tmp=tmp-diag(diag(tmp));       % ignore self connections
    BrainNet(:,:,ns)=tmp;
end
