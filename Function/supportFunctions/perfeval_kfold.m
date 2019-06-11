function [auc,SEN,SPE,F1,Youden,BalanceAccuracy,plot_ROC]=perfeval_kfold(Label,pred_Label,prob_Estimates)
% Performance evaluation
% 1: Patient (e.g., MCI), -1: Normal control (NC)
% 
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
SEN=Sensitivity*100;
SPE=Specificity*100;
F1=Fscore*100;
Youden=Youden*100;
BalanceAccuracy=BalanceAccuracy*100;
