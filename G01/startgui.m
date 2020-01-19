function varargout = startgui(varargin)

% startgui MATLAB code for startgui.fig
%      startgui, by itself, creates a new startgui or raises the existing
%      singleton*.
%
%      H = startgui returns the handle to a new startgui or the handle to
%      the existing singleton*.
%
%      startgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in startgui.M with the given input arguments.
%
%      startgui('Property','Value',...) creates a new startgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before startgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to startgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help startgui

% Last Modified by GUIDE v2.5 16-Jul-2019 20:59:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @startgui_OpeningFcn, ...
                   'gui_OutputFcn',  @startgui_OutputFcn, ...
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


% --- Executes just before startgui is made visible.
function startgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to startgui (see VARARGIN)

% Choose default command line output for startgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes startgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = startgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global path;
   path= uigetdir;
   path_text  = uicontrol('Style','text','String',path,...
        'Position',[120,600,500,15]);%[25,830,60,30]
   path_text.Units = 'normalized';
   imleft = imread(fullfile(path,'im0.png'));
   imright = imread(fullfile(path,'im1.png'));
   axes1 = findobj(0, 'tag', 'axes1');
   axes(axes1);
   %axes(handles.axes1);
   imshow(imleft);
   %axes(handles.axes2);
   axes2 = findobj(0, 'tag', 'axes2');
   axes(axes2);
   imshow(imright);
%        global h1 h2 h3 h4 h5;
%        pos1= [0.1,0.6,0.3,0.3];
% 
%        h1=subplot('Position', pos1);    %���¾��h1
%        imshow(imleft);
%        pos2= [0.4,0.6,0.3,0.3];
%        
%        h2=subplot('Position', pos2);    %���¾��h2       
%        imshow(imright);
%        path = path_data;
%        h_calc = uicontrol('Style','pushbutton','String','Calculate',...
%        'Position',[25,600,60,30],'Callback',@calcbutton_Callback);
%        h_calc.Units = 'normalized';
    


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    tic;
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global path;
    [D_l, D_r, R, T] = disparity_map(path);
    R=single(R);
    T=single(T);
 if size(D_r,1)>1000
    image_choose=1;
elseif size(D_r,1)<1000 & size(D_r,1)>500
    image_choose=2;
else
    image_choose=3;
end

switch image_choose
    case 1
        color_max = 255;
    case 2
        color_max= 150;
    case 3
        color_max=20;
end
    %axes(handles.axes3);
    axes3 = findobj(0, 'tag', 'axes3');
    axes(axes3);
    imshow(D_l), colormap(gca,jet), colorbar;
    caxis([0 color_max]);
    %axes(handles.axes4);
    axes4 = findobj(0, 'tag', 'axes4');
    axes(axes4);
    imshow(D_r), colormap(gca,jet), colorbar;
    caxis([0 color_max]);

    %axes(handles.axes5);
    axes8 = findobj(0, 'tag', 'axes8');
    axes(axes8);
    calib_path=[path,'/calib.txt'];
    [cam0, cam1, doffs, baseline, width, height, ndisp] = read_calib(calib_path);
    [image, A] = threedreconstruction(cam0,baseline,doffs,D_l,path);
     ptCloud = pointCloud(A,'Color',double(image)/255);
     pcshow(ptCloud,'VerticalAxis','y','VerticalAxisDir','down');
    gt_path = fullfile(path,'disp0.pfm');
%     % Load the ground truth
    G = pfmread(gt_path);
%      % Estimate the quality of the calculated disparity map
%      % G=imresize(G,0.25);
    p = verify_dmap(D_l, G);
    assignin('base','R',single(R));
    assignin('base','T',single(T));
    assignin('base','p',p);
    assignin('base','D_l',D_l);
    assignin('base','G',G);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    p_str = num2str(p);
    p_text  = uicontrol('Style','text','String',p_str,...
      'Position',[555,95,30,15]);
    p_text.Units = 'normalized';
    R_text  = uitable('Data', roundn(R,-5),...
     'Position',[125,55,220,80]);%%%%
    R_text.Units = 'normalized';
    T_text  = uitable('Data', roundn(T,-5),...
      'Position',[405,55,100,80]);
    T_text.Units = 'normalized'; 
    e_time = toc;
    e_str = num2str(e_time);
    e_text  = uicontrol('Style','text','String',e_str,...
      'Position',[47,95,30,15]);
    e_text.Units = 'normalized';
    s_text  = uicontrol('Style','text','String','s',...
      'Position',[80,95,10,15]);
    s_text.Units = 'normalized';

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
res = runtests('test');
        %result = table(res);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.


% --- Executes during object creation, after setting all properties.


% --- Executes during object creation, after setting all properties.
