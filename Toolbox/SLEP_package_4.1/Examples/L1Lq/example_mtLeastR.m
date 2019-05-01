clear, clc;

% This is an example for running the function mtLeastR
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

m=1000;  n=100;     % the size of the data matrix
k=10;               % 10 tasks
ind=0:100:1000;     % the 1000 samples are from 10 tasks
randNum=1;          % a random number
q=2;                % the value of q in the L1/Lq regularization
rho=0.5;            % the regularization parameter

% ---------------------- generate random data ----------------------
randn('state',(randNum-1)*3+1);
A=randn(m,n);        % the data matrix

randn('state',(randNum-1)*3+2);
xOrin=randn(n,k);

randn('state',(randNum-1)*3+3);
noise=randn(m,1);

for i=1:k
    ind_i=(ind(i)+1):ind(i+1);
    y(ind_i,1)=A(ind_i,:)*xOrin(:,i)+...
        noise(ind_i,1)*0.01;  
                     % the response
end

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
opts.ind=ind;       % set the group indices

%----------------------- Run the code mtLeastR -----------------------
fprintf('\n mFlag=0, lFlag=0 \n');
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
tic;
[x1, funVal1, ValueL1]= mtLeastR(A, y, rho, opts);
toc;

opts.maxIter=200;

fprintf('\n mFlag=1, lFlag=0 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x2, funVal2, ValueL2]= mtLeastR(A, y, rho, opts);
toc;

fprintf('\n mFlag=1, lFlag=1 \n');
opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
opts.tFlag=2; opts.tol= funVal1(end);
tic;
[x3, funVal3, ValueL3]= mtLeastR(A, y, rho, opts);
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
% opts.fName='mtLeastR';    % set the function name to 'mtLeastR'
% Z=[0.9, 0.8, 0.5, 0.3];   % set the parameters
% 
% % run the function pathSolutionLeast
% fprintf('\n Compute the pathwise solutions, please wait...');
% X=pathSolutionLeast(A, y, Z, opts);