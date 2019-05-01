function BrainNet=tHOFC(BOLD)
% Topographical similarity-based high-order FC network construction
%
% Input:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% 
% Output:
% BrainNet. High-order brain networks (#ROIs x #ROIs x #Subjects)
% 
% By Han Zhang, hanzhang@med.unc.edu
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
% 
% Cite: 1. Zhang, H., Chen, X., Shi, F., Li, G., Kim, M., Giannakopoulos, P., Haller, S., Shen, D., Jun 28, 2016. 
%          Topographic Information based High-Order Functional Connectivity and its Application in Abnormality Detection 
%          for Mild Cognitive Impairment, Journal of Alzheimer's Disease. In press. DOI: 10.3233/JAD-160092.
%       2. Zhang, H., Chen, X., Zhang, Y., Shen, D., Test-retest reliability of �high-order� functional connectivity 
%          in young healthy adults. Frontiers in Neuroscience, In Press. DOI: 10.3389/fnins.2017.00439.

[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
BrainNet=zeros(nROI,nROI,nSubj);

% Compute low-order FC network
pc=PC(BOLD);   % Pearson's correlation-based network
pc=atanh(pc);       % Fisher z transformation

% Compute topographical similarity which defines high-order FC
for ns=1:nSubj
    tempNet=zeros(nROI,nROI);
    for i=1:nROI
        for j=(i+1):nROI
            temp1=pc(:,i,ns);
            temp2=pc(:,j,ns);
            temp1([i,j])=[];                    % ignore self connections
            temp2([i,j])=[];                    % ignore self connections
            tempNet(i,j)=corr(temp1,temp2);     % only upper triangle
        end
    end
    BrainNet(:,:,ns)=tempNet+tempNet';          % form symmetric adjancency matrix (main diag are zeros)
end
