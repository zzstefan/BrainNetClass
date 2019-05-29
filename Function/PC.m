function BrainNet=PC(BOLD)
% FC Network Construction using Pearson's Correlation of regional mean BOLD signals
% 
% Input:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
%
% Output:
% BrainNet. Functional connectivity networks (#ROIs x #ROIs x #Subjects)
% 
% By Yu Zhang 7/19/2017 zhangyu0112@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill

[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
BrainNet=zeros(nROI,nROI,nSubj,'single');
for i=1:nSubj
    temp=corr(BOLD{i});
    temp=temp-diag(diag(temp));    % remove selfconnection (set to zeros)
    BrainNet(:,:,i)=temp;
end
