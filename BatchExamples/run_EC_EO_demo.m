% Command line mode of BrainNetClass, in case user doesn't want to use GUI
% Note: this is a demo for constructing dHOFC network for two-class
% classification (patient, control), it also generates results using
% PC and SR as two baseline results for comparison purposes
% run_EC_EO_demo is the main function that can be used for ALL analysis, ALL the
% results (except log.txt) will be generated, similar to GUI.

clear all
cd BatchExamples;
mkdir test1;  % for saving results from dHOFC
mkdir test2;  % for saving results from PC
mkdir test3;  % for saving results from SR

addpath(genpath(pwd));

% load label file, they are provided in BatchExample dir
load ECEO_label.mat; % A matrix named 'label' in a size of M x 1, taking the SAME order as that of FED_NC.mat
% load data file
load ECEO.mat; % A cell array named 'BOLD' in a size of M x 1, each cell contains a T (nTimePoints) x N (nROI) time series data  


% 1- Main method
meth_Net='dHOFC';

s=1;  % step size for dynamic FC calculation, only changable in batch mode
W=50:10:120;  % window length
C=100:100:800;  % number of clusters
lambda_lasso=0.05;  % hyper-parameter in lasso, controls feature selection, only changable in batch mode

% It then calls param_select_demo.m to run dHOFC network construction and classification
% For other network construction methods and other parameter settings, see param_select_demo.m
[opt_paramt,AUC,SEN,SPE,F1,Acc,opt_t,ttest_p,midw_lasso,w,plot_ROC]=param_select_demo('./test1',meth_Net,BOLD,label,1,W,s,C,lambda_lasso);



% 2- baseline method
% This is a demo for constructing SR network for two-class classification
% (used as a baseline method)
meth_Net="SR";
lambda_1=0.01:0.01:0.1;
lambda_lasso=0.05;
[opt_paramt,AUC,SEN,SPE,F1,Acc,opt_t,ttest_p,midw_lasso,w,plot_ROC]=param_select_demo('./test2',meth_Net,BOLD,label,1,lambda_1,lambda_lasso);



% 3- another baseline method
% This is a demo for constructing PC network for two-class classification
% (used as a baseline method)
% It can also be used for all other type I-based classification
meth_Net="PC";
meth_FEX="coef";
meth_FS="t-test + LASSO";  %% you can choose from 'LASSO','t-test','t-test + LASSO'
lambda_lasso=0.1;
[AUC,SEN,SPE,F1,Acc,cpred,score,plot_ROC]=no_param_select_demo('./test3',meth_Net,meth_FEX,meth_FS,BOLD,label,lambda_lasso);