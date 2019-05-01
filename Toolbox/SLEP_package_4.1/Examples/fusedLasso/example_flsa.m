clear, clc;

% This is an example for running the function flsa
%
%% Problem:
%
%  min  1/2 || x - v||^2 + lambda1 * ||x||_1 + 
%       lambda2 * sum_i |x_i-x_{i+1}|
%
% For detailed description of the function, please refer to the Manual.
%
%% Related papers
%
% [1]  Jun Liu, Lei Yuan, and Jieping Ye, An Efficient Algorithm for 
%      a Class of Fused Lasso Problems, KDD, 2010.
%
%% ------------   History --------------------
%
% First version on 14 November 2009.
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/fusedLasso;      

n=10000;        % the problem size
randState=1;    % the random seed for reporducing the experiments
nn=n-1;         % the size of the dual variable

%% generate the data
randn('state',randState);
v=randn(n,1);

lambda1=0.01;   % the regularization parameter for L1
lambda2=1;      % the regularization parameter for the fused part
tol=1e-10;      % the duality gap for termination
maxStep=50;     % the maximal number of iterations

% the starting point
z0=zeros(nn,1);

tic;
[x, z, infor]=flsa(v, z0,...
    lambda1, lambda2, n,...
    maxStep, tol, 1, 6);
toc;
% x -               the solution
% v -               the input variable
% lambda1, lambda2 -the regularization parameters
%
% please refer to sfa.h for detailed description of the other input and output
% variables
