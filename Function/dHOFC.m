function [BrainNet,IDX] = dHOFC(BOLD,W,s,numCluster)
% Dynamics-based High-Order FC Network Construction.
%
% Input:
% BOLD. A cell array with size of N x 1, each cell is a matrix of BOLD signals (#time points x #ROIs) from one of N subject
%       Each subject may have different #time points but should have the same #ROIs
% Parameters:
% W: sliding window length, number
% s: sliding window step size, number
% numCluster: number of clusters, number (the clusters are treated as new
%             node in high-order networks, the parameter can be learned based on LOOCV.
% 
% Output:
% BrainNet. High-order brain networks (#numCluster x #numCluster x #Subjects)
% 
% By Xiaobo Chen xbchen82@gmail.com
% IDEA lab https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, UNC Chapel Hill
% Cite: 1.	Chen, X., Zhang, H., Gao, Y., Wee, C.-Y., Li, G., Shen, D., the Alzheimer’s Disease Neuroimaging Initiative, 
%           2017. High-order resting-state functional connectivity network for MCI classification. Human Brain Mapping. DOI:10.1002/hbm.23240.
%       2.  Chen, X., Zhang, H., Shen, D., Ensemble Hierarchical High-Order Functional Connectivity Networks for MCI Classification”, 
%           MICCAI 2016, Athens, Greece, Oct. 17–21, 2016.
%       3. 	Chen, X., Zhang, H., Shen, D. 2017. Hierarchical High-Order Functional Connectivity Networks and Selective Feature 
%           Fusion for MCI Classification. Neuroinformatics, 15(3):271-284.
%       4.  Zhang, H., Chen, X., Zhang, Y., Shen, D., Test-retest reliability of “high-order” functional connectivity 
%           in young healthy adults. Frontiers in Neuroscience, In Press. DOI: 10.3389/fnins.2017.00439.

[nTime,nROI]=size(BOLD{1});
nSubj=length(BOLD);

k = 0;pp = [];
for i=1:nROI
    for j=1:nROI
        k = k+1;
        if i>=j
            pp = [pp;k];
        end
    end
end

K = floor((nTime-W)/s)+1;                % K: number of sliding window
r = zeros(nROI,nROI,K);
All_dFC = [];
for i = 1:nSubj
    D = BOLD{i};
    for j = 1:K
        idx1 = (j-1)*s+1;
        idx2 = (j-1)*s+W;
        r(:,:,j) = corr(D(idx1:idx2,:)); % BOLD signal sub-series correlation
    end
    A = permute(r,[3 2 1]);
    B=squeeze(reshape(A,[],K, nROI*nROI));
    B(:,pp) = [];
    All_dFC = [All_dFC;B];
end

Dist = pdist(All_dFC');
Y1 = linkage(Dist,'ward');

IDX = cluster(Y1,'maxclust',numCluster); % clustering based on dynamic FC

Tmp11 = zeros(size(All_dFC,1),numCluster);
for j = 1:numCluster
    Tmp11(:,j) = mean(All_dFC(:,find(IDX == j)),2);   % calculate mean dynamic FC of each cluster
end

BrainNet = zeros(numCluster,numCluster,nSubj);
for i = 1:nSubj
    BrainNet(:,:,i) = corr(Tmp11(1+K*(i-1):K*i,:));   % calculate HOFC matrix
end
