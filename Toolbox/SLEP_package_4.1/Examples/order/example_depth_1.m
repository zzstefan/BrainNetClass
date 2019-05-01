clear, clc;

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/order;


n=1e3;          % the number of nodes

rand('state',1);
v=randn(n,1);

tic;
x=orderTreeDepth1(v,n);
t=toc;

a=[v, x];