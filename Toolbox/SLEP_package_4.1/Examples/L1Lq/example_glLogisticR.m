clear, clc;

% This is an example for running the function glLogisticR
%
%  Problem:
%
%  min  f(x,c) = - weight_i * log (p_i) + rho * sum_j ||x^j||_q
%
%  a_i denotes a training sample,
%      and a_i' corresponds to the i-th row of the data matrix A
%
%  y_i (either 1 or -1) is the response
%     
%  p_i= 1/ (1+ exp(-y_i (x' * a_i + c) ) ) denotes the probability
%
%  weight_i denotes the weight for the i-th sample
%
%  x is grouped into k groups according to opts.ind.
%      The indices of x_j in x is (ind(j)+1):ind(j+1).
%
% For detailed description of the function, please refer to the Manual.
%
% Last modified on August 10, 2009.
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/L1Lq;

m=1000;  n=1000;     % The data matrix is of size m x n

ind=[0 100:100:n];   % the indices for the groups
k=length(ind)-1;     % number of groups
q=2;                 % the value of q in the L1/Lq regularization
rho=0.8;             % the regularization parameter

randNum=1;           % a random number

% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);         % the data matrix

randn('state',(randNum-1)*3+2);
xOrin=randn(n,1);

randn('state',(randNum-1)*3+3);
y=[ones(n/2,1);...
    -ones(n/2, 1)];  % the response

%----------------------- Set optional items -----------------------
opts=[];

% Starting point
opts.init=2;        % starting from a zero point

% Termination 
opts.tFlag=5;       % run .maxIter iterations
opts.maxIter=100;   % maximum number of iterations

% Normalization
opts.nFlag=0;       % without normalization

% Regularization
opts.rFlag=1;       % the input parameter 'rho' is a ratio in (0, 1)

% Group Property
opts.ind=ind;       % set the group indices
opts.q=q;           % set the value for q
opts.sWeight=[1,1]; % set the weight for positive and negative samples
opts.gWeight=ones(k,1);
                   % set the weight for the group, a cloumn vector

%----------------------- Run the code glLogisticR -----------------------
fprintf('\n mFlag=0, lFlag=0 \n');
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
tic;
[x1, c1, funVal1, ValueL1]= glLogisticR(A, y, rho, opts);
toc;

opts.maxIter=1000;

fprintf('\n mFlag=1, lFlag=0 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x2, c2, funVal2, ValueL2]= glLogisticR(A, y, rho, opts);
toc;

fprintf('\n mFlag=1, lFlag=1 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x3, c3, funVal3, ValueL3]= glLogisticR(A, y, rho, opts);
toc;

figure;
plot(funVal1,'-r');
hold on;
plot(funVal2,'--b');
hold on;
plot(funVal3,':g');
legend('mFlag=0, lFlag=0', 'mFlag=1, lFlag=0', 'mFlag=1, lFlag=1');
xlabel('Iteration (i)');
ylabel('The objective function value');

% % --------------------- compute the pathwise solutions ----------------
% opts.fName='glLogisticR';    % set the function name to 'glLogisticR'
% Z=[0.9, 0.8, 0.5, 0.3];      % set the parameters
% 
% % run the function pathSolutionLogistic
% fprintf('\n Compute the pathwise solutions, please wait...');
% [X,C]=pathSolutionLogistic(A, y, Z, opts);