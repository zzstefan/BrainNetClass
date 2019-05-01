%example_accel_grad_mlr

clear all;
clc

% add path
addpath('../../SLEP/trace/');

% load data and set regularization parameter
load('../../data/scene.mat');
lambda = 10^-4;

% center data
D = CenterRowData(D);
L = CenterRowData(L);

% call the main function
[Wp, fval_vec, itr_counter] = accel_grad_mlr(D,L,lambda);







