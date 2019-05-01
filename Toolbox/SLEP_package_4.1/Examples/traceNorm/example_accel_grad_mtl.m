%example_accel_grad_mtl

clear all;
clc

% add path
addpath(genpath('../../SLEP/'));

% load data and set regularization parameter
load('../../data/dmoz.mat');
lambda = 10^-4;

% center data
for i = 1:length(Xtrain)
        Xtrain{i} = CenterRowData(Xtrain{i});
        Ytrain{i} = CenterRowData(Ytrain{i});
end

% call the main function
[Wp,fval_vec,itr_counter] = accel_grad_mtl(Xtrain,Ytrain,lambda);







