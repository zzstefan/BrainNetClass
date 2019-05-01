function C=wlcc(W,flag)
%	weighted local clustering coefficient
%
%   C = clustering_coef_wu(W);
%
%   The weighted clustering coefficient is the average "intensity" of
%   triangles around a node.
%
%   Input:      W,      weighted undirected connection matrix
%
%   Output:     C,      clustering coefficient vector
%
%   Reference: Onnela et al. (2005) Phys Rev E 71:065103
%
%
%   Mika Rubinov, UNSW, 2007-2010

if flag == 1
    K=sum(W~=0,2);
    cyc3=diag((W.^(1/3))^3);
    K(cyc3==0)=inf;             %if no 3-cycles exist, make C=0 (via K=inf)
    C=cyc3./(K.*(K-1));         %clustering coefficient
elseif flag == 2
    % Only compute on Positive values
    W1 = W.*(W>0);
    K=sum(W1~=0,2);
    cyc3=diag((W1.^(1/3))^3);
    K(cyc3==0)=inf;             %if no 3-cycles exist, make C=0 (via K=inf)
    C1=cyc3./(K.*(K-1));         %clustering coefficient
    
    C = C1;
elseif flag == 3
    % Compute on Absolute Value
%         W1 = W.*(W>0);
%     K=sum(W1~=0,2);
%     cyc3=diag((W1.^(1/3))^3);
%     K(cyc3==0)=inf;             %if no 3-cycles exist, make C=0 (via K=inf)
%     C1=cyc3./(K.*(K-1));         %clustering coefficient
    
%     W2 = -W.*(W<0);
%     K=sum(W2~=0,2);
%     cyc3=diag((W2.^(1/3))^3);
%     K(cyc3==0)=inf;             %if no 3-cycles exist, make C=0 (via K=inf)
%     C2=cyc3./(K.*(K-1));         %clustering coefficient
%     
    W3 = abs(W);
    K=sum(W3~=0,2);
    cyc3=diag((W3.^(1/3))^3);
    K(cyc3==0)=inf;             %if no 3-cycles exist, make C=0 (via K=inf)
    C3=cyc3./(K.*(K-1));         %clustering coefficient
    
    C = C3;
end