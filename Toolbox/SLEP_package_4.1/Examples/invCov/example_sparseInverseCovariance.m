clear, clc;

% This is an example for running the function sparseInverseCovariance
% 
%   max log( det( Theta ) ) - < S, Theta> - lambda * ||Theta||_1
%
% For detailed description of the function, please refer to the Manual.
%
%% Related papers
%
% The implementation is based on the following paper:
%
% [1]  Jerome Friedman, Trevor Hastie, and Robert Tibshirani,
%      Sparse inverse covariance estimation with the graphical lasso, 2007
%
% This function has been used in the following paper:
%
% [2] Shuai Huang, Jing Li, Liang Sun, Jun Liu, Teresa Wu,
%     Kewei Chen, Adam Fleisher, Eric Reiman, and Jieping Ye,
%     Learning Brain Connectivity of Alzheimer's Disease 
%     from Neuroimaging Data, NIPS, 2009
%
%% ------------   History --------------------
%
% First version on September 18, 2008.
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/invCov;

n=100;
% problem size

% generate the data
randn('state',1);
A=randn(n,n);

mean_1=mean(A,1);
A=A-repmat(mean_1,n,1);
norm_2=sqrt( sum(A.^2,1) );
A=A./repmat(norm_2,n,1);

% S is the empirical covariance matrix
S=A'*A;

% set the maximal number of iterations
opts.maxIter=100;

lambda=0.2;

tic;
Theta=sparseInverseCovariance(S, lambda, opts);
toc;