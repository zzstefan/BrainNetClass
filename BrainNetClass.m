function varargout = BrainNetClass(varargin)
% TEST MATLAB code for test.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 07-Feb-2019 16:52:00

% Begin initialization code - DO NOT EDIT
% testcodefdfds
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainNetClass_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainNetClass_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before test is made visible.
function BrainNetClass_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)

% Choose default command line output for test
handles.output = hObject;

axes(handles.axes_logo);
axis image;
[A, map, alpha] = imread('./Pics/logo.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

axes(handles.axes_arrow2);
axis image;
[A, map, alpha] = imread('./Pics/arrow_down.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

axes(handles.axes6);
axis image;
[A, map, alpha] = imread('./Pics/arrow_left.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

axes(handles.axes7);
axis image;
[A, map, alpha] = imread('./Pics/arrow_down.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

axes(handles.axes8);
axis image;
[A, map, alpha] = imread('./Pics/arrow_down2.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

axes(handles.axes9);
axis image;
[A, map, alpha] = imread('./Pics/arrow_down2.png');
h = imshow(A, map);
set(h, 'AlphaData', alpha);

set(handles.lambda1,'Enable','off');
set(handles.lambda2,'Enable','off');
set(handles.clusters,'Enable','off');
%set(handles.step,'Enable','off');
set(handles.window_length,'Enable','off');
%set(handles.lasso_lambda,'Enable','off');
set(handles.sensitivity_test,'Enable','off');

handles.default.lambda_1=[0.01:0.01:0.1];
handles.default.lambda_2=[0.01:0.01:0.1];
handles.default.clusters=[100:100:800];
handles.default.window_length=[50:10:120];
handles.default.k_times=10;

% User can change the value of lasso_lambda and step 
handles.default.lasso_lambda=0.1;
handles.default.step=1;


set(handles.k_times,'String',mat2str(handles.default.k_times));
set(handles.test_radio,'Value',1);%set the initial radiobutton being selected

% axes(handles.axes_arrow1);
% arrow_p1=[0.5 1];
% arrow_p2=[0 -1];
% h=annotation('textarrow');
% set(h,'parent','postition',[arrow_p1 arrow_p2]);

% axes(handles.axes_arrow1);
% h_arrow_axis=annotation('textarrow');
% set(h_arrow_axis,'parent',gca,'position',[0.5 1],[0 -1]);

%uicontrol('Style','text','String',sprintf('Set \x3a9'),'units','characters','Position',[62.142857142857140,25.588235294117645,9.714285714285708,1.058823529411765]);

% handles.laxis = axes('parent',hObject,'units','normalized','position',[0 0 1 1],'visible','off');
% Find all static text UICONTROLS whose 'Tag' starts with latex_
%lbls = findobj(hObject,'-regexp','tag','latex_*');
% for i=1:length(lbls)
%       l = lbls(i);
%       % Get current text, position and tag
%       set(l,'units','normalized');
%       s = get(l,'string');
%       p = get(l,'position');
%       t = get(l,'tag');
%       % Remove the UICONTROL
%       delete(l);
%       % Replace it with a TEXT object 
%       %handles.(t) = text(p(1),p(2),s,'interpreter','latex');
%       handles.(t) = text('position',p,'interpreter','latex','string','$\lambda$');
% end
lbls=findobj(hObject,'-regexp','tag','lambda_1');
p=get(lbls,'position');
uicontrol('Style','text','Fontname','Calibri','FontSize',10,'String',sprintf('\x3bb_1'),'units','characters','Position',p);

lbls=findobj(hObject,'-regexp','tag','lambda_2');
p=get(lbls,'position');
uicontrol('Style','text','Fontname','Calibri','FontSize',10,'String',sprintf('\x3bb_2'),'units','characters','Position',p);

% lbls=findobj(hObject,'-regexp','tag','lambda_lasso');
% p=get(lbls,'position');
% uicontrol('Style','text','Fontname','Calibri','String',sprintf('    \x3bb lasso for \n feature selection'),'units','characters','Position',p);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BrainNetClass_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% p=[62.142857142857140,25.588235294117645,9.714285714285708,1.058823529411765];
% uicontrol('Style','text','String',sprintf('Set '),'Units','norm','Position',p);
% --- Executes on selection change in net_method.
function net_method_Callback(hObject, eventdata, handles)
% hObject    handle to net_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns net_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from net_method
% contents_net=cellstr(get(hObject,'String'));
% pop_choice_net=contents_net{get(hObject,'Value')};
popStrings_net = cellstr(get(hObject,'String')); 
meth_Net=popStrings_net{get(hObject,'Value')};
handles.meth_Net=meth_Net;
guidata(hObject,handles);
if strcmpi(meth_Net,'Network Construction Method')
    reset_para(handles);
end

set(handles.lambda1,'Enable','off');
set(handles.lambda2,'Enable','off');
%set(handles.lasso_lambda,'Enable','off');
set(handles.clusters,'Enable','off');
set(handles.window_length,'Enable','off');
%set(handles.step,'Enable','off');
set(handles.sensitivity_test,'Enable','off');


% --- Executes during object creation, after setting all properties.
function net_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to net_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fs_method.
function fe_method_Callback(hObject, eventdata, handles)
% hObject    handle to fs_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fs_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fs_method
contents_fe=cellstr(get(hObject,'String'));
pop_choice_fe=contents_fe{get(hObject,'Value')};
switch pop_choice_fe
    case 'Feature Extraction Method'
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','string',sprintf(''));
    case 'connection-based coefficients'
        tmp='coef';
        %handles.fe_method=tmp;
        handles.fe_display=pop_choice_fe;
        handles.pop_choice_fe=tmp;
        guidata(hObject,handles);
    case 'weighted-graph local clustering coefficients'
        tmp='clus';
        %handles.fe_method=tmp;
        handles.fe_display=pop_choice_fe;
        handles.pop_choice_fe=tmp;
        guidata(hObject,handles);
end


if isfield(handles,'meth_Net')&& isfield(handles,'fe_method')&&~strcmpi(pop_choice_fe,'Feature Extraction Method')
    set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('%s as features',handles.fe_display));
end

% --- Executes during object creation, after setting all properties.
function fe_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fs_method.
function fs_method_Callback(hObject, eventdata, handles)
% hObject    handle to fs_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fs_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fs_method
contents_fs=cellstr(get(hObject,'String'));
pop_choice_fs=contents_fs{get(hObject,'Value')};
handles.pop_choice_fs=pop_choice_fs;
guidata(hObject,handles);
if strcmpi(pop_choice_fs,'Feature Selection Method')
    set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','string',sprintf(''));

elseif isfield(handles,'meth_Net')&& isfield(handles,'fe_method')&&isfield(handles,'fs_method')
    set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',...
        sprintf('%s as features \n%s for feature selection',handles.fe_display,pop_choice_fs));
end

% --- Executes during object creation, after setting all properties.
function fs_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in net_method_2.
function net_method_2_Callback(hObject, eventdata, handles)
% hObject    handle to net_method_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns net_method_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from net_method_2
% popStrings_net_2 = handles.net_method_2.String; 
% selectedIndex_net_2 = handles.net_method_2.Value;
% meth_Net_2 = popStrings_net_2{selectedIndex_net_2};
contents=cellstr(get(hObject,'String'));
meth_Net_2=contents{get(hObject,'Value')};
handles.meth_Net_2=meth_Net_2;
guidata(hObject,handles);
switch meth_Net_2 
    case 'Network Construction Method'
        reset_para(handles);
    case {'SR','WSR'}
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('\x3bb controlling sparsity'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('connection-based coefficients as features \nt-test (p<0.05) + LASSO for feature selection'));
    case 'GSR'
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('\x3bb controlling group sparsity'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('connection-based coefficients as features \nt-test (p<0.05) + LASSO for feature selection'));
    case 'SLR'
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('\x3bb_1 controlling low_rank \n\x3bb_2 controlling sparsity'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('connection-based coefficients as features \nt-test (p<0.05) + LASSO for feature selection'));
    case {'SGR','WSGR'}
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',...
            sprintf('\x3bb_1 controlling sparsity \n\x3bb_2 controlling group sparsity'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('connection-based coefficients as features \nt-test (p<0.05) + LASSO for feature selection'));
    case 'SSGSR'
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',...
            sprintf('\x3bb_1 controlling group sparsity \n\x3bb_2 controlling inter-subject LOFC-pattern similarity'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('connection-based coefficients as features \nt-test (p<0.05) + LASSO for feature selection'));
    case 'dHOFC'
        set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('step normally set to 1'));
        set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','ForegroundColor',[0.3 0.75 0.93],'string',sprintf('weighted-graph local clustering coefficients as features \nLASSO for feature selection'));
end

if strcmp(meth_Net_2,'SR')||strcmp(meth_Net_2,'WSR')||strcmp(meth_Net_2,'GSR')
    set(handles.lambda2,'Enable','off');
    set(handles.window_length,'Enable','off');
    %set(handles.step,'Enable','off');
    set(handles.clusters,'Enable','off');
    set(handles.lambda1,'Enable','on','String',mat2str(handles.default.lambda_1));
    %set(handles.lasso_lambda,'Enable','on','String',num2str(handles.default.lasso_lambda));
    set(handles.sensitivity_test,'Enable','on');
    %set(handles.sensitivity_test,'ForegroundColor','k');
elseif strcmp(meth_Net_2,'SLR')||strcmp(meth_Net_2,'SGR')||strcmp(meth_Net_2,'WSGR')||strcmp(meth_Net_2,'SSGSR')
    set(handles.window_length,'Enable','off');
    %set(handles.step,'Enable','off');
    set(handles.clusters,'Enable','off');
    set(handles.lambda1,'Enable','on','String',mat2str(handles.default.lambda_1));
    %set(handles.lasso_lambda,'Enable','on','String',num2str(handles.default.lasso_lambda));
    set(handles.lambda2,'Enable','on','String',mat2str(handles.default.lambda_1));
    set(handles.sensitivity_test,'Enable','on');
    %set(handles.sensitivity_test,'ForegroundColor','k');
elseif strcmp(meth_Net_2,'dHOFC')
    set(handles.lambda1,'Enable','off');
    set(handles.lambda2,'Enable','off');
    %set(handles.lasso_lambda,'Enable','on','String',num2str(handles.default.lasso_lambda));
    set(handles.clusters,'Enable','on','String',mat2str(handles.default.clusters));
    set(handles.window_length,'Enable','on','String',mat2str(handles.default.window_length));
    %set(handles.step,'Enable','on','String',num2str(handles.default.step));
    set(handles.sensitivity_test,'Enable','on');
    %set(handles.sensitivity_test,'ForegroundColor','k');
end

switch meth_Net_2
    case{'SR','WSR','SLR','SGR','WSGR','GSR','SSGSR'}
        set(handles.fs_method,'Value',4);
        set(handles.fe_method,'Value',2);
        set(handles.fe_method,'Enable','off');
        set(handles.fs_method,'Enable','off');
    case 'dHOFC'
        set(handles.fs_method,'Value',3);
        set(handles.fe_method,'Value',3);
        set(handles.fe_method,'Enable','off');
        set(handles.fs_method,'Enable','off');
end


% --- Executes during object creation, after setting all properties.
function net_method_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to net_method_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_withparam.
function run_withparam_Callback(hObject, eventdata, handles)
% hObject    handle to run_withparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if handles
BOLD=handles.BOLD;
label=handles.label;
result_dir=handles.result_dir;
if handles.sensitivity_test.Value==1
    para_test_flag=1;
else
    para_test_flag=0;
end

if isfield(handles,'meth_Net')
    meth_Net=handles.meth_Net;
    meth_FEX=handles.pop_choice_fe;
    meth_FS=handles.pop_choice_fs;
    if strcmpi(handles.cross_val,'loocv')
        [AUC,SEN,SPE,F1,Acc]=demo_framwk(result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label);
    elseif strcmpi(handles.cross_val,'10-fold')
        [AUC,SEN,SPE,F1,Acc]=demo_framwk_kfold(handles.default.k_times,result_dir,meth_Net,meth_FEX,meth_FS,BOLD,label);
    end
    write_log(result_dir,meth_Net,handles.cross_val,AUC,SEN,SPE,F1,Acc,meth_FEX,meth_FS,handles.default.k_times);
else
    meth_Net_2=handles.meth_Net_2;
    if strcmpi(handles.cross_val,'loocv')
        switch meth_Net_2
            case {'SR','WSR','GSR'}
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=param_select(result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.lambda_1,handles.default.lasso_lambda);
            case {'SLR','SGR','WSGR','SSGSR'}
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=param_select(result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.lambda_1,handles.default.lambda_2,handles.default.lasso_lambda);
            case 'dHOFC'
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=param_select(result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.window_length,handles.default.step,handles.default.clusters,handles.default.lasso_lambda);
        end
    elseif strcmpi(handles.cross_val,'10-fold')
        switch meth_Net_2
            case {'SR','WSR','GSR'}
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=kfold_param_select(handles.default.k_times,result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.lambda_1,handles.default.lasso_lambda);
            case {'SLR','SGR','WSGR','SSGSR'}
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=kfold_param_select(handles.default.k_times,result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.lambda_1,handles.default.lambda_2,handles.default.lasso_lambda);
            case 'dHOFC'
                [opt_paramt,opt_t,AUC,SEN,SPE,F1,Acc]=kfold_param_select(handles.default.k_times,result_dir,meth_Net_2,BOLD,label,para_test_flag,handles.default.window_length,handles.default.step,handles.default.clusters,handles.default.lasso_lambda);
        end
    end
    switch meth_Net_2
        case {'SR','WSR','GSR'}
            write_log(result_dir,meth_Net_2,handles.cross_val,AUC,SEN,SPE,F1,Acc,handles.default.lambda_1,handles.default.lasso_lambda,opt_paramt,handles.default.k_times,opt_t);
        case {'SGR','WSGR','SSGSR','SLR'}
            write_log(result_dir,meth_Net_2,handles.cross_val,AUC,SEN,SPE,F1,Acc,handles.default.lambda_1,handles.default.lambda_2,handles.default.lasso_lambda,opt_paramt,handles.default.k_times,opt_t);
        case 'dHOFC'
            write_log(result_dir,meth_Net_2,handles.cross_val,AUC,SEN,SPE,F1,Acc,handles.default.window_length,handles.default.step,handles.default.clusters,handles.default.lasso_lambda,opt_paramt,handles.default.k_times,opt_t);
    end
    set(handles.parameter,'string',opt_paramt);
end

set(handles.Result_details,'HorizontalAlignment','left','Fontname','Calibri','FontSize',10,...
    'string',sprintf('Testing set AUC: %0.4g\nTesting set ACC: %3.2f%%\nTesting set SEN: %3.2f%%\nTesting set SPE: %3.2f%%\nTesting set F-score: %3.2f%%',AUC,Acc,SEN,SPE,F1));

% --- Executes on button press in select_dir.

function select_dir_Callback(hObject, eventdata, handles)
% hObject    handle to select_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folderName = uigetdir();
set(handles.data_dir,'string',folderName);

% file_extension=any(size(dir([folderName '/*.mat']),1));
% if file_extension==1
%     dirOutput=dir(fullfile(folderName,'*.mat'));
% else
%     dirOutput=dir(fullfile(folderName,'*.txt'));
% end
% fileName={dirOutput.name}';
% folder={dirOutput.folder}';
% [cs,index]=sort_nat(fileName);
% for i=1:length(fileName)
%     load([folder{i},'/',fileName{index(i)}]);
%     BOLD{i}=Signals;
% end
% handles.file_extension=file_extension;


dirOutput=dir(fullfile(folderName,'*.txt'));
fileName={dirOutput.name}';
folder={dirOutput.folder}';
for i=1:length(fileName)
    BOLD{i,1}=load([folder{i},'/',fileName{i}]);
end

handles.BOLD=BOLD;
guidata(hObject,handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over parameter.
function parameter_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function data_dir_Callback(hObject, eventdata, handles)
% hObject    handle to data_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_dir as text
%        str2double(get(hObject,'String')) returns contents of data_dir as a double


% --- Executes during object creation, after setting all properties.
function data_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function label_file_Callback(hObject, eventdata, handles)
% hObject    handle to label_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of label_file as text
%        str2double(get(hObject,'String')) returns contents of label_file as a double


% --- Executes during object creation, after setting all properties.
function label_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_label.
function select_label_Callback(hObject, eventdata, handles)
% hObject    handle to select_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if handles.file_extension ==1
%     label_fileName=uigetfile('.mat','please select the label file');
% else 
%     label_fileName=uigetfile('.txt','please select the label file');
% end

label_fileName=uigetfile('.txt','please select the label file');

label=importdata(label_fileName);
set(handles.label_file,'string',label_fileName);

handles.label=label;
guidata(hObject,handles);



function lambda1_Callback(hObject, eventdata, handles)
% hObject    handle to lambda1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda1 as text
%        str2double(get(hObject,'String')) returns contents of lambda1 as a double

% lambda_1=get(hObject,'String');
% temp=strsplit(lambda_1,' ');
% lambda_1=str2double(temp);
% handles.lambda_1=lambda_1;
% guidata(hObject,handles);
lambda_1=get(hObject,'String');
handles.default.lambda_1=eval(['[',lambda_1,']']);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function lambda1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lambda2_Callback(hObject, eventdata, handles)
% hObject    handle to lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda2 as text
%        str2double(get(hObject,'String')) returns contents of lambda2 as a double
% lambda_2=get(hObject,'String');
% temp=strsplit(lambda_2,' ');
% lambda_2=str2double(temp);
% handles.lambda_2=lambda_2;
% guidata(hObject,handles);

lambda_2=get(hObject,'String');
handles.default.lambda_2=eval(['[',lambda_2,']']);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function lambda2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function window_length_Callback(hObject, eventdata, handles)
% hObject    handle to window_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_length as text
%        str2double(get(hObject,'String')) returns contents of window_length as a double
% window_length=get(hObject,'String');
% temp=strsplit(window_length,' ');
% window_length=str2double(temp);
% handles.window_length=window_length;
% guidata(hObject,handles);

window_length=get(hObject,'String');
handles.default.window_length=eval(['[',window_length,']']);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function window_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function clusters_Callback(hObject, eventdata, handles)
% hObject    handle to clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusters as text
%        str2double(get(hObject,'String')) returns contents of clusters as a double
% clusters=get(hObject,'String');
% temp=strsplit(clusters,' ');
% clusters=str2double(temp);
% handles.clusters=clusters;
% guidata(hObject,handles);

clusters=get(hObject,'String');
handles.default.clusters=eval(['[',clusters,']']);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function clusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function lasso_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lasso_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function run_withparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run_withparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function select_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function lambda_1_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to lambda_1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in loocv.
function loocv_Callback(hObject, eventdata, handles)
% hObject    handle to loocv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loocv

% --- Executes on button press in k_fold.
function k_fold_Callback(hObject, eventdata, handles)
% hObject    handle to k_fold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of k_fold


% --- Executes on button press in sensitivity_test.
function sensitivity_test_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sensitivity_test

function output_dir_Callback(hObject, eventdata, handles)
% hObject    handle to output_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_dir as text
%        str2double(get(hObject,'String')) returns contents of output_dir as a double


% --- Executes during object creation, after setting all properties.
function output_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_outdir.
function select_outdir_Callback(hObject, eventdata, handles)
% hObject    handle to select_outdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folderName = uigetdir();
handles.result_dir=folderName;
set(handles.output_dir,'string',folderName);
guidata(hObject,handles);


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(get(eventdata.NewValue,'Tag'))
    case 'loocv'
        handles.cross_val=get(handles.loocv,'string');   
    case 'k_fold'
        handles.cross_val=get(handles.k_fold,'string');        
end
guidata(hObject,handles);



function k_times_Callback(hObject, eventdata, handles)
% hObject    handle to k_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k_times as text
%        str2double(get(hObject,'String')) returns contents of k_times as a double
k=get(hObject,'String');
handles.default.k_times=eval(['[',k,']']);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function k_times_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k_times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reset_para(handles)
    set(handles.window_length,'Enable','off');
    %set(handles.step,'Enable','off');
    set(handles.clusters,'Enable','off');
    set(handles.lambda1,'Enable','off');
    %set(handles.lasso_lambda,'Enable','off');
    set(handles.lambda2,'Enable','off');
    set(handles.sensitivity_test,'Enable','off');
    set(handles.lambda_details,'HorizontalAlignment','left','Fontname','Calibri','string',sprintf(''));
    set(handles.fe_fs_details,'HorizontalAlignment','left','Fontname','Calibri','string',sprintf(''));
    set(handles.fe_method,'Enable','on');
    set(handles.fs_method,'Enable','on');
    set(handles.fe_method,'Value',1);
    set(handles.fs_method,'Value',1);
    clear handles.meth_Net;
    clear handles.meth_Net_2;
    
