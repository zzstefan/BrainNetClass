function BrainNet=SLR(BOLD,lambda1,lambda2)
% FC Network Construction using Sparse Low-rank Representation (SLR)
%
% Inpute:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% lambda1. parameter for low-rank
% lambda2. parameter for sparsity
% 
% Output:
% BrainNet. High-order brain networks (#ROIs x #ROIs x #Subjects)
%
% Requires SLEP toolbox: http://www.yelab.net/software/SLEP/
%
% By Yu Zhang, zhangyu0112@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
%
% Cite: L. Qiao, et al. Estimating functional brain networks by incorporating a modularity prior. 
%       NeuroImage, 2016, 141: 399-407.
%


%% Initialize parameters for SLEP toolbox
opts=[];
opts.epsilon = 10^-5;
opts.max_itr = 1000;
opts.z=lambda2;


%% Construct FC networks using sparse low-rank representation
[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
BrainNet=zeros(nROI,nROI,nSubj);
for i=1:nSubj
    temp=BOLD{i};
    temp=temp-repmat(mean(temp,2),1,nROI);     % centralization
    [tempNet,fval_vec]=accel_grad_mlr_qiao(temp,temp,lambda1,opts);
    tempNet=(tempNet+tempNet')/2;              % form symmetric adjancency matrix (main diag are zeros)
    tempNet=tempNet-diag(diag(tempNet));       % ignore self connections
    BrainNet(:,:,i)=tempNet;
end
