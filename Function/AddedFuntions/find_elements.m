%% find elements;
%% when we stretch the upper triangle matrix of a matrix into a vector, we want to know
%% the element represent the relationship between which two elements in the original matrix.
function [first,second]=find_elements(nROI,test)
% test=6670;
% nROI=116;
Index=1:nROI-1;
new_index=flipud(Index')';

i=1;
all=0;
while 1
    all=sum(new_index(1:i));
    %i=i+1;
    if all>=test
        break
    end
    i=i+1;
end

tmp=test-sum(new_index(1:i-1));
first=i;
M=i+1:116;
second=M(tmp);