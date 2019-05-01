function [opt_paramt]=select_para(meth_Net,Acc_para,varargin)
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
        opt_paramt(1,1)=C(which_C);
        if which_W==0
            opt_paramt(1,2)=W(length(C));
        else
            opt_paramt(1,2)=W(which_W);
        end
end
