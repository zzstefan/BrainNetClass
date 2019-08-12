function write_log(result_dir,meth_Net,cross_val,AUC,SEN,SPE,F1,Acc,Youden,BalanceAccuracy,varargin)

% This function records all the calculation details in a log file, including the method used to construct the brain network, the parameter range,
% the meaning of each parameter, the CV method (using LOOCV/10-fold CV) to conduct the analysis, the suggested parameters, the occurrence frequency of each parameter
% or parameter combination.
% 
% Input:
% 	result_dir: the directory used to store all the results;
% 	meth_Net: brain network construction method;
% 	cross_val: loocv or 10-fold;
% 	AUC, SEN, SPE,F1,Acc,Youden,BalanceAccuracy: model performance
% 	varargin: according to different conditions, this could be the parameter range, lambda of lasso, etc.

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill


fprintf('Save resluts.\n');
fileName=char(strcat(result_dir,'/log.txt'));
fp=fopen(fileName,'w');
% fprintf(fp,'%%PC: Pearson''s correlation \r\n%%SR: Sparse representation \r\n%%WSR: Weighted SR \r\n');
% fprintf(fp,'%%SGR: Sparse group representation \r\n%%WSGR: Sparse group representation \r\n%%GSR: Group sparse represenation \r\n');
% fprintf(fp,'%%SSGSR: Strength and similarity guided GSR \r\n%%SLR: sparse and low-rank representation \r\n');
% fprintf(fp,'%%tHOFC: Topographical high-order FC \r\n%%aHOFC: Associated high-order FC \r\n%%dHOFC: Dynamic high-order FC \r\n \r\n');

if strcmpi(cross_val,'loocv')
    cross_val_method='leave-one-out cross validation';
elseif strcmpi(cross_val,'10-fold')
    cross_val_method='10-fold';
end

switch meth_Net
    case {'SR','WSR'}
        lambda_1=varargin{1};
        lasso_lambda=varargin{2};
        opt_paramt=varargin{3};
        ktimes=varargin{4};
        opt_t=varargin{5};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Lambda ranges in %s.\r\n',num2str(lambda_1));
        fprintf(fp,'Lambda controls the sparsity.\r\n\n');
        fprintf(fp,'Using connection coefficients as features and t-test (p<0.05) + LASSO (lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times.\r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s.\r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1);
        
    case 'GSR'
        lambda_1=varargin{1};
        lasso_lambda=varargin{2};
        opt_paramt=varargin{3};
        ktimes=varargin{4};
        opt_t=varargin{5};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Lambda ranges in %s.\r\n',num2str(lambda_1));
        fprintf(fp,'Lambda controls the group sparsity.\r\n\n');
        fprintf(fp,'Using connection coefficients as features and t-test (p<0.05) + LASSO(lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s. \r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1);
    case {'SGR','WSGR'}
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Lambda 1 ranges in %s.\r\n',num2str(lambda_1));
        fprintf(fp,'Lambda 2 ranges in %s.\r\n',num2str(lambda_2));
        fprintf(fp,'Lambda 1 controls the sparsity and lambda 2 controls the group sparsity.\r\n\n');
        fprintf(fp,'Using connection coefficients as features and ttest (p<0.05) + LASSO (lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s. \r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'SSGSR'
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Lambda 1 ranges in %s.\r\n',num2str(lambda_1));
        fprintf(fp,'Lambda 2 ranges in %s.\r\n',num2str(lambda_2));
        fprintf(fp,'Lambda 1 controls the sparsity and lambda 2 controls the inter-group LOFC-pattern similarity.\r\n\n');
        fprintf(fp,'Using connection coefficients as features and ttest (p<0.05) + LASSO (lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s. \r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'SLR'
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Lambda 1 ranges in %s.\r\n',num2str(lambda_1));
        fprintf(fp,'Lambda 2 ranges in %s.\r\n',num2str(lambda_2));
        fprintf(fp,'Lambda 1 controls low rank and lambda 2 controls sparsity.\r\n\n');
        fprintf(fp,'Using connection coefficients as features and ttest (p<0.05) + lasso (lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s. \r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'dHOFC'
        window_length=varargin{1};
        step=varargin{2};
        clusters=varargin{3};
        lasso_lambda=varargin{4};
        opt_paramt=varargin{5};
        ktimes=varargin{6};
        opt_t=varargin{7};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n\n',meth_Net);
        fprintf(fp,'Step size is %s. \r\n',num2str(step));
        fprintf(fp,'Number of clusters ranges in %s. \r\n',num2str(clusters));
        fprintf(fp,'Window length ranges in %s. \r\n\n',num2str(window_length));
        fprintf(fp,'Using local clustering coefficients as features and lasso(lambda=%0.2g) for feature selection.\r\n\n',lasso_lambda);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n\n',ktimes);
            opt_t=opt_t(:);
        else 
            fprintf(fp,'Using %s to calculate the final results.\r\n',cross_val_method);
        end
        fprintf(fp,'The suggested parameter(s): %s. \r\n\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,window_length,clusters);
    case {'PC','aHOFC','tHOFC'}
        fe_method=varargin{1};
        fs_method=varargin{2};
        ktimes=varargin{3};
        lasso_lambda=varargin{4};
        fprintf(fp,'%s method is used to constructed the brain network and no parameter required.\r\n\n',meth_Net);
        [fe_method,fs_method]=trans(fe_method,fs_method,lasso_lambda);
        fprintf(fp,'Using %s as features and %s for feature selection.\r\n\n',fe_method,fs_method);
        fprintf(fp,'Using %s to calculate the final results.\r\n\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times. \r\n',ktimes);
        end
end
fprintf(fp,'\nModel evaluation result based on testing set:\r\n');
fprintf(fp,'AUC:\t\t\t\t\t\t%0.4g\r\nACC:\t\t\t\t\t\t%3.2f%%\r\nSEN:\t\t\t\t\t\t%3.2f%%\r\nSPE:\t\t\t\t\t\t%3.2f%%\r\nYouden:\t\t\t\t\t\t%3.2f%%\r\nF-score:\t\t\t\t\t\t%3.2f%%\r\nBAC:\t\t\t\t\t\t%3.2f%%\r\n',...
    AUC,Acc,SEN,SPE,Youden,F1,BalanceAccuracy);

fclose(fp);




function [fe_method,fs_method]=trans(fe_method,fs_method,lasso_lambda)
if strcmpi(fe_method,'coef')
    fe_method='connection coefficients';
elseif strcmpi(fe_method,'clus')
    fe_method='local clustering coefficients';
end

if strcmpi(fs_method,'ttest')
    fs_method='ttest(p<0.05)';
elseif strcmpi(fs_method,'lasso')
    fs_method=sprintf('lasso(lambda=%0.2g)',lasso_lambda);
elseif strcmpi(fs_method,'ttest + lasso')
    fs_method=sprintf('ttest(p<0.05) + lasso(lambda=%0.2g)',lasso_lambda);
end

function cal_frequency(result_dir,file,opt_t,meth_Net,varargin)
freq=tabulate(opt_t);
fp=file;
All=unique(opt_t);
for i=1:length(All)
    Frequency(i)=freq(find(freq(:,1)==All(i)),3);
end
ind_x=1:length(Frequency);
name=string(length(All));

switch meth_Net
    case {'SR','WSR','GSR'}
        lambda_1=varargin{1};
        for i=1:length(All)
            opt_paramt(i)=lambda_1(All(i));
            name(i)=char(num2str(opt_paramt(i)));
        end
        fprintf(fp,'The occurrence of hyper-parameter(s):\n');
        for i=1:length(name)
            fprintf(fp,'%s \t\t\t\t\t\t\t %0.2g%%\n',name(i),Frequency(i));
        end
        figure('visible','off');
        bar(Frequency);
        set(gca,'XTick',ind_x,'XTicklabel',name);
        ax=gca;
        ax.XTickLabelRotation=45;
        xlabel('\lambda','Fontsize',13);
        ylabel('Frequency of occurrence (%)');
        title('Occurrence frequency of selected parameter(s)');
        print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/Model_robustness.tiff')));
    case {'SGR','WSGR','SLR','SSGSR'}
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        
        for i=1:length(All)
            which_lambda1=ceil(All(i)/length(lambda_1));
            which_lambda2=mod(All(i),length(lambda_1));
            opt_paramt(i,2)=lambda_2(which_lambda1);
            if which_lambda2==0
                opt_paramt(i,1)=lambda_1(length(lambda_1));
            else
                opt_paramt(i,1)=lambda_1(which_lambda2);
            end
            name(i)=char(strcat(num2str(opt_paramt(i,1)),',',num2str(opt_paramt(i,2))));
        end
        fprintf(fp,'The occurrence of hyper-parameter(s):\n');
        for i=1:length(name)
            fprintf(fp,'%s \t\t\t\t\t\t\t %0.2g%%\n',name(i),Frequency(i));
        end
        figure('visible','off');
        bar(Frequency);
        set(gca,'XTick',ind_x,'XTicklabel',name);
        ax=gca;
        ax.XTickLabelRotation=45;
        xlabel('\lambda_1,\lambda_2','Fontsize',13);
        ylabel('Frequency of occurrence (%)');
        title(['Occurrence frequency of selected parameter(s)']);
        print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/Model_robustness.tiff')));
    case 'dHOFC'
        W=varargin{1};
        C=varargin{2};
        
        for i=1:length(All)
            which_C=ceil(All(i)/length(W));
            which_W=mod(All(i),length(W));
            opt_paramt(i,2)=C(which_C);
            if which_W==0
                opt_paramt(i,1)=W(length(W));
            else
                opt_paramt(i,1)=W(which_W);
            end
            name(i)=char(strcat(num2str(opt_paramt(i,1)),',',num2str(opt_paramt(i,2))));
        end
        fprintf(fp,'The occurrence of hyper-parameter(s):\n');
        for i=1:length(name)
            fprintf(fp,'%s \t\t\t\t\t\t\t %0.2g%%\n',name(i),Frequency(i));
        end
        figure('visible','off');
        bar(Frequency);
        set(gca,'XTick',ind_x,'XTicklabel',name);
        ax=gca;
        ax.XTickLabelRotation=45;
        xlabel('Number of clusters,Window length');
        ylabel('Frequency of occurrence (%)');
        title(['Occurrence frequency of selected parameter(s)']);
        print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/Model_robustness.tiff')));
end