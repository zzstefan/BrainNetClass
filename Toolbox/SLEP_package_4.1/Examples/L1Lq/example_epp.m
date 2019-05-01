clear, clc;

% This is an example for running the function epp
%
%  Problem:
%
%  min  1/2 || x - y||^2 + rho * \|x\|_q
%
%  which is a subproblem of the Euclidean projection:
%
%  min \sum_i 1/2 || X_i - Y_i||^2 + rho * \sum_i \|X_i\|_q
%
% For detailed description of the function, please refer to the Manual.
%
%% ------------   History --------------------
% First version on August 10, 2009.
%
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/L1Lq;

n=100;
v=randn(n, 1);
lambda=1;
q=3;
c0=0.1;

% run the function epp
[x, c, iter_step]=epp(v, n, lambda, q, c0);