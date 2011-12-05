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

% Last Modified by GUIDE v2.5 03-Dec-2011 23:45:18

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

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI.
if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
%     c=imread('road.bmp');
%     imagesc(imrotate(c, 90));
    axis normal;
    xlim([0 10]);

    xlabel('Miles');
    ylabel('Lane');

    % Modify default starting view values
    set(handles.edit1,'String','.05');  %step
	set(handles.edit2,'String','.25');    %range
    
    %     set(gca,'GridLineStyle','-')
    %     set(gca, 'YMinorGrid', 'on');
%     set(guiAxes, 'YGrid', 'on');
%     set(guiAxes, 'XTick', 0:10:50);
%     set(guiAxes, 'YMinorGrid', 'on');
    set(guiAxes, 'XTickMode', 'auto');
    set(guiAxes, 'XTickLabelMode', 'auto');
    set(guiAxes, 'YTickLabelMode', 'auto');
    set(guiAxes, 'CameraPositionMode', 'auto');
    set(guiAxes, 'CameraTargetMode', 'auto');

%     set(handles.UpdateButton, 'String', 'Quit (for now)');
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
    global SimulationSetup
    
    SimulationSetup.End = true;
%     disp('Update clicked... Closing for now');
%     close(handles.figure1);


function updateGUI()
    global guiHandle
%     guiHandle = GUI
    figure(guiHandle);
    gh = guihandles(guiHandle);
    guiAxes = gh.axes1;
    
    step = str2double(get(gh.edit1,'String'));
    range = str2double(get(gh.edit2,'String'));

    vm = getappdata(guiHandle, 'vm');
    vehicles = vm.currentVehicles;
      
    cla;
    
    xl=xlim;
    xlim([xl(1) xl(1)+range]);
    ylim([0 (vm.lanes+1)]);   
    xl=xlim;
    yl=ylim;
    height=yl(2)-yl(1);
    
    set(guiAxes, 'Visible', 'off');
    
    set(guiAxes, 'YTick', -1:(vm.lanes+2));
    set(guiAxes, 'YTickLabel', {'', '', 1:vm.lanes-1, 'HSTC', ''});
    set(guiAxes, 'XTick', xl(1):step:xl(2));
    
    hold on;
    
    % Plot grass
    r = rectangle('Position',[0 0 1000 height]);
    set(r, 'FaceColor', 'green');
    
    % Plot asphalt
    r = rectangle('Position',[0 .5 1000 vm.lanes]);
    set(r, 'FaceColor','black');
    
    % Plot lane markers
    for i=.5:vm.lanes+2-.5
        l=line([0 1000],[i i]);
        set(l, 'Color', 'white');
        set(l, 'LineStyle', '--');
    end
    
    % Handle focus stuff
    focusCheckbox = gh.focusCheckbox;
    focusSelector = gh.focusSelector;
    
    if get(focusCheckbox, 'Value')
       focusId = get(focusSelector, 'Value');
       centerFocus = step*round(vm.currentVehicles(focusId).posY/step);
       diff = mod(range/2, step);
       xlim([centerFocus-range/2+diff centerFocus+range/2+diff]);
       xl=xlim;
       set(guiAxes, 'XTick', xl(1):step:xl(2));
    end
    
    % Compile stats
    numInCaravan = sum([vehicles.caravanNumber] > 0);
    numToJoin = sum([vehicles.wantsCaravan]);
    numJoining = sum([vehicles.joiningCaravan]);
    numNotInCaravan = sum([vehicles.caravanNumber] <= 0);
    avgVelocity = mean([vehicles.velocity]);
    avgEconomy = mean([vehicles.fuelEconomy]);
    
    % Plot rectangles and compile statistics for vehicles
    for i=1:length(vehicles)
        v = vehicles(i);
        
        % Only draw if we're currently in view
        if (xl(1) <= v.posY <= xl(2))
            r = rectangle('Position',[v.posY v.lane-.05 v.length .1], ...
                'Curvature',[0 0]);

            % todo: add more options
            if v.wantsCaravan
                set(r, 'FaceColor','blue');
            elseif v.caravanNumber > 0 % In caravan
                set(r, 'FaceColor','green');
            else
                set(r,'FaceColor',[1 0.5 0.2]); % orange
            end
        end
    end
    
    set(gh.numberValues,'String',[numInCaravan; numToJoin; ...
        numJoining; numNotInCaravan]);
    set(gh.averageValues,'String',[avgVelocity; avgEconomy]);
    
    set(focusSelector, 'String', [vehicles.id]');
    
    set(guiAxes, 'Visible', 'on');
        

% --- Executes on button press in scrollLeft.
function scrollLeft_Callback(hObject, eventdata, handles)
% hObject    handle to scrollLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guiAxes = handles.axes1;
step = str2double(get(handles.edit1,'String'));
range = str2double(get(handles.edit2,'String'));

if xlim-step >= 0
    set(guiAxes, 'XLim', get(guiAxes, 'XLim') - step);
    xl=xlim;
    xlim([xl(1) xl(1)+range]);
    updateGUI();
end


% --- Executes on button press in scrollRight.
function scrollRight_Callback(hObject, eventdata, handles)
% hObject    handle to scrollRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guiAxes = handles.axes1;
step = str2double(get(handles.edit1,'String'));
range = str2double(get(handles.edit2,'String'));
% {step, step}
% set(guiAxes, 'XLim', get(guiAxes, 'XLim') + step);
xl=xlim;
xlim([xl(1) xl(1)+range] + step);
updateGUI();



% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('I''ll do something eventually!')



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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SimulationSetup
    
    if SimulationSetup.Pause == true
        SimulationSetup.Pause = false;
    else
        SimulationSetup.Pause = true;
    end
    


% --- Executes on button press in focusCheckbox.
function focusCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to focusCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of focusCheckbox


% --- Executes on selection change in focusSelector.
function focusSelector_Callback(hObject, eventdata, handles)
% hObject    handle to focusSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns focusSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from focusSelector


% --- Executes during object creation, after setting all properties.
function focusSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to focusSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
