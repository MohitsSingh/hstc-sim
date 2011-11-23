function varargout = GUI(varargin)
% GUI M-file for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 14-Nov-2011 21:20:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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

% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

guiAxes = handles.axes1;

axis normal;
xlim([0 50]);

set(guiAxes, 'YDir', 'reverse');
%     set(gca,'GridLineStyle','-')
%     set(gca, 'YMinorGrid', 'on');
set(guiAxes, 'YGrid', 'on');
set(guiAxes, 'XTick', 0:10:50);
set(guiAxes, 'XTickLabelMode', 'auto');
set(guiAxes, 'CameraPositionMode', 'auto');
set(guiAxes, 'CameraTargetMode', 'auto');

set(handles.UpdateButton, 'String', 'Quit (for now)');

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI.
if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
%     c=imread('road.bmp');
%     imagesc(imrotate(c, 90));
    
end

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in UpdateButton.
function UpdateButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    disp('Update clicked... Closing for now');
    close(handles.figure1);



% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

function updateGUI()
    guiHandle = GUI;
    gh = guihandles(guiHandle);
    guiAxes = gh.axes1;
%     get(guiAxes)

    vm = getappdata(guiHandle, 'vm');
    vehicles = vm.allVehicles;
      
    hold off
    cla
    
    xlim([0 50]);
    ylim([-1 (vm.lanes+2)]);
    
    set(guiAxes, 'YTick', -1:(vm.lanes+2));
    set(guiAxes, 'YTickLabel', -1:(vm.lanes+2));
    
    hold on;
    
    for i=1:length(vehicles)
        v = vehicles(i);
        r = rectangle('Position',[v.posY v.lane 1 1]);
        
        if v.wantsCaravan == 1
            set(r, 'FaceColor','b');
        else
            set(r,'FaceColor','y');
        end
        
    end
    
%     c=imread('road.bmp');
%     imagesc(imrotate(c, 90));


% --- Executes on button press in scrollLeft.
function scrollLeft_Callback(hObject, eventdata, handles)
% hObject    handle to scrollLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in scrollRight.
function scrollRight_Callback(hObject, eventdata, handles)
% hObject    handle to scrollRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('I''ll do something eventually!')
