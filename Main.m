function varargout = Main(varargin)
    % MAIN MATLAB code for Main.fig
    %      MAIN, by itself, creates a new MAIN or raises the existing
    %      singleton*.
    %
    %      H = MAIN returns the handle to a new MAIN or the handle to
    %      the existing singleton*.
    %
    %      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MAIN.M with the given input arguments.
    %
    %      MAIN('Property','Value',...) creates a new MAIN or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before Main_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to Main_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help Main

    % Last Modified by GUIDE v2.5 18-Mar-2022 18:52:06

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton', gui_Singleton, ...
        'gui_OpeningFcn', @Main_OpeningFcn, ...
        'gui_OutputFcn', @Main_OutputFcn, ...
        'gui_LayoutFcn', [], ...
        'gui_Callback', []);

    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end

    % End initialization code - DO NOT EDIT

% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to Main (see VARARGIN)

    % Choose default command line output for Main
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes Main wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    handles.edit4.String = "Loading Folder...";
    [handles.Folder, handles.Files] = Load_TXT_Folder();
    handles.log = "Selected Working folder: " + newline + handles.Folder + newline + "Select the desired txt file.";

    handles.edit4.String = newline + handles.log;
    handles.edit2.String = handles.Folder; % Displays the selected folder
    handles.listbox3.String = handles.Files; % Save the list of txt files for luminescence
    handles.listbox4.String = handles.Files; % Save the list of txt files for topography

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


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
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
    % hObject    handle to listbox3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listbox3

    str = handles.log;
    handles.log = str + newline + "Fluo File selected: " + ...
        newline + handles.listbox3.String{handles.listbox3.Value};

    handles.edit4.String = handles.log;

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listbox3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
    % hObject    handle to listbox4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listbox4
    str = handles.log;
    handles.log = str + newline + "Topo File selected: " + ...
        newline + handles.listbox4.String{handles.listbox4.Value};
    handles.edit4.String = handles.log; % Update log

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listbox4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %Gets the file reference
    fluo_file = handles.listbox3.String{handles.listbox3.Value};
    %Loads the data
    handles.lumi_raw_data = Load_Fluo(fluo_file, handles.Folder); % Saves raw data for later use
    handles.lumi_raw_image = Calculate_raw_Lumi_Intensity(handles.lumi_raw_data);

    %Displays message an update message
    str = handles.log;
    handles.log = str + newline + "Lumi Data loaded.";
    handles.edit4.String = handles.log; % Update log

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    Alignement(handles.processed_image, handles.topo_raw_data);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [processed_data, processed_image, background] = NoiseCorrection(handles.lumi_raw_data, handles.lumi_raw_image);
    handles.processed_data = processed_data;
    handles.processed_image = processed_image;

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkbox2

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %Gets the file reference
    topo_file = handles.listbox4.String{handles.listbox4.Value};
    %Loads the data
    handles.topo_raw_data = Load_Topo(topo_file, handles.Folder); % Saves raw data for later use

    %Displays message
    str = handles.log;
    handles.log = str + newline + "Topo Data loaded.";
    handles.edit4.String = handles.log; % Update log

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

function edit4_Callback(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit4 as text
    %        str2double(get(hObject,'String')) returns contents of edit4 as a double

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    delete(hObject);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
