clear, clc;

% This is an example for running the function mcLogisticC
%
%  Problem:
%
%  min  - sum_{il} weight_{il} log( p_{il} ) 
%  sum_j ||x^j||_q <=z
%
%  The current program only implements q=2
%
%  p_{il}= 1 / (1+ exp(-y_i (x_i' * a_i + c_l) ) ) denotes the probability
%  weight_{il} is the weight for the i-th sample in the l-th classifier
%                is a m x k matrix
%  c_l is the intercept for the l-th classfier, and is a 1xk vector
%  x_i denotes the i-th column of x
%  x^j denotes the j-th row of x
%  a_i' denotes the i-th row of A
%
%  In this implementation, we assume weight_{il}=1/(mk)
%
% For detailed description of the function, please refer to the Manual.
%
%% ------------   History --------------------
% First version on August 10, 2009.
%
% September 5, 2009: adaptive line search is added
%
% For any problem, please contact Jun Liu (j.liu@asu.edu)

cd ..
cd ..

root=cd;
addpath(genpath([root '/SLEP']));
                     % add the functions in the folder SLEP to the path
                   
% change to the original folder
cd Examples/L1Lq;

m=100;  n=100;       % The data matrix is of size m x n
k=10;                % the number of classes (tasks)
q=2;                 % the value of q in the L1/Lq regularization
z=50;                % the regularization parameter
randNum=1;           % a random number

% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

randn('state',(randNum-1)*3+2);
y=randn(m, k);
y=2* (y>0) - 1;      % the response

%----------------------- Set optional items -----------------------
opts=[];

% Starting point
opts.init=2;        % starting from a zero point

% Termination 
opts.tFlag=5;       % run .maxIter iterations
opts.maxIter=100;   % maximum number of iterations

% Normalization
opts.nFlag=0;       % without normalization

% Group Property
opts.q=q;           % set the value for q

%----------------------- Run the code mcLogisticC -----------------------
fprintf('\n lFlag=0 \n');
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
tic;
[x1, c1, funVal1, ValueL1]= mcLogisticC(A, y, z, opts);
toc;

opts.maxIter=200;

fprintf('\n lFlag=1 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x2, c2, funVal2, ValueL2]= mcLogisticC(A, y, z, opts);
toc;

figure;
plot(funVal1,'-r');
hold on;
plot(funVal2,'--b');
legend('lFlag=0', 'lFlag=1');
xlabel('Iteration (i)');
ylabel('The objective function value');

% % --------------------- compute the pathwise solutions ----------------
% opts.fName='mcLogisticC';    % set the function name to 'mcLogisticC'
% Z=[0.9, 0.8, 0.5, 0.3];      % set the parameters
% 
% % run the function pathSolutionLogistic
% fprintf('\n Compute the pathwise solutions, please wait...');
% [X, C]=pathSolutionLogistic(A, y, Z, opts);