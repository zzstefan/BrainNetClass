function [centered_data,centroid] = CenterRowData(input)
% each row is a data point

centroid = mean(input);

centered_data = input-(ones(size(input, 1), 1)*centroid);
