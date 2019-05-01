clear, clc;

% This is an example for running the function tree_mtLogisticR
%
%  Problem:
%
%  min  - sum_{il} weight_{il} log( p_{il} ) + z * sum_i sum_j w_j ||x^i_{G_j}||
%
%  p_{il}= 1 / (1+ exp(-y_i (x_i' * a_i + c_l) ) ) denotes the probability
%  weight_{il} is the weight for the i-th sample in the l-th classifier
%                is a m x k matrix
%  c_l is the intercept for the l-th classfier, and is a 1xk vector
%  x_i denotes the i-th column of x
%  x^j denotes the j-th row of x
%  a_i' denotes the i-th row of A
%
%  y_i (either 1 or -1) is the response
%
%  In this implementation, we assume weight_{il}=1/(mk)
%
%  x^i denotes the i-th row of x
%
%  G_j's are nodes with tree structure
%
%  We assume that the tasks are of a tree structure
%
%  The tree structured group information is contained in
%  opts.ind, which is a 3 x nodes matrix, where nodes denotes the number of
%  nodes of the tree.
%
%  opts.ind_t(1,:) contains the starting index
%  opts.ind_t(2,:) contains the ending index
%  opts.ind_t(3,:) contains the corresponding weight (w_j)
%
%  Note: 
%  1) If each element of x^j is a leaf node of the tree and the weight for
%  this leaf node are the same, we provide an alternative "efficient" input
%  for this kind of node, by creating a "super node" with 
%  opts.ind_t(1,1)=-1; opts.ind_t(2,1)=-1; and opts.ind_t(3,1)=the common weight.
%
%  2) If the features are well ordered in that, the features of the left
%  tree is always less than those of the right tree, opts.ind(1,:) and
%  opts.ind(2,:) contain the "real" starting and ending indices. That is to
%  say, x^j( opts.ind_t(1,j):opts.ind_t(2,j) ) denotes x^j_{G_j}. In this case,
%  the entries in opts.ind_t(1:2,:) are within 1 and k (the number of tasks).
%
%
%  If the features are not well ordered, please use the input opts.G for
%  specifying the index so that  
%   x^j( opts.G ( opts.ind_t(1,j):opts.ind_t(2,j) ) ) denotes x^j_{G_j}.
%  In this case, the entries of opts.G are within 1 and n, and the entries of
%  opts.ind_t(1:2,:) are within 1 and length(opts.G).
%
% The following example shows how G and ind_t works:
%
% G={ {1, 2}, {4, 5}, {3, 6}, {7, 8},
%     {1, 2, 3, 6}, {4, 5, 7, 8}, 
%     {1, 2, 3, 4, 5, 6, 7, 8} }.
%
% ind_t={ [1, 2, 100]', [3, 4, 100]', [5, 6, 100]', [7, 8, 100]',
%       [9, 12, 100]', [13, 16, 100]', [17, 24, 100]' },
%
% where each node has a weight of 100.
%
%  3) we use opts.ind to denote the starting and ending indices for the
%  samples of different tasks.
%  Samples for the the first task is in 
%    A ( (opts.ind(1)+1):opts.ind(2), :  )

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

m=1000;  n=80;       % The data matrix is of size m x n
k=100;

randNum=1;
% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

randn('state',(randNum-1)*3+2);
y=2*(randn(m,1) >0)-1;

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
opts.rFlag=1;     % use ratio

% Normalization
opts.nFlag=0;       % without normalization

% Group Property
opts.q=2;           % set the value for q

% Group Property
opts.ind_t=[[-1, -1, 1]',... % leave nodes (each node contains one feature)
    [1, 20, sqrt(20)]', [21, 40, sqrt(20)]',... % the layer above the leaf
    [41, 50, sqrt(10)]', [51, 70, sqrt(20)]', [71,100, sqrt(30)]',...
    [1, 50, sqrt(50)]', [51, 100, sqrt(50)]']; % the higher layer

% samples for different tasks
opts.ind=[0, 10:10:1000]; % each task has 10 samples

%% Run the function
z=0.5;

tic;
[x1, c1, funVal1, ValueL1]= tree_mtLogisticR(A, y, z, opts);
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
opts.rFlag=1;     % use ratio

% Normalization
opts.nFlag=0;       % without normalization

% Group Property
opts.q=2;           % set the value for q

% Group Property
opts.ind_t=[[-1, -1, 1]',... % leave nodes (each node contains one feature)
    [1, 20, sqrt(20)]', [21, 40, sqrt(20)]',... % the layer above the leaf
    [41, 50, sqrt(10)]', [51, 70, sqrt(20)]', [71,100, sqrt(30)]',...
    [101, 150, sqrt(50)]', [151, 200, sqrt(50)]']; % the higher layer
opts.G=[1:100, 1:100];

% samples for different tasks
opts.ind=[0, 10:10:1000]; % each task has 10 samples

%% Run the function
z=0.5;

tic;
[x2, c2, funVal2, ValueL2]= tree_mtLogisticR(A, y, z, opts);
toc;

