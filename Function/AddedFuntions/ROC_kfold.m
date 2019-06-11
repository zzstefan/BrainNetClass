function []=ROC_kfold(plot_ROC,result_dir,k_fold)
% This is for drawing the ROC curve when performing the 10-fold cross validation 10 times.
% Combine the 10 ROC curves into one.

%Input:
%   plot_ROC: middle results used to plot ROC curve, obtained from the
%   perfeval function or perfeval_kfold function;
%   result_dir: the directory used to store all the result data or figures;
%   k_fold: number of 10-fold cross validation, default is 10;

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill
% College of Computer Science, Zhejiang University, China
fold_times=k_fold;
for i=1:fold_times
    tmp(:,i)=plot_ROC{i}(:,1);
end
x_label=unique(tmp);

for i=1:length(x_label)
    for j=1:fold_times
        A{i,j}=find(plot_ROC{j}(:,1)==x_label(i));
    end
end
temp1=[];
for i=1:length(x_label)
    for j=1:fold_times
        if isempty(A{i,j})
            continue;
        else
            temp=plot_ROC{j}(:,2);
            temp1=[temp1;temp(A{i,j})];
        end
    end
   
    y_label(i)=mean(temp1);
    stderror(i)=std(temp1)/sqrt(length(temp1));
    temp1=[];
end
x_label=x_label';
figure('visible','off');
h=fill([x_label,fliplr(x_label)],[y_label-stderror,fliplr(y_label+stderror)],'b');
set(h,'facealpha',0.3);
hold on
plot(x_label,y_label,'k');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC curve (10-fold)']);
axis square;
print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/ROC.tiff')));