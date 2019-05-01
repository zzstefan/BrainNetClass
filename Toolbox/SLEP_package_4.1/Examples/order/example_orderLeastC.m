clear, clc;

% This is an example for running the function orderLeast
% 
%  min  1/2 || A x - y||^2 + lambda * \|x\|
%  s.t. x satisfy the ordered tree structure (non-negative max-heap)
%
% For detailed description of the function, please refer to the Manual.
%
%% Related papers
%
% [1]  Jun Liu, Liang Sun, and Jieping Ye, Projection onto A Nonnegative
%      Max-Heap, NIPS 2011.
%
%% Note:
% In this example, the tree is given by the input file in treeNodes.txt
%
%  The root of the tree is node 18
%   
%   Parent node     # Child node   Child nodes
%
%   18               3             10  13  17
%   10               3             5   8   9
%   13               2             11  12
%   17               3             14  15  16
%   5                2             1  4
%   8                2             6  7
%   9                0
%   11               0
%   12               0
%   14               0
%   15               0
%   16               0
%   1                0
%   4                2              2  3
%   6                0
%   7                0
%   2                0
%   3                0

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/order;

m=18;  n=18;    % The data matrix is of size m x n

% for reproducibility
randNum=1;

% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);       % the data matrix

randn('state',(randNum-1)*3+2);
xOrin=randn(n,1);

% call orderTree to make xOrin satisfies the ordered tree structure
% here, we assumed that the tree structure is specified by treeNodes.txt 

FileName='treeNodes.txt';
rootNum=18;
x=orderTree(FileName, xOrin, rootNum, n);
xOrin=x;


randn('state',(randNum-1)*3+3);
noise=randn(m,1);
y=A*xOrin +...
    noise*0.01;     % the response


%----------------------- Set optional items -----------------------
opts=[];

% Starting point
opts.init=2;            % starting from a zero point

% Termination criterion
opts.tFlag=5;          % run .maxIter iterations
opts.maxIter=100;      % maximum number of iterations
opts.rFlag=1;          % for lambda, use the ratio

% Mormalization
opts.nFlag=0;         % without normalization

% The ordered tree is given by the file 
opts.FileName='treeNodes.txt';
opts.treeFlag=4; % 1: a sequential list
                 % 2: full binary tree, n=2^d -1
                 % 3: tree with depth 1
                 % 4: a general tree, where the tree is specified by
                 % opts.FileName
opts.rootNum=18; % node 18 is the root

% set the regularization parameter
lambda=1e-3;

[x, funVal, ValueL]= orderLeast(A, y, lambda, opts);

[x xOrin]