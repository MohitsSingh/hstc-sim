function varargout = SimulationOptions(varargin)
%SIMULATIONOPTIONS M-file for SimulationOptions.fig
%      SIMULATIONOPTIONS, by itself, creates a new SIMULATIONOPTIONS or raises the existing
%      singleton*.
%
%      H = SIMULATIONOPTIONS returns the handle to a new SIMULATIONOPTIONS or the handle to
%      the existing singleton*.
%
%      SIMULATIONOPTIONS('Property','Value',...) creates a new SIMULATIONOPTIONS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SimulationOptions_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SIMULATIONOPTIONS('CALLBACK') and SIMULATIONOPTIONS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SIMULATIONOPTIONS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SimulationOptions

% Last Modified by GUIDE v2.5 27-Nov-2011 22:49:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SimulationOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @SimulationOptions_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before SimulationOptions is made visible.
function SimulationOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for SimulationOptions
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimulationOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SimulationOptions_OutputFcn(hObject, eventdata, handles)
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
global CaravanControllerSetup
global SimulationSetup

CaravanControllerSetup.VehicleSpacing = ...
    get(handles.VehicleSpacing,  'String');

CaravanControllerSetup.MaxCaravanSize = ...
    get(handles.MaxCaravanSize,'String');

CaravanControllerSetup.MaxCaravanSpeed = ...
    get(handles.MaxCaravanSpeed,'String');

CaravanControllerSetup.MinCaravanDistance = ...
    get(handles.MinCaravanDistance,'String');

CaravanControllerSetup.MaxCaravanDistance = ...
    get(handles.MaxCaravanDistance,'String');

SimulationSetup.TrafficDensityModel = ...
    get(handles.TrafficDensityModel,'String');

SimulationSetup.SimulationRunLength = ...
    get(handles.SimulationRunLength,'String');


val = get(handles.SimulationRunUnits,'Value');
if val == 1 
    SimulationSetup.SimulationRunUnits = 'Cars';
else
    SimulationSetup.SimulationRunUnits = 'Seconds';
end

close


% --- Executes on selection change in TrafficDensityModel.
function TrafficDensityModel_Callback(hObject, eventdata, handles)
% hObject    handle to TrafficDensityModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TrafficDensityModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TrafficDensityModel


% --- Executes during object creation, after setting all properties.
function TrafficDensityModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrafficDensityModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SimulationRunLength_Callback(hObject, eventdata, handles)
% hObject    handle to SimulationRunLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SimulationRunLength as text
%        str2double(get(hObject,'String')) returns contents of SimulationRunLength as a double


% --- Executes during object creation, after setting all properties.
function SimulationRunLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimulationRunLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SimulationRunUnits.
function SimulationRunUnits_Callback(hObject, eventdata, handles)
% hObject    handle to SimulationRunUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SimulationRunUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SimulationRunUnits


% --- Executes during object creation, after setting all properties.
function SimulationRunUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimulationRunUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VehicleSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to VehicleSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VehicleSpacing as text
%        str2double(get(hObject,'String')) returns contents of VehicleSpacing as a double


% --- Executes during object creation, after setting all properties.
function VehicleSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VehicleSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxCaravanSize_Callback(hObject, eventdata, handles)
% hObject    handle to MaxCaravanSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxCaravanSize as text
%        str2double(get(hObject,'String')) returns contents of MaxCaravanSize as a double


% --- Executes during object creation, after setting all properties.
function MaxCaravanSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxCaravanSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxCaravanSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to MaxCaravanSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxCaravanSpeed as text
%        str2double(get(hObject,'String')) returns contents of MaxCaravanSpeed as a double


% --- Executes during object creation, after setting all properties.
function MaxCaravanSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxCaravanSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinCaravanDistance_Callback(hObject, eventdata, handles)
% hObject    handle to MinCaravanDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinCaravanDistance as text
%        str2double(get(hObject,'String')) returns contents of MinCaravanDistance as a double


% --- Executes during object creation, after setting all properties.
function MinCaravanDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinCaravanDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxCaravanDistance_Callback(hObject, eventdata, handles)
% hObject    handle to MaxCaravanDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxCaravanDistance as text
%        str2double(get(hObject,'String')) returns contents of MaxCaravanDistance as a double


% --- Executes during object creation, after setting all properties.
function MaxCaravanDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxCaravanDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
