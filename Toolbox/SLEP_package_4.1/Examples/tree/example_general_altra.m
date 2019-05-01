clear, clc;

% This is an example for running the function general_altra
%
%  Problem:
%
%  min  1/2 || x - v||^2 + z * sum_j w_j ||x_{G_j}||
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

n=10000;
v=randn(n,1);
ind=[ [-1, -1, 0.5]'; [1, 3000, 0.2]'; [3001, 6000, 0.2]'; [6001, 10000, 0.2]';...
    [1001, 20000, 2]'];
G=[1:10000, 1:10000];

nodes=size(ind,2);

tic;
x=general_altra(v, n, G, ind, nodes);
toc;

