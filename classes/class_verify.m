function varargout = class_verify(varargin)
% CLASS_VERIFY MATLAB code for class_verify.fig
%      CLASS_VERIFY, by itself, creates a new CLASS_VERIFY or raises the existing
%      singleton*.
%
%      H = CLASS_VERIFY returns the handle to a new CLASS_VERIFY or the handle to
%      the existing singleton*.
%
%      CLASS_VERIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASS_VERIFY.M with the given input arguments.
%
%      CLASS_VERIFY('Property','Value',...) creates a new CLASS_VERIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before class_verify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to class_verify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help class_verify

% Last Modified by GUIDE v2.5 14-Apr-2019 22:33:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @class_verify_OpeningFcn, ...
                   'gui_OutputFcn',  @class_verify_OutputFcn, ...
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

function draw_imagebuttons(handles)
for i=1:40
    h = getfield(handles, sprintf('togglebutton%d', i));
    if i+handles.current_base > length(handles.current_indices)
        h.String = [];
        h.Value = 0;
        set(h, 'cdata', []);
    else
        h.String = handles.class_names{handles.presented_class+1};
        h.Value = 1;
        ind = handles.current_indices(i+handles.current_base);
        h.Units = 'pixels';
        img = handles.images(:,(1:90)+(handles.current_display-1)*90,ind);
        %img = flipud(img); %img = fliplr(img);
        img = repmat(img, [1, 1, 3]);
        set(h, 'cdata', img);
    end
end

% --- Initialize all images
function reset_images(handles)
% Read current class assignment
in_file = matfile('stimuli_class_assignment.mat');
class_names = in_file.class_names;
class_assignment = in_file.class_assignment;
% Set the presented class to be the current one during reset
handles.presented_class = handles.current_class; 
% Populate the handles map
handles.listbox1.String = class_names;
handles.listbox1.Value = handles.current_class+1;
handles.listbox2.Value = handles.current_display;
handles.class_names = class_names;
handles.class_assignment = class_assignment;
handles.current_base = 0;
handles.pushbutton2.String = sprintf('Reset %s', handles.class_names{handles.current_class+1});
displays = {'left', 'middle', 'right'};
fprintf('Reseting to %s (%s display)\n', class_names{handles.presented_class+1}, displays{handles.current_display});
% Read images
img_filename = '../../imgResp/images_natimg2800_all.mat';
assert(exist(img_filename, 'file')>0, 'Natural images file not found: %s', img_filename);
img = matfile(img_filename);
images = img.imgs;
images = double(images)/255.;
handles.images = images;
handles.current_indices = find(class_assignment == handles.presented_class);
handles.text2.String = sprintf('Tagging\n[%d-%d / %d]', ...
handles.current_base+1, handles.current_base+40, length(handles.current_indices));
draw_imagebuttons(handles)
% Update handles structure
guidata(handles.output, handles);

% --- Executes just before class_verify is made visible.
function class_verify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to class_verify (see VARARGIN)
% Choose default command line output for class_verify
handles.output = hObject;
if length(varargin)>=1
    handles.current_class = varargin{1};
else
    handles.current_class = 0;
end
if length(varargin)>=2 
    handles.current_display = varargin{2};
else
    handles.current_display = 2;
end
reset_images(handles)

% UIWAIT makes class_verify wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = class_verify_OutputFcn(hObject, eventdata, handles) 
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
class_assignment = handles.class_assignment;
class_names = handles.class_names;
for i=1:40
    h = getfield(handles, sprintf('togglebutton%d', i));
    if i+handles.current_base>length(handles.current_indices)
        continue;
    end
    ind = handles.current_indices(i+handles.current_base);
    if (isempty(h.String))
        class_assignment(ind) = nan;
    else
        current_class = find(strcmp(h.String, class_names))-1;
        class_assignment(ind) = current_class;
    end
end
save('stimuli_class_assignment.mat', 'class_names', 'class_assignment');
handles.class_assignment = class_assignment;
handles.current_base = handles.current_base+40;
handles.text2.String = sprintf('Review %s\n[%d-%d / %d]', handles.class_names{handles.presented_class+1}, ...
    handles.current_base+1, handles.current_base+40, length(handles.current_indices));
draw_imagebuttons(handles)
guidata(gcbo, handles);

% --- Executes on key press with focus on pushbutton1 and none of its controls.
function pushbutton1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function toggle_button(hObject, handles)
if get(hObject,'Value')
    hObject.String = handles.class_names{handles.current_class+1};
else
    hObject.String = [];
end

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on button press in togglebutton4.
function togglebutton4_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton4


% --- Executes on button press in togglebutton5.
function togglebutton5_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton5


% --- Executes on button press in togglebutton6.
function togglebutton6_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton6


% --- Executes on button press in togglebutton7.
function togglebutton7_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton7


% --- Executes on button press in togglebutton8.
function togglebutton8_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton8


% --- Executes on button press in togglebutton9.
function togglebutton9_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton9


% --- Executes on button press in togglebutton10.
function togglebutton10_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton10


% --- Executes on button press in togglebutton11.
function togglebutton11_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton11


% --- Executes on button press in togglebutton12.
function togglebutton12_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton12


% --- Executes on button press in togglebutton13.
function togglebutton13_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton13


% --- Executes on button press in togglebutton14.
function togglebutton14_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton14


% --- Executes on button press in togglebutton15.
function togglebutton15_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton15


% --- Executes on button press in togglebutton16.
function togglebutton16_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton16


% --- Executes on button press in togglebutton17.
function togglebutton17_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton17


% --- Executes on button press in togglebutton18.
function togglebutton18_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton18


% --- Executes on button press in togglebutton19.
function togglebutton19_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton19


% --- Executes on button press in togglebutton20.
function togglebutton20_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton20


% --- Executes on button press in togglebutton21.
function togglebutton21_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton21


% --- Executes on button press in togglebutton22.
function togglebutton22_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton22


% --- Executes on button press in togglebutton23.
function togglebutton23_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton23


% --- Executes on button press in togglebutton24.
function togglebutton24_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton24


% --- Executes on button press in togglebutton25.
function togglebutton25_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton25


% --- Executes on button press in togglebutton26.
function togglebutton26_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton26


% --- Executes on button press in togglebutton27.
function togglebutton27_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton27


% --- Executes on button press in togglebutton28.
function togglebutton28_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton28


% --- Executes on button press in togglebutton29.
function togglebutton29_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton29


% --- Executes on button press in togglebutton30.
function togglebutton30_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton30


% --- Executes on button press in togglebutton31.
function togglebutton31_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton31


% --- Executes on button press in togglebutton32.
function togglebutton32_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton32


% --- Executes on button press in togglebutton33.
function togglebutton33_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton33


% --- Executes on button press in togglebutton34.
function togglebutton34_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton34


% --- Executes on button press in togglebutton35.
function togglebutton35_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton35


% --- Executes on button press in togglebutton36.
function togglebutton36_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton36


% --- Executes on button press in togglebutton37.
function togglebutton37_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton37


% --- Executes on button press in togglebutton38.
function togglebutton38_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton38


% --- Executes on button press in togglebutton39.
function togglebutton39_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton39


% --- Executes on button press in togglebutton40.
function togglebutton40_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_button(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of togglebutton40


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.current_class = get(hObject,'Value')-1;
handles.pushbutton2.String = sprintf('Reset %s', handles.class_names{handles.current_class+1});
guidata(gcbo, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reset_images(handles)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.current_display = get(hObject,'Value');
draw_imagebuttons(handles);
guidata(gcbo, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
