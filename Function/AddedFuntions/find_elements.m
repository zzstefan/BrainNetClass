function [first,second]=find_elements(nROI,connection_index)
% when we stretch the upper triangle matrix of a matrix into a vector, we want to know
% the element represent the relationship between which two elements in the original matrix.
% Input:
%      nROI: number of ROIs;
%      connection_index: the index of the node in the stretched matrix;
% Output:
%      first,second: the index of the connected two nodes.
%       

Index=1:nROI-1;
new_index=flipud(Index')';

i=1;
all=0;
while 1
    all=sum(new_index(1:i));
    %i=i+1;
    if all>=connection_index
        break
    end
    i=i+1;
end

tmp=connection_index-sum(new_index(1:i-1));
first=i;
M=i+1:nROI;
second=M(tmp);
