function output = Correction_Factor(varargin)
% This function calculates the given beckground correction factor of the luminescence by a reference file
%   The input of the function is : Correction_Factor(input1)
%       input1 : full path to the luminescence file
%       input2 : full path to the background file 
%   The output of the function is: output = Correction_Factor
%       output : array of the correction coefficients

    % Check that the filepath is not empty
    if (isempty(varargin))
        luminescence_file_path  = Load_TXT_File;
        background_file_path    = Load_TXT_File;
    else
        luminescence_file_path = varargin{1};
        background_file_path   = varargin{2};
    end
    
    %Check if the algorithm is performing right
    debug_flag = 1;
    
    %Load the data from the txt file into a matlab matrix
    background_data = readmatrix(background_file_path,'Delimiter',';','NumHeaderLines',3);
    luminescence_data = readmatrix(luminescence_file_path);
    
    % Calculate the amount of points per images from data
    [N_pixels, ~] = size(luminescence_data);
    
    %Format the data
    background_counts          = background_data(:,2)';
    
    %_________________________________________________________________________
    %
    %   Correction estimation algorithm
    %
    %_________________________________________________________________________
    
    CoeffCor=linspace(0.001,10,1001);
    
    SubData=zeros(N_pixels,1024);
    alldata_luminescence = zeros(1024,N_pixels);
    C = zeros(1,N_pixels);
    
    for i=1:N_pixels
        
        pixel_spectrum = luminescence_data(i,3:end); % The i index tells is the pixel number
        %pixel_position = luminescence_data(i,1:2);   % All of the pixels are considered
    
        %N = numel(pixel_spectrum); % Number of wavelengths considered in the spectrum
        
        counts = pixel_spectrum(2:2:end); % Extrect the counts from the data array of the pixel
        
        %Format to in order to pass it as input of the correction algorithm
        alldata_luminescence(:,i) = counts;

        % We repeat the data so that we generate enough correction
        % backgrounds and chose the best among them
        [~,idx]=min(sum(( (alldata_luminescence(1:200,i).*ones(200,1001))-background_counts(1:200)'.*CoeffCor ).^2,1));
        
        if i<10 && debug_flag
            
            lambda = pixel_spectrum(1:2:end); % Extrect the lambdas from the data array of the pixel
            %Calculate the correction
            SubData(i,:)=alldata_luminescence(:,i)-background_counts'.*CoeffCor(idx); %Correction
            
            figure
            %Verfication of the correction
            plot(lambda,SubData(i,:),'Parent',gca,'DisplayName','Raw')
            title("Histogram of the pixel",'Parent',gca)
            xlabel("Wavelength (in nm)",'Parent',gca)
            ylabel("Bin Count",'Parent',gca)
            hold on
            plot(lambda,alldata_luminescence(:,i),'Parent',gca,'DisplayName','Corrected')
            legend            
        end
        C(i) = CoeffCor(idx);
    end
    
    
    %___________________________
    %
    %   Output and Format
    %___________________________
    
    output = C;
end
