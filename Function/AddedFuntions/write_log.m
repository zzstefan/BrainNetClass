function write_log(result_dir,meth_Net,cross_val,AUC,SEN,SPE,F1,Acc,varargin)
% PC: Pearson's correlation
% SR: Sparse representation
% WSR: Weighted SR
% SGR: Sparse group representation
% WSGR: Weighted SGR
% GSR: Group sparse represenation
% SSGSR: Strength and similarity guided GSR
% tHOFC: Topographical high-order FC
% aHOFC: Associated high-order FC
% dHOFC: Dynamic high-order FC
%% Leave-one-out cross validation was performed on the 
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
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'lambda ranges in %s and it controls the controlling sparsity\r\n',num2str(lambda_1));
        fprintf(fp,'Using connection-based coefficients as features and t-test ( p<0.05 ) + LASSO ( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1);
    case 'GSR'
        lambda_1=varargin{1};
        lasso_lambda=varargin{2};
        opt_paramt=varargin{3};
        ktimes=varargin{4};
        opt_t=varargin{5};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'lambda ranges in %s and it controls the controlling group sparsity\r\n',num2str(lambda_1));
        fprintf(fp,'Using connection-based coefficients as features and t-test ( p<0.05 ) + LASSO( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1);
    case {'SGR','WSGR'}
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'lambda_1 ranges in %s and it controls the controlling sparsity\r\n',num2str(lambda_1));
        fprintf(fp,'lambda_2 ranges in %s and it controls the controlling group sparsity\r\n',num2str(lambda_2));
        fprintf(fp,'Using connection-based coefficients as features and ttest ( p<0.05 ) + LASSO ( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'SSGSR'
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'lambda_1 ranges in %s and it controls the controlling group sparsity\r\n',num2str(lambda_1));
        fprintf(fp,'lambda_2 ranges in %s and it controls the controlling inter-subject LOFC-pattern similarity\r\n',num2str(lambda_2));
        fprintf(fp,'Using connection-based coefficients as features and ttest ( p<0.05 ) + LASSO ( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'SLR'
        lambda_1=varargin{1};
        lambda_2=varargin{2};
        lasso_lambda=varargin{3};
        opt_paramt=varargin{4};
        ktimes=varargin{5};
        opt_t=varargin{6};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'lambda_1 ranges in %s and it controls low rank\r\n',num2str(lambda_1));
        fprintf(fp,'lambda_2 ranges in %s and it controls sparisty\r\n',num2str(lambda_2));
        fprintf(fp,'Using connection-based coefficients as features and ttest ( p<0.05 ) + lasso ( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,lambda_1,lambda_2);
    case 'dHOFC'
        window_length=varargin{1};
        step=varargin{2};
        clusters=varargin{3};
        lasso_lambda=varargin{4};
        opt_paramt=varargin{5};
        ktimes=varargin{6};
        opt_t=varargin{7};
        fprintf(fp,'%s method is used to constructed the brain network.\r\n',meth_Net);
        fprintf(fp,'step length is %s \r\n',num2str(step));
        fprintf(fp,'cluster ranges in %s \r\n',num2str(clusters));
        fprintf(fp,'window_length ranges in %s \r\n',num2str(window_length));
        fprintf(fp,'Using weighted-graph local clustering coefficients as features and lasso( lambda=%0.2g ) for feature selection\r\n',lasso_lambda);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
            opt_t=opt_t(:);
        end
        fprintf(fp,'The suggested parameter(s): %s \r\n',num2str(opt_paramt));
        cal_frequency(result_dir,fp,opt_t,meth_Net,window_length,clusters);
    case {'PC','aHOFC','tHOFC'}
        fe_method=varargin{1};
        fs_method=varargin{2};
        ktimes=varargin{3};
        fprintf(fp,'%s method is used to constructed the brain network and no parameter required\r\n',meth_Net);
        [fe_method,fs_method]=trans(fe_method,fs_method);
        fprintf(fp,'Using %s as features and %s for feature selection\r\n',fe_method,fs_method);
        fprintf(fp,'Using %s to calculate the final results\r\n',cross_val_method);
        if strcmpi(cross_val_method,'10-fold')
            fprintf(fp,'The 10-fold cross valindation was repeated %d times \r\n',ktimes);
        end
end

fprintf(fp,'Testing set AUC:\t\t\t\t\t\t%0.4g\r\nTesting set ACC:\t\t\t\t\t\t%3.2f%%\r\nTesting set SEN:\t\t\t\t\t\t%3.2f%%\r\nTesting set SPE:\t\t\t\t\t\t%3.2f%%\r\nTesting set F-score:\t\t\t\t\t\t%3.2f%%\r\n',AUC,Acc,SEN,SPE,F1);

fclose(fp);

function [fe_method,fs_method]=trans(fe_method,fs_method)
if strcmpi(fe_method,'coef')
    fe_method='connection-based coefficients';
elseif strcmpi(fe_method,'clus')
    fe_method='weighted-graph local clustering coefficients';
end

if strcmpi(fs_method,'ttest')
    fs_method='ttest(p<0.05)';
elseif strcmpi(fs_method,'lasso')
    fs_method='lasso(lambda=0.1)';
elseif strcmpi(fs_method,'ttest + lasso')
    fs_method='ttest(p<0.05) + lasso(lambda=0.1)';
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
        title(['Occurrence frequency of parameter(s)']);
        print(gcf,'-depsc',char(strcat(result_dir,'paprameter_occurrence.eps')));
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
        xlabel('\lambda_1 and \lambda_2','Fontsize',13);
        ylabel('Frequency of occurrence (%)');
        title(['Occurrence frequency of parameter(s)']);
        print(gcf,'-depsc',char(strcat(result_dir,'paprameter_occurrence.eps')));
    case 'dHOFC'
        W=varargin{1};
        C=varargin{2};
        
        for i=1:length(All)
            which_C=ceil(All(i)/length(W));
            which_W=mod(All(i),length(W));
            opt_paramt(i,1)=C(which_C);
            if which_W==0
                opt_paramt(i,2)=W(length(C));
            else
                opt_paramt(i,2)=W(which_W);
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
        xlabel('Window length and number of clusters');
        ylabel('Frequency of occurrence (%)');
        title(['Occurrence frequency of parameter(s)']);
        print(gcf,'-dtiffn',char(strcat(result_dir,'/paprameter_occurrence.tiff')));
end