function []=ROC_kfold(plot_ROC,result_dir,k_fold)
%% This is for drawing the ROC curve when performing the 10-fold cross validation 10 times.
%% Combine the 10 ROC curves into one.

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
title(['ROC curve of 10-times']);
print(gcf,'-dtiff',char(strcat(result_dir,'/ROC.tiff')));