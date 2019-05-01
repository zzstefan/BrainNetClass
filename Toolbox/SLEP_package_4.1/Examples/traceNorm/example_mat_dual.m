%example_mat_dual

clear all;
clc
clear opt;
% add path
addpath(genpath('../../SLEP/'));

% load data and set regularization parameter
load('../../data/scene.mat');
lambda = 10^-4;

% center data
D = CenterRowData(D);
L = CenterRowData(L);

% call the main function
[W,fmin] = mat_dual(D,L,lambda); 







