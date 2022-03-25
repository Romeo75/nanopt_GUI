function varargout = AverageRegionNoiseCorrection(varargin)
    % AverageRegionNoiseCorrection MATLAB code for AverageRegionNoiseCorrection.fig
    %      AverageRegionNoiseCorrection, by itself, creates a new AverageRegionNoiseCorrection or raises the existing
    %      singleton*.
    %
    %      H = AverageRegionNoiseCorrection returns the handle to a new AverageRegionNoiseCorrection or the handle to
    %      the existing singleton*.
    %
    %      AverageRegionNoiseCorrection('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in AverageRegionNoiseCorrection.M with the given input arguments.
    %
    %      AverageRegionNoiseCorrection('Property','Value',...) creates a new AverageRegionNoiseCorrection or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before AverageRegionNoiseCorrection_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to AverageRegionNoiseCorrection_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help AverageRegionNoiseCorrection

    % Last Modified by GUIDE v2.5 18-Mar-2022 18:52:29

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton', gui_Singleton, ...
        'gui_OpeningFcn', @AverageRegionNoiseCorrection_OpeningFcn, ...
        'gui_OutputFcn', @AverageRegionNoiseCorrection_OutputFcn, ...
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

%___________________________________________
%
%   Local Functions
%___________________________________________

function pixel_index = select_pixel(hObject, eventdata, handles)

    %Pixel selector
    pixel_selector = drawpoint(handles.axes1, 'Color', 'r', 'MarkerSize', 5);
    uiresume(handles.Noise)
    clc
    %Calculate the nearest values of the data positions to the selected ones
    selected_position = pixel_selector.Position;
    difference = abs(handles.lumi_raw_data(:, 1:2) - selected_position);
    minimize_selection = min(difference);
    search_condition = find(difference == minimize_selection);
    pixel_position = unique(handles.lumi_raw_data(search_condition));
    handles.pixel_position = pixel_position';
    handles.edit1.String = "selected pixel: " + newline + ...
        pixel_position(1) + " " + pixel_position(2);

    %Pixel index determination
    all_positions = handles.lumi_raw_data(:, 1:2);
    x_condition = abs(all_positions(:, 1) - pixel_position(2)) == 0;
    y_condition = abs(all_positions(:, 2) - pixel_position(1)) == 0;
    pixel_condition = x_condition & y_condition;
    pixel_index = find(pixel_condition); % output
    delete(pixel_selector); % Clear the figure marker
    % Update handles structure
    guidata(hObject, handles);

function [hObject, eventdata, handles] = plot_pixel_histogram(hObject, eventdata, handles)
    pixel_index = select_pixel(hObject, eventdata, handles);

    %data extraction
    pixel_spectrum = handles.lumi_raw_data(pixel_index, 3:end);

    %data formating
    N = numel(pixel_spectrum); % Number of wavelengths considered in the spectrum
    lambda = pixel_spectrum(1:2:end); % Extrect the lambdas from the data array of the pixel
    counts = pixel_spectrum(2:2:end); % Extrect the counts from the data array of the pixel

    %save data to start processing
    handles.lambda = lambda;
    handles.counts = counts;
    handles.pixel_spectrum = pixel_spectrum;

    %plot raw data
    plot(lambda, handles.counts, 'Parent', handles.axes2)
    title("Histogram of the pixel", 'Parent', handles.axes2)
    xlabel("Wavelength (in nm)", 'Parent', handles.axes2)
    ylabel("Bin Count", 'Parent', handles.axes2)
    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

%___________________________________________
%
%   end of local functions
%___________________________________________

% --- Executes just before AverageRegionNoiseCorrection is made visible.
function AverageRegionNoiseCorrection_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to AverageRegionNoiseCorrection (see VARARGIN)

    % Choose default command line output for AverageRegionNoiseCorrection
    handles.processed_image = hObject;
    handles.lumi_raw_data = varargin{1};
    handles.lumi_raw_image = varargin{2};

    %Draw hyper spectral image
    X = reshape(handles.lumi_raw_image(1, :), [100, 100]);
    Y = reshape(handles.lumi_raw_image(2, :), [100, 100]);
    C = reshape(handles.lumi_raw_image(3, :), [100, 100]);
%     s_fluo = surface(X, Y, C, "Parent", handles.axes1);
%     s_fluo.EdgeColor = 'flat';
%     s_fluo.LineStyle = ':';
%     s_fluo.MarkerEdgeColor = 'none';
%     s_fluo.EdgeAlpha = 1;
    shading interp
    colormap("hot")
    colorbar
    view(handles.axes1, [handles.slider1.Value handles.slider2.Value])

    % The function needs to override the main function handles otherwise we
    % lose variables as handles.counts,etc...
    %[hObject, eventdata, handles] = plot_pixel_histogram(hObject, eventdata, handles);
    
    %yy2 = smooth(x,y,0.1,'rloess');
    
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes AverageRegionNoiseCorrection wait for user response (see UIRESUME)
    uiwait(handles.Noise);

% --- Outputs from this function are returned to the command line.
function varargout = AverageRegionNoiseCorrection_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure

    if (strcmp(handles.pushbutton6.Enable, 'off'))
        varargout{1} = handles.processed_data;
        varargout{2} = handles.processed_image;
        varargout{3} = handles.calculated_background;
    else
        varargout{1} = [];
        varargout{2} = [];
        varargout{3} = [];
    end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    view(handles.axes1, [handles.slider1.Value handles.slider2.Value]);
    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', [.9 .9 .9]);
    end

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    view(handles.axes1, [handles.slider1.Value handles.slider2.Value]);
    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', [.9 .9 .9]);
    end

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.peak = drawrectangle('Color', 'r', 'Parent', handles.axes2);

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use
    % Since Noice seems to break uiwait, it is called again.
    uiwait(handles.Noise);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % open the noise selection windows
    handles.edit1.String = "select a square with only noisy background in the image...";
    handles.noise_left = drawrectangle('Color', 'r', 'Parent', handles.axes1);
    
    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use
    % Since Noice seems to break uiwait, it is called again.
    uiwait(handles.Noise);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
    % hObject    handle to slider3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', [.9 .9 .9]);
    end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    counts = handles.counts;
    lambda = handles.lambda;

    position_right = get(handles.noise_right, 'Position');

    right_intervall_start = position_right(1);
    right_intervall_end = position_right(1) + position_right(3);
    
    right_noise = counts(right_intervall_start < lambda & lambda < right_intervall_end);

    right_level = mean(right_noise);

    position_peak = get(handles.peak, 'Position');
    intervall_start = position_peak(1);
    intervall_end = position_peak(1) + position_peak(3);

    handles.background_values = background_values;
    counts_trimmed = counts - background_values;
    condition = counts_trimmed > 0 & intervall_start < lambda & lambda < intervall_end;

    plot(lambda, counts, "Parent", handles.axes3);
    hold(handles.axes3, 'on')
    plot(lambda, background_values, "Parent", handles.axes3);
    hold(handles.axes3, 'off')
    title("luminescence of the selected pixel", "Parent", handles.axes3)
    xlabel("Wavelength (in nm)", "Parent", handles.axes3)
    ylabel("Bin Count", "Parent", handles.axes3)

    plot(lambda(condition), counts_trimmed(condition), 'Parent', handles.axes4);
    title("Corrected luminescence of the selected pixel", "Parent", handles.axes4)
    xlabel("Wavelength (in nm)", "Parent", handles.axes4)
    ylabel("Bin Count", "Parent", handles.axes4)

    %Calculate output
    handles.processed_data = [counts_trimmed(condition), lambda(condition)];
    handles.processed_image = Calculate_Corrected_Lumi_Intensity(handles.lumi_raw_data, background_values, intervall_start, intervall_end);
    handles.calculated_background = background_values;

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %clear the selection windows
    delete(handles.noise_right);
    delete(handles.noise_left);
    delete(handles.peak);

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: place code in OpeningFcn to populate axes1

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit1 as text
    %        str2double(get(hObject,'String')) returns contents of edit1 as a double

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use


% --- Executes during object deletion, before destroying properties.
function axes1_DeleteFcn(hObject, eventdata, handles)
    % hObject    handle to axes1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    plot_pixel_histogram(hObject, eventdata, handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.pushbutton6.Enable = 'off';
    uiresume(handles.Noise)
    % Update handles structure (variables of the running program)
    guidata(hObject, handles); % This saves all of the data saved in handles as variables for later use

% --- Executes when user attempts to close Noise.
function Noise_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to Noise (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.Noise)
    delete(handles.Noise)

% --- Executes during object deletion, before destroying properties.
function Noise_DeleteFcn(hObject, eventdata, handles)
    % hObject    handle to Noise (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.Noise)
