clear, clc;


FileName='treeNodes.txt'; % please make sure that this file exists in this folder

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



n=18;
v=randn(n,1);

rootNum=18;

tic;
x=orderTree(FileName, v, rootNum, n);
toc;

a=[v, x];