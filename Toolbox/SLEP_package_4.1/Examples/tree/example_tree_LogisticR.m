clear, clc;

% This is an example for running the function tree_LogisticR
%
%  Problem:
%
%  min  f(x,c) = - sum_i weight_i * log (p_i) + z * sum_j w_j ||x_{G_j}||
%
%  a_i denotes a training sample,
%      and a_i' corresponds to the i-th row of the data matrix A
%
%  y_i (either 1 or -1) is the response
%     
%  p_i= 1/ (1+ exp(-y_i (x' * a_i + c) ) ) denotes the probability
%
%  G_j's are nodes with tree structure
%
%  The tree structured group information is contained in
%  opts.ind, which is a 3 x nodes matrix, where nodes denotes the number of
%  nodes of the tree.
%
%  opts.ind(1,:) contains the starting index
%  opts.ind(2,:) contains the ending index
%  opts.ind(3,:) contains the corresponding weight (w_j)
%
%  Note: 
%  1) If each element of x is a leaf node of the tree and the weight for
%  this leaf node are the same, we provide an alternative "efficient" input
%  for this kind of node, by creating a "super node" with 
%  opts.ind(1,1)=-1; opts.ind(2,1)=-1; and opts.ind(3,1)=the common weight.
%
%  2) If the features are well ordered in that, the features of the left
%  tree is always less than those of the right tree, opts.ind(1,:) and
%  opts.ind(2,:) contain the "real" starting and ending indices. That is to
%  say, x( opts.ind(1,j):opts.ind(2,j) ) denotes x_{G_j}. In this case,
%  the entries in opts.ind(1:2,:) are within 1 and n.
%
%
%  If the features are not well ordered, please use the input opts.G for
%  specifying the index so that  
%   x( opts.G ( opts.ind(1,j):opts.ind(2,j) ) ) denotes x_{G_j}.
%  In this case, the entries of opts.G are within 1 and n, and the entries of
%  opts.ind(1:2,:) are within 1 and length(opts.G).
%
%% Related papers
%
% [1] Jun Liu and Jieping Ye, Moreau-Yosida Regularization for 
%     Grouped Tree Structure Learning, NIPS 2010
%
%%


cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/tree;

m=50;  n=100;       % The data matrix is of size m x n

% ---------------------- generate random data ----------------------
%randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

y=[-ones(25,1); ones(25,1)];      % the response


%% In this example, the tree is set as:
%
% root, 1:100, with weight 0
% its children nodes, 1:50, and 51:100
%
% For 1:50, its children are 1:20, 21:40, and 41:50
%
% For 51:100, its children are 51:70, and 71:100
%
% These nodes in addition have each individual features (they contain) as
% children nodes.
%
%%

%% One efficient way
% We make use of the fact that the indices of the left nodes of the tree
% are smaller than the right nodes.

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
opts.ind=[[-1, -1, 1]',... % leave nodes (each node contains one feature)
    [1, 20, sqrt(20)]', [21, 40, sqrt(20)]',... % the layer above the leaf
    [41, 50, sqrt(10)]', [51, 70, sqrt(20)]', [71,100, sqrt(30)]',...
    [1, 50, sqrt(50)]', [51, 100, sqrt(50)]']; % the higher layer

%----------------------- Run the code mc_cgLassoLeast -----------------------
z=0.1;
tic;
[x, c, funVal, ValueL]= tree_LogisticR(A, y, z, opts);
toc;

%% An alternative way
% We make use of the fact that the indices of the left nodes of the tree
% are smaller than the right nodes.
%%

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
opts.ind=[[-1, -1, 1]',... % leave nodes (each node contains one feature)
    [1, 20, sqrt(20)]', [21, 40, sqrt(20)]',... % the layer above the leaf
    [41, 50, sqrt(10)]', [51, 70, sqrt(20)]', [71,100, sqrt(30)]',...
    [101, 150, sqrt(50)]', [151, 200, sqrt(50)]']; % the higher layer
opts.G=[1:100, 1:100];

%----------------------- Run the code mc_cgLassoLeast -----------------------
z=0.1;
tic;
[x2, c2, funVal2, Value2L]= tree_LogisticR(A, y, z, opts);
toc;

