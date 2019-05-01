clear, clc;

% This is an example for running the function eplb
%
%  Problem:
%
%  min  1/2 || x - y||^2
%  s.t. \|x\|_1 <= z
%
% For detailed description of the function, please refer to the Manual.
%
%% ------------   History --------------------
% First version on August 10, 2008.
%
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/L1;

n=1000;
v=randn(n, 1);
z=20;
lambda0=0;

% run the function epp
[x, lambda, iter_step]=eplb(v, n, z, lambda0);