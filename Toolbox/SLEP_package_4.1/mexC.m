%
% In this file, we mex the C files used in this package.

clear, clc;
current_path=cd;

%% Output infor
%%
fprintf('\n ----------------------------------------------------------------------------');
fprintf('\n The program is mexing the C files. Please wait...');
fprintf('\n If you have problem with mex, you can refer to the help of Matlab.');
fprintf('\n If you cannot solve the problem, please contact with Jun Liu (j.liu@asu.edu)\n\n');

%% currently, this package uses the following C files 
%%            (in the folder /SLEP/CFiles)


% files in the folder q1
cd([current_path '/SLEP/CFiles/q1']);
mex epp.c;
mex ep1R.c;
mex ep21d.c;
mex ep21R.c;
mex eplb.c;
mex eppMatrix.c;
mex eppVector.c;
mex eppVectorR.c;
mex epsgLasso.c;

% file in the folder flsa
cd([current_path '/SLEP/CFiles/flsa']);
mex flsa.c;

% file in the folder SpInvCoVa
cd([current_path '/SLEP/CFiles/SpInvCoVa']);
mex invCov.c;

% files in the folder tree
cd([current_path '/SLEP/CFiles/tree']);
mex altra.c;
mex altra_mt.c;
mex computeLambda2Max.c;
mex treeNorm.c;
mex findLambdaMax.c;
mex findLambdaMax_mt.c;

mex general_altra.c;
mex general_altra_mt.c;
mex general_treeNorm.c;
mex general_findLambdaMax.c;
mex general_findLambdaMax_mt.c;

% files in the folder order
cd([current_path '/SLEP/CFiles/order']);
mex orderTree.c;
mex orderTree_without_nonnegative.c;
mex orderTreeBinary.c;
mex orderTreeDepth1.c;
mex sequence_bottomup.c;
mex sequence_topdown.c;


%% Output infor
%% 
fprintf('\n\n The C files in the folder CFiles have been successfully mexed.');
fprintf('\n\n You can now use the functions in the folder SLEP.');
fprintf('\n You are suggested to read the manual for better using the codes.');
fprintf('\n You are also suggested to run the examples in the folder Examples for these functions.');
fprintf('\n\n These codes are being developed by Jun Liu and Jieping Ye at Arizona State University.');
fprintf('\n If there is any problem, please contact with Jun Liu and Jieping Ye ({j.liu,jieping.ye}@asu.edu).');
fprintf('\n\n Thanks!');
fprintf('\n ----------------------------------------------------------------------------\n');

cd(current_path);