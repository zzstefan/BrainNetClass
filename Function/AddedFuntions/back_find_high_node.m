

function [result_features]=back_find_high_node(W,C,nROI,w,midw_lasso,IDX,opt_t)

%%according to feature selction, find the remaining features after lasso, 
%%high_index means the index after clustering, index means the index before clustering.
% clear all
% 
% load dHOFC_loocv_middle.mat;
%load dHOFC_kfold_middle.mat;
fprintf('Begin finding features\n');
midw_lasso=feature_index_lasso;

for i =1:size(midw_lasso,1)
    for j=1:size(midw_lasso,2)
        which_C=ceil(opt_t(i,j)/length(W));
        which_W=mod(opt_t(i,j),length(W));
        if which_W ==0
            which_W=length(C);
        end
        index{i,j}=IDX{which_W,which_C};
        high_index{i,j}=find(midw_lasso{i,j}~=0);
    end
end
%% index means the corresponding cluster number of each of the 6670 lines in the original low-order FC;
%% high_index ,each LOOCV ,there is one combination of hyper-parameter constructed brain network being choosen,
%% find the cluster number after feature selection


index=index(:);
high_index=high_index(:);
for i=1:length(high_index) 
    for j=1:length(high_index{i})
        tmp{i,j}=find(index{i}==high_index{i}(j));
    end
    %length_test(i)=length(find(~cellfun(@isempty,tmp(i,:))));
end

% B=unique(length_test);
% for i=1:length(B)
%     A(i)=length(find(length_test==B(i)));    
% end

%% find the frequency of each element in the cell array
tmp=cellfun(@(x) x',tmp,'UniformOutput',false);
temp=tmp(:);

[a1,b,c]=unique(cellfun(@char,temp,'un',0));
lo=histc(c,1:max(c));
loo=lo(:)>1;
out=[temp(b(loo)),num2cell(lo(loo))];
out(1,:)=[];
new_out=out;

%% find the weight of each cluster and the averaged accuracy would be the mean weight for each cluster.
for k=1:length(new_out)
    weight=[];
    test{k}=cellfun(@(x)isequal(x,new_out{k}),tmp,'un',0);
    [location{k}(:,1),location{k}(:,2)]=find(cell2mat(test{k}));
    for j=1:length(location{k})
        weight=[weight,w{location{k}(j,1)}(location{k}(j,2))];
    end
    W(k)=mean(weight);
end



for j=1:length(new_out)
    inner_tmp=new_out{j};
    for i=1:length(inner_tmp)
        [first{j}(i,1),first{j}(i,2)]=find_elements(116,new_out{j,1}(i));
    end
    new_out(j,3)=first(j);
end

%%according to the connection between ROI, create the 0-1 matrix for the
%%convenience of drawing in brainnet viewer


%Matrix=create_matrix(first);

for m=1:length(first)
    node_matrix{m}=eye(nROI,nROI);
    for n=1:length(first{m})
        node_matrix{m}(first{m}(n,1),first{m}(n,2))=1;
        node_matrix{m}(first{m}(n,2),first{m}(n,1))=1;
    end
end


% nROI=116;
% node_matrix=eye(nROI,nROI);
% for m=1:length(test)
%    
%         node_matrix(test{m}(:,1),test{m}(:,2))=1;
%         node_matrix(test{m}(:,2),test{m}(:,1))=1;
% 
% end


result_features(:,1)=new_out(:,2);
result_features(:,2)=new_out(:,3);
result_features(:,3)=node_matrix';
result_features(:,4)=num2cell(W);
result_features=sortrows(result_features,1,'descend');%% sort according to the frequency of each cluster ,descend
fprintf('End network construction\n');





