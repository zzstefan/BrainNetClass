function [result_features]=back_find_low_node_para(result_dir,nSubj,k_times,nROI,w,cross_val,ttest_p,midw_lasso)

% This function aims to find features used in the classification, suitable
% for the SR,SLR,SGR,GSR,WSR,WSGR,SSGSR network construction method. And it is also
% suitable for the LOOCV or the 10-fold cross validation. The found
% features can be applied on the visualization software to present the
% important brain regions or links.
% Input:
%         result_dir: the directory you want to store all the result files;
%         nSubj: number of subjects;
%         k_times: times of 10-fold cross validation;
%         nROI: number of ROIs 
%         w: weight of each selected features;
%         cross_val: loocv or 10-fold;
%         ttest_pm,midw_lasso: the feature selection indexes of ttest or
%         lasso;
%         
% Output:
%        result_features: cell array, consisting of the averaged weight and occurrence of the features;

% Written by Zhen Zhou, zzstefan@email.unc.edu
% IDEA lab, https://www.med.unc.edu/bric/ideagroup
% Department of Radiology and BRIC, University of North Carolina at Chapel Hill




% clear all
% load SR_10_fold_middle.mat;
% load SR_loocv_middle.mat;
% cross_val='loocv';
% ttest_p=feature_index_ttest;
% midw_lasso=feature_index_lasso;
fprintf('Begin contributing feature identification\n');
if strcmpi(cross_val,'10-fold')
    for i=1:size(ttest_p,1)
        for j=1:size(ttest_p,2)
            tmp=find(ttest_p{i,j}<0.05);
            tmp_b{i,j}=find(midw_lasso{i,j});
            index=tmp(tmp_b{i,j});
            for k=1:length(index)
                [first{i,j,k}(1),first{i,j,k}(2)]=find_elements(nROI,index(k));
            end
        end
    end
elseif strcmpi(cross_val,'loocv')
    for i=1:length(ttest_p)
        tmp=find(ttest_p{i}<0.05);
        tmp_b{i}=find(midw_lasso{i});
        index=tmp(tmp_b{i});
        for k=1:length(index)
            [first{i,k}(1),first{i,k}(2)]=find_elements(nROI,index(k));
        end
    end
end

%first=cellfun(@(x) x',first,'UniformOutput',false);
temp=first(:);

[a1,b,c]=unique(cellfun(@char,temp,'un',0));
lo=histc(c,1:max(c));
loo=lo(:)>1;
out=[temp(b(loo)),num2cell(lo(loo))];
out(1,:)=[];


All_link=out(find(cell2mat(out(:,2))>0),1);%find all links which exists in any one  LOOCV fold
if strcmpi(cross_val,'10-fold')
    for j=1:length(All_link)
        weight=[];
        temp_index=cell2mat(cellfun(@(x)isequal(x,All_link{j}),first,'un',0));
        ind=find(temp_index);
        [A,B,C]=ind2sub(size(temp_index),ind);
        for k=1:length(A)
            weight=[weight,w{A(k),B(k)}(C(k))];
        end
        all_weight(j)=mean(weight);
    end
elseif strcmpi(cross_val,'loocv')
    for j=1:length(All_link)
        weight=[];
        temp_index=cell2mat(cellfun(@(x)isequal(x,All_link{j}),first,'un',0));
        [A,B]=find(temp_index);
        for k=1:length(A)
            weight=[weight,w{A(k)}(B(k))];
        end
        all_weight(j)=mean(weight);
    end
end

matrix_1=zeros(nROI,nROI);
matrix_2=zeros(nROI,nROI);
for m=1:size(out,1)
    matrix_1(out{m,1}(1),out{m,1}(2))=all_weight(m);
    matrix_1(out{m,1}(2),out{m,1}(1))=all_weight(m);
    matrix_2(out{m,1}(1),out{m,1}(2))=out{m,2};
    matrix_2(out{m,1}(2),out{m,1}(1))=out{m,2};
end
result_features{1}=matrix_1;

if strcmpi(cross_val,'loocv')
    matrix_2=matrix_2/nSubj;
elseif strcmpi(cross_val,'10-fold')
    matrix_2=matrix_2/(10*k_times);
end
result_features{2}=matrix_2;


figure('visible','off');
subplot(1,2,1);
imagesc(matrix_1);
colormap jet
colorbar
axis square
xlabel('ROI');
ylabel('ROI');
title('Averaged weight');

subplot(1,2,2);
imagesc(matrix_2);
colormap jet
colorbar
axis square
xlabel('ROI');
ylabel('ROI');
title('Normalized occurence');
print(gcf,'-r1000','-dtiff',char(strcat(result_dir,'/result_features_weigthAndOccurence.tiff')));


fprintf('End contributing feature identification\n');
