function [AllData] = Generate_AllData(raw_file)
    %GENERATE_ALLDATA Summary of this function goes here
    %   Detailed explanation goes here
    
    [pixy_N, ~] = size(raw_file); % Number of pixels
    pixel_data = zeros(pixy_N,1024);
    

    for i = 1:pixy_N
        
        pixel_spectrum = raw_file(i,3:end); % The i index tells is the pixel number
        pixel_position = raw_file(i,1:2);   % All of the pixels are considered
    
        N = numel(pixel_spectrum); % Number of wavelengths considered in the spectrum
        
        counts = pixel_spectrum(mod(1:N,2) == 0); % Extract the counts from the data array of the pixel
        lambda = pixel_spectrum(mod(1:N,2) == 1); % Extract the lambdas from the data array of the pixel
        
        pixel_data(i,:) = counts;
    end
    
    
    AllData = pixel_data;
end

