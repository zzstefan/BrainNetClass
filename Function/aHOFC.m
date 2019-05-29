function BrainNet=aHOFC(BOLD)
% Associated High-order FC Network Construction
%
% Input:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
%
% Output:
% BrainNet. High-order brain networks (#ROIs x #ROIs x #Subjects)
% 
% By Yu Zhang 7/31/2017 zhangyu0112@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
%
% Cite: 1.	Zhang, Y., Zhang, H., Chen, X., Lee, S.-W., Shen, D. Hybrid High-order Functional Connectivity 
%           Networks Using Resting-state Functional MRI for Mild Cognitive Impairment Diagnosis�, 
%           Scientific Reports, 2017. In Press. DOI:10.1038/s41598-017-06509-0
%       2.  Zhang, H., Chen, X., Zhang, Y., Shen, D., Test-retest reliability of �high-order� functional connectivity 
%           in young healthy adults. Frontiers in Neuroscience, In Press. DOI: 10.3389/fnins.2017.00439.

[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);
BrainNet=zeros(nROI,nROI,nSubj,'single');

% Compute low-order FC network (i.e., Pearson's correlation-based network)
pc=PC(BOLD);   % Pearson's correlation-based network
pc=atanh(pc);       % Fisher z transformation

% Construct associated high-order FC network
for ns=1:nSubj
    tempNet1=zeros(nROI,nROI);
    tempNet2=zeros(nROI,nROI);
    
    % First, compute topographical high-order FC network
    for i=1:nROI
        for j=(i+1):nROI
            temp1=pc(:,i,ns);
            temp2=pc(:,j,ns);
            temp1([i,j])=[];
            temp2([i,j])=[];
            tempNet1(i,j)=corr(temp1,temp2);     % only upper triangle
        end
    end
    tempNet1=tempNet1+tempNet1';
    tempNet1=atanh(tempNet1);
    
    % Then, compute associated high-order FC network
    for i=1:nROI
        for j=1:nROI
            temp1=pc(:,i,ns);
            temp2=tempNet1(:,j);
            temp1([i,j])=[];
            temp2([i,j])=[];
            tempNet2(i,j)=corr(temp1,temp2);
        end
    end
    BrainNet(:,:,ns)=(tempNet2+tempNet2')/2;    % make aHOFC matrix symmetric
                                                % note: aHOFC is
                                                % theoretically asymmetry,
                                                % i.e., aHOFC(i,j) could be
                                                % different from
                                                % aHOFC(j,i). However, to
                                                % make result more
                                                % interpretable, we make it
                                                % symmetric.
end
