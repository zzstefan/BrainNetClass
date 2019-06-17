function [opt_paramt]=select_para(meth_Net,Acc_para,varargin)
% This function is used to find the suggested parameter(s) according to the
% Acc_para;

% Input:
%         meth_Net: brain network construction method;
%         Acc_para: result obtained from the parameter sensitivitiy test;
%         varargin: different parameters according to different brain network construction method;
% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill
      
switch meth_Net
    case {'SR','WSR','GSR'}
        lambda_1=varargin{1};
        [max_acc,max_index]=max(Acc_para);
        opt_paramt=lambda_1(max_index);
    case {'SLR','SGR','WSGR','SSGSR'}
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        opt_paramt=zeros(1,2);
        [max_acc,max_index]=max(Acc_para);
        which_lambda1=ceil(max_index/length(lambda_1));
        which_lambda2=mod(max_index,length(lambda_1));
        opt_paramt(1,2)=lambda_2(which_lambda1);
        if which_lambda2==0
            opt_paramt(1,1)=lambda_1(length(lambda_1));
        else
            opt_paramt(1,1)=lambda_1(which_lambda2);
        end
    case {'dHOFC'}
        W=varargin{1};
        C=varargin{2};
        opt_paramt=zeros(1,2);
        [max_acc,max_index]=max(Acc_para);
        which_C=ceil(max_index/length(W));
        which_W=mod(max_index,length(W));
        opt_paramt(1,2)=C(which_C);
        if which_W==0
            opt_paramt(1,1)=W(length(W));
        else
            opt_paramt(1,1)=W(which_W);
        end
end
