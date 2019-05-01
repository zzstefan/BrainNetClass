clear, clc;

% This is an example for running the function overlapping
%
%  Problem:
%
%  min  1/2 || x - v||^2 + z_1 \|x\|_1 + z_2 * sum_i w_i ||x_{G_i}||
%
%  G_i's are nodes 
%
%    we have L1 for each element
%    and the L2 for the overlapping group 
%
%  The overlapping group information is contained in
% 
%   opts.G- a row vector containing the indices of all the overlapping
%           groups G_1, G_2, ..., G_groupNum
%    
%   opts.w- a 3 x groupNum matrix
%           opts.w(1,i): the starting index of G_i in opts.G
%           opts.w(2,i): the ending index of G_i in opts.G
%           opts.w(3,i): the weight for the i-th group
%
% For better illustration, we consider the following example of four groups:
%   G_1={1,2,3}, G_2={2,4}, G_3={3,5}, G_4={1,5}.
% Let us assume the weight for each group is 123.
% 
%   opts.G=[1,2,3,2,4,3,5,1,5];
%   opts.w=[ [1, 3, 123]', [4,5,123]',[6,7,123]',[8,9,123]' ];
%
%% Related papers
%
% [1]  Jun Liu and Jieping Ye, Fast Overlapping Group Lasso, 
%      arXiv:1009.0306v1, 2010
%
%% ------------   History --------------------
%
% First version on April 21, 2010.
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)


cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/overlapping;

p=100; % number of samples
g=10; % number of groups

v=randn(p,1);

lambda1=0.6;
lambda2=1.1;
Y=zeros(200,1);
maxIter=2000;
tol=1e-12;


%% ---- Example 1
%% 

G=[1:20, 11:30, 21:40, 31:50, 41:60, 51:70, 61:80, 71:90, 81:100, 91:100, 1:10]-1;
W=[ [1 20 1]', [21 40 1]', [41 60 1]', [61 80 1]', [81 100 1]',...
    [101 120 1]', [121 140 1]', [141 160 1]', [161 180 1]', [181 200 1]' ];
W(1:2,:)=W(1:2,:)-1;


Y=zeros(200,1);
tic;
[x,gap, infor]=overlapping(v,  p, g, lambda1, lambda2,...
    W, G, Y, maxIter, 2, tol);
toc;
