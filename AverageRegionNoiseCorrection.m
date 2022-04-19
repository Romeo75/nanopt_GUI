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

    % Last Modified by GUIDE v2.5 30-Mar-2022 10:25:46

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

function pixel_index = image_to_data(selected_position,step)
    pixel_index = selected_position(1)+selected_position(2)*step;

function pixel_index = select_pixel(hObject, eventdata, handles)

    %inputs
    image_size = handles.image_size;
    step       = image_size(1);

    %Pixel selector
    pixel_selector = drawpoint(handles.axes1, 'Color', 'r', 'MarkerSize', 5);
    uiresume(handles.Noise);
    
    
    %Calculate the nearest values of the data positions to the selected ones
    selected_position = round(pixel_selector.Position);

    %Determine the pixel index using the size of the image
    pixel_index = image_to_data(selected_position,step);
    
    pixel_position = handles.lumi_raw_data(pixel_index, 1:2);
    
    handles.edit1.String = "selected pixel data position: " + newline + ...
        pixel_position(1) + " " + pixel_position(2) + newline + ...
        "selected pixel index inside data: " + newline + ...
        pixel_index;
    
    %Clear the figure marker
    delete(pixel_selector);

function [hObject, eventdata, handles] = select_image_area(hObject, eventdata, handles)
    
    %inputs
    image_size = handles.image_size;
    step       = image_size(1);
    
    %Pixel selector
    pixel_selector = drawrectangle(handles.axes1, 'Color', 'r', 'MarkerSize', 5);
    %uiresume(handles.Noise);
    
    
    %generate the array of indexes corresponding to the selected pixels
    area_limits = round(pixel_selector.Position);
    
    top_left    = area_limits(1:2);
    botom_right = area_limits(1:2)+area_limits(3:4);
    
    row_indexes     = (top_left(1):1:botom_right(1));
    column_indexes  = (top_left(2):1:botom_right(2));
    
    pixel_area_indexes = [];

    for c = column_indexes
        temp = [row_indexes;c*ones(size(row_indexes))]';
        pixel_area_indexes = [pixel_area_indexes;temp(:,1)+step*temp(:,2)];
    end
    
    %debug scopes to track the limits of the indexes array
    %first_index = image_to_data(top_left,step);
    %last_index  = image_to_data(botom_right,step);
    
    %Function outputs
    handles.noise_area = pixel_selector;
    handles.area_indexes = pixel_area_indexes;
    
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
    plot(lambda, handles.counts, 'Parent', handles.axes3,'DisplayName','Raw counts')
    
    title("Histogram of the selected pixel", 'Parent', handles.axes3)
    xlabel("Wavelength (in nm)", 'Parent', handles.axes3)
    ylabel("Bin Count", 'Parent', handles.axes3)
    legend(handles.axes3,"AutoUpdate","on");

    % If the background has been calculated plot it
    if isfield(handles,'smooth_counts') %checks if the variable exists inside handles
        hold(handles.axes3,"on")
        plot(lambda, handles.smooth_counts, 'Parent', handles.axes3,'DisplayName','Calculated Background')
        hold(handles.axes3,"off")
    end

    % Update handles structure
    guidata(hObject, handles);


function [hObject, eventdata, handles] = plot_area_histogram(hObject, eventdata, handles)
    
    index_list = handles.area_indexes;
    N_pixels = numel(index_list);

    %data extraction
    pixel_spectrum = handles.lumi_raw_data(index_list(1), 3:end);

    %data extraction from the data array of the first pixel
    lambda = pixel_spectrum(1:2:end); % Extract the lambdas 
    raw_counts = pixel_spectrum(2:2:end); % Extract the counts
    
    N_lambdas = numel(lambda);

    mean = zeros(1,N_lambdas);

    for i = (1:N_pixels)
        
        %Explore all of the selected pixels
        pixel_index = index_list(i);
        %data extraction
        pixel_spectrum = handles.lumi_raw_data(pixel_index, 3:end);
        
        %data formating
        counts = pixel_spectrum(2:2:end); % Extract the counts from the data array of the pixel
        mean = mean + counts/N_pixels; % Calculate the background noise

    end


    %save data for the full image processing
    handles.lambda          = lambda;
    handles.raw_counts      = raw_counts;
    handles.mean_counts     = mean; %Noise background
    handles.smooth_counts   = smooth(lambda,mean,0.1,'rloess');
    handles.pixel_spectrum  = pixel_spectrum;
    
    %plot raw data
    plot(lambda, handles.raw_counts, 'Parent', handles.axes2,'DisplayName','Raw counts')
    hold(handles.axes2,"on")
    plot(lambda, handles.mean_counts, 'Parent', handles.axes2,'DisplayName',' Area averaged counts')
    plot(lambda, handles.smooth_counts, 'Parent', handles.axes2,'DisplayName',' Smoothed area averaged counts')
    hold(handles.axes2,"off")
    %Graph format
    title("Histogram of the pixel", 'Parent', handles.axes2)
    xlabel("Wavelength (in nm)", 'Parent', handles.axes2)
    ylabel("Bin Count", 'Parent', handles.axes2)
    legend(handles.axes2,"AutoUpdate","on");

    % Update handles structure
    guidata(hObject, handles);

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

    %Interface input
    image_size = [ str2double(get(handles.edit2,'String')), str2double(get(handles.edit4,'String')) ];

    %Store for later use
    handles.image_size = image_size;

    %Draw hyper spectral image
    X = reshape(handles.lumi_raw_image(1, :), image_size);
    Y = reshape(handles.lumi_raw_image(2, :), image_size);
    C = reshape(handles.lumi_raw_image(3, :), image_size);
    
    %Display the image
    image(handles.axes1,C,'CDataMapping','scaled');
    %image(handles.axes1,[X(1,1),X(end,end)],[Y(1,1),Y(end,end)],C,'CDataMapping','scaled');
    colormap("hot")
    colorbar
    
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
        % UIWAIT makes AverageRegionNoiseCorrection wait for user response (see UIRESUME)
        uiwait(handles.Noise);
    end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    view(handles.axes1, [handles.slider1.Value 90]);
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
    handles.peak = drawrectangle('Color', 'r', 'Parent', handles.axes3);

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
    [hObject, eventdata, handles] = select_image_area(hObject, eventdata, handles);
    [hObject, eventdata, handles] = plot_area_histogram(hObject, eventdata, handles);

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
    
    background_values = handles.smooth_counts';

    position_peak = get(handles.peak, 'Position');
    intervall_start = position_peak(1);
    intervall_end = position_peak(1) + position_peak(3);

    counts_trimmed = counts - background_values;
    condition = intervall_start < lambda & lambda < intervall_end & counts_trimmed > 0 ;

%     plot(lambda, counts, "Parent", handles.axes3);
%     hold(handles.axes3, 'on')
%     plot(lambda, background_values, "Parent", handles.axes3);
%     hold(handles.axes3, 'off')
%     title("luminescence of the selected pixel", "Parent", handles.axes3)
%     xlabel("Wavelength (in nm)", "Parent", handles.axes3)
%     ylabel("Bin Count", "Parent", handles.axes3)
    
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
     if isfield(handles,'noise_area') %checks if the variable exists inside handles
        delete(handles.noise_area);        
     end
    if isfield(handles,'peak') %checks if the variable exists inside handles

        delete(handles.peak);

    end


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
    [hObject, eventdata, handles] = plot_pixel_histogram(hObject, eventdata, handles);
    % UIWAIT makes AverageRegionNoiseCorrection wait for user response (see UIRESUME)
    uiwait(handles.Noise);


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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
