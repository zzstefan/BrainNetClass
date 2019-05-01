function [auc,SEN,SPE,F1,plot_ROC]=perfeval(Label,pred_Label,prob_Estimates,result_dir)
% Performance evaluation
% 1: Patient (e.g., MCI), -1: Normal control (NC)
% 

save test.mat pred_Label prob_Estimates;
TP = sum(pred_Label==1 & Label == 1); % MCI --> MCI
FP = sum(pred_Label==1 & Label == -1); % NC --> MCI
TN = sum(pred_Label==-1 & Label == -1); % NC --> NC
FN = sum(pred_Label==-1 & Label == 1); % MCI --> NC
Sensitivity = TP/(TP+FN);
Specificity = TN/(TN+FP);
Precision = TP/(TP+FP);
Recall = TP/(TP+FN); % = Sensitivity
Youden = Sensitivity+Specificity-1;
Fscore = 2*Precision*Recall/(Precision+Recall);
BalanceAccuracy = 0.5*(Sensitivity+Specificity);


[val,ind] = sort(prob_Estimates,'descend');
roc_y = Label(ind);
stack_x = cumsum(roc_y == -1)/sum(roc_y == -1);
stack_y = cumsum(roc_y == 1)/sum(roc_y == 1);
auc = sum((stack_x(2:length(roc_y),1)-stack_x(1:length(roc_y)-1,1)).*stack_y(2:length(roc_y),1));
plot_ROC=[stack_x,stack_y];
%figure
figure('visible','off');
plot(stack_x,stack_y,'LineWidth',2);
set(gca,'XTick',[0:0.1:1]);
%hold on
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC curve of (AUC = ' num2str(auc) ' )']);
%print(gcf,'-dtiff','./result/ROC.tiff');
%print(gcf,'-dtiff',char(strcat(result_dir,'/ROC.tiff')));
print(gcf,'-dtiffn',char(strcat(result_dir,'/ROC_tiffn.tiff')));
%print(gcf,'-depsc',char(strcat(result_dir,'/ROC_epsc.eps')));


fprintf('Testing set AUC: %g\n',auc);
fprintf(1,'Testing set Sens: %3.2f%%\n',Sensitivity*100);
fprintf(1,'Testing set Spec: %3.2f%%\n',Specificity*100);
fprintf(1,'Testing set Youden: %3.2f%%\n',Youden*100);
fprintf(1,'Testing set F-score: %3.2f%%\n',Fscore*100);
fprintf(1,'Testing set BAC: %3.2f%%\n',BalanceAccuracy*100);

SEN=Sensitivity*100;
SPE=Specificity*100;
F1=Fscore*100;

