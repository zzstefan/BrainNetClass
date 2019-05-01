clear, clc;

% This is an example for running the function mcLeastR
%
%  Problem:
%
%  min  1/2 || A x - y||^2 + rho * sum_j ||x^j||_q
%
%  x is grouped into k groups according to opts.ind
%  The indices of x_j in x is (ind(j)+1):ind(j+1)
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
rho=0.5;             % the regularization parameter
randNum=1;           % a random number

% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

randn('state',(randNum-1)*3+2);
xOrin=randn(n,k);

randn('state',(randNum-1)*3+3);
noise=randn(m,k);
y=A*xOrin +...
    noise*0.01;      % the response

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
opts.q=q;           % set the value for q

%----------------------- Run the code mcLeastR -----------------------
fprintf('\n mFlag=0, lFlag=0 \n');
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
tic;
[x1, funVal1, ValueL1]= mcLeastR(A, y, rho, opts);
toc;

opts.maxIter=200;

fprintf('\n mFlag=1, lFlag=0 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x2, funVal2, ValueL2]= mcLeastR(A, y, rho, opts);
toc;

fprintf('\n mFlag=1, lFlag=1 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x3, funVal3, ValueL3]= mcLeastR(A, y, rho, opts);
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

fprintf('\n mFlag=0, lFlag=0 \n');
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
tic;
[x1, funVal1, ValueL1]= mcLeastR(A, y, rho, opts);
toc;

% % --------------------- compute the pathwise solutions ----------------
% opts.fName='mcLeastR';    % set the function name to 'mcLeastR'
% Z=[0.9, 0.8, 0.5, 0.3];   % set the parameters
% 
% % run the function pathSolutionLeast
% fprintf('\n Compute the pathwise solutions, please wait...');
% X=pathSolutionLeast(A, y, Z, opts);