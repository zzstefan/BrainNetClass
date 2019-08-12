%% This script is used to generate the Brain Network for user to perform further analysis by themselves.


clear all
addpath(genpath(pwd));
input_folder='./data/'; % this is the directory of the time course data for all subjects, each file for each subject, similar as you prepared for GUI
output_dir='./Generated_BrainNet/'; %this is the output directory;
meth_Net='aHOFC'; %Here you can set the brain network construction method;
%["PC","aHOFC","tHOFC","SR","WSR","SLR","SGR","WSGR","GSR","SSGSR","dHOFC"];
switch meth_Net
    case {'SR','WSR','GSR'}
        lambda=0.01:0.01:0.1; %User can change the parameter range by themselves;
    case {'SLR','SGR','WSGR','SSGSR'}
        lambda_1=0.01:0.01:0.1; %User can change the parameter range by themselves;
        lambda_2=0.01:0.01:0.1;
    case 'dHOFC'
        C=100:100:800;
        W=20:10:70;
        s=1; %step size is usually set to 1 or 2;
    case {'PC','tHOFC','aHOFC'}
        
end




dirOutput=dir(fullfile(input_folder,'*.txt'));
fileName={dirOutput.name}';
%folder={dirOutput.folder}';
for i=1:length(fileName)
    BOLD{i,1}=load([input_folder,'/',fileName{i}]);
end
label=importdata(label_input);

[~,nROI]=size(BOLD{1});
nSubj=length(BOLD);

fprintf('Begin network construction\n');

switch meth_Net
    case 'PC'       % Pearson's correlation
        BrainNet{1}=PC(BOLD);
    case 'tHOFC'    % Topographical high-order FC
        BrainNet{1}=tHOFC(BOLD);
    case 'aHOFC'    % Associated high-order FC
        BrainNet{1}=aHOFC(BOLD);
    case 'SR'       % Sparse representation
        parfor i=1:length(lambda)
            BrainNet{i}=SR(BOLD,lambda(i));
        end
             
    case 'WSR'      % PC weighted SR
        parfor i=1:length(lambda)
            BrainNet{i}=WSR(BOLD,lambda(i));
        end
         
    case 'SLR'      % Sparse low-rank representation
        lambda1=lambda_1;
        lambda2=lambda_2;
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SLR(BOLD,lambda1(i),lambda2(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        
    case 'SGR'      % Sparse group representation
        lambda1=lambda_1;
        lambda2=lambda_2;
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SGR(BOLD,lambda1(i),lambda2(j));
            end
        end
        
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        
    case 'WSGR'     % PC weighted SGR
        lambda1=lambda_1; % parameter for sparsity
        lambda2=lambda_2; % parameter for group sparsity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=WSGR(BOLD,lambda1(i),lambda2(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        
    case 'GSR'      % Group sparse representation
        parfor i=1:length(lambda)
            BrainNet{i}=GSR(BOLD,lambda(i));
        end
        
    case 'SSGSR'    % Strength and Similarity guided GSR
        %lambda1=lambda_1(1:6); % parameter for group sparsity
        lambda1=lambda_1;
        lambda2=lambda_2; % parameter for inter-subject LOFC-pattern similarity
        num_lambda1=length(lambda1);
        num_lambda2=length(lambda2);
        parfor i=1:num_lambda1
            for j=1:num_lambda2
                BrainNet{i,j}=SSGSR(BOLD,lambda1(i),lambda2(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_lambda1*num_lambda2);
        
    case 'dHOFC'    % Dynamic high-order FC
        num_W=length(W);
        num_C=length(C);
        parfor i=1:num_W % number of clusters
            for j=1:num_C
                [BrainNet{i,j},IDX{i,j}]=dHOFC(BOLD,W(i),s,C(j));
            end
        end
        BrainNet=reshape(BrainNet,1,num_W*num_C);
end
save(char(strcat(output_dir,meth_Net,'.mat')),'BrainNet','-v7.3');
% All the generated networks (and those resulted from different parameters) are saved as a cell array, nROIxnROIxnSubject in each cell, different cells for results with different combinations of parameters 
fprintf('Network construction finished\n');
