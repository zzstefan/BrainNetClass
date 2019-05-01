%example_accel_grad_mc

clear all;
clc

% add path
addpath(genpath('../../SLEP/'));

% load data and set regularization parameter
load('../../data/matrix_classification_data.mat');
lambda = 10^-4;

% call the main function
[Wp,b,fval_vec,itr_counter] = accel_grad_mc(D,L,lambda);

