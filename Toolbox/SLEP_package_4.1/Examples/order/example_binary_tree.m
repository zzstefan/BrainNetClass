clear, clc;

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                  % add the functions in the folder SLEP to the path

% change to the original folder
cd Examples/order;

d=10;            % the depth of the binary tree
n=2^(d+1)-1;     % the number of nodes

rand('state',1);
v=randn(n,1);    % the input

tic;
x=orderTreeBinary(v,n);
t=toc;

a=[v, x];