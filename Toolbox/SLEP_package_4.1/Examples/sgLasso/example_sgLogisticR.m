clear, clc;

% This is an example for running the function sgLogisticR
%
%  Problem:
%
%  min  f(x,c) = - weight_i * log (p_i) + z_1 \|x\|_1 + z_2 * sum_j w_j ||x_{G_j}||
%
%  a_i denotes a training sample,
%      and a_i' corresponds to the i-th row of the data matrix A
%
%  y_i (either 1 or -1) is the response
%     
%  p_i= 1/ (1+ exp(-y_i (x' * a_i + c) ) ) denotes the probability
%
%  weight_i denotes the weight for the i-th sample
%
%  G_j's are the non-overlapping groups
%
%    we apply L1 for each element
%    and the L2 for the non-overlapping group 
%
%  The group information is contained in
%  opts.ind, which is a 3 x nodes matrix, where nodes denotes the number of
%  nodes of the tree.
%  opts.ind(1,:) contains the starting index
%  opts.ind(2,:) contains the ending index
%  opts.ind(3,:) contains the corresponding weight (w_j)
%
%% Related papers
%
% [1] Jun Liu and Jieping Ye, Moreau-Yosida Regularization for 
%     Grouped Tree Structure Learning, NIPS 2010

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/sgLasso;

m=50;  n=100;       % The data matrix is of size m x n

% ---------------------- generate random data ----------------------
%randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

y=[-ones(25,1); ones(25,1)];      % the response

%----------------------- Set optional items -----------------------
opts=[];

% Starting point
opts.init=2;        % starting from a zero point

% Termination 
opts.tFlag=5;       % run .maxIter iterations
opts.maxIter=100;   % maximum number of iterations

% regularization
opts.rFlag=1;       % use ratio

% Normalization
opts.nFlag=0;       % without normalization

% Group Property
opts.ind=[ [1, 20, sqrt(20)]', [21, 40, sqrt(20)]',...
    [41, 50, sqrt(10)]', [51, 70, sqrt(20)]', [71,100, sqrt(30)]'];

%----------------------- Run the code -----------------------
z=[0.1,0.2];
tic;
[x, c, funVal, ValueL]= sgLogisticR(A, y, z, opts);
toc;


