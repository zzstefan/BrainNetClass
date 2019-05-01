function BrainNet=SSGSR(BOLD,lambda1,lambda2)
% FC Network Strength- and Similarity-uided Group Sparse Representation (SSGSR)
% 
% Inpute:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% lambda1. parameter for group sparsity
% lambda2. parameter for inter-subject LOFC-pattern similarity
% 
% Output:
% BrainNet. FC network (#ROIs x #ROIs x #Subjects)
%
% Requires SLEP toolbox: http://www.yelab.net/software/SLEP/
%
% By Yu Zhang, zhangyu0112@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
%
% Cite: Y. Zhang, et al. Strength and similarity guided group-level
%        brain functional network construction for MCI diagnosis. Submitted, 2017.
% 


%% Initialize parameters for SLEP toolbox
[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);

midata=cell(1,nSubj);
pc=zeros(nROI,nROI,nSubj);
for i=1:nSubj
    temp1=BOLD{i};
    temp1=temp1-repmat(mean(temp1,2),1,nROI);   % normalization
    midata{i}=temp1;
    temp2=corr(temp1);                          % compute Pearson's correlation (PC)
    temp2=temp2-diag(diag(temp2));              % remove link to oneself
    pc(:,:,i)=temp2;
end
BOLD=midata;
clear midata temp1 temp2

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

% Compute Pearson's correlation (PC) network


% Brain network modeling using SSGSR
r_std=1;
for nr=1:nROI
    tmpvec=[];
    tmpmat=[];
    ndic=setdiff(1:nROI,nr);
    for ns=1:nSubj
        pcef=exp(-pc(ndic,nr,ns).^2/r_std);       % PC strength
        tmpvec=[tmpvec; BOLD{ns}(:,nr)];
        tmpmat=[tmpmat; BOLD{ns}(:,ndic)./repmat(pcef',nTime,1)];
    end
    
    % Compute graph Laplacian for inter-subject similarity
    C=squeeze(pc(ndic,nr,:));
    L=computeLap(C');
    
    % Estimate FC pattern at the nr-th ROI for all subjects
    [tmp,funcVal]=mtLeastR_SSGSR(tmpmat,tmpvec,L,lambda1,lambda2,opts);
    tmp=tmp./repmat(pcef,1,nSubj);
    BrainNet(ndic,nr,:)=tmp;
end

% Symmetrization and remove link to oneself
for ns=1:nSubj
    tmp=BrainNet(:,:,ns);
    tmp=(tmp+tmp')/2;              % form symmetric adjancency matrix (main diag are zeros)
    tmp=tmp-diag(diag(tmp));       % ignore self connections
    BrainNet(:,:,ns)=tmp;
end
