
%%input variables
'D:\Obren\Ordered\20220415_data\528\BG0 528 0.2s.txt'
'D:\Obren\Ordered\20220415_raw-spectra\528\exp_1\2022.04.15_0.txt'

%Load the .TXT files inside the folder
[Folder, Files]=Load_TXT_Folder("D:\Obren\Ordered\20220415_raw-spectra\528\exp_1");

%Output the names of the found TXT files
N_Files = numel(Files);

%Names of the files inside the folder
Files(:)
%Vector of indexes (final for loop of the Folder Batch)
[1:N_Files];

%Display the number of files inside the folder
N_Files

% Select the files
i = 2 % Intensity  index
j = 1 % Bakcground index


%Select the Background and intensity data from the folder
Fluo_File       = Load_Fluo(Files(i),Folder); % Output of the Intensity  file
Background_File = Load_Fluo(Files(j),Folder); % Output of the Background file

% Calculate the amount of points per images from data
[N_pixels, ~] = size(Fluo_File);
N = sqrt(N_pixels); % This is the number of points in x or y

%Calculate the Integral of the full spectrum to have a first view of data
lumi_raw_image       = Calculate_raw_Lumi_Intensity(Fluo_File);
background_raw_image = Calculate_raw_Lumi_Intensity(Background_File);


%Draw hyper spectral image of the Luminescence
figure("Name","Raw Luminescence")
Plot_Lumi(lumi_raw_image,gca);

%Draw hyper spectral image of the Bakcground
figure("Name","Background Luminescence")
Plot_Lumi(background_raw_image,gca);


%Coefficient
C = 1;

AllData_Fluo       = Generate_AllData(Fluo_File);
AllData_Background = Generate_AllData(Background_File);

testy = 237;
%temp
temp= SubAvanced(AllData_Fluo,N_pixels,AllData_Background(testy,:),lambda);

%Background substraction
Fluo_Intensity_processed = [lumi_raw_image(1:2,:);temp'];



%Draw hyper spectral image of the processed Luminescence
figure("Name","Processed Luminescence")
Plot_Lumi(Fluo_Intensity_processed,gca);

%Plots histogram from pixel

figure("Name","Histogram selected pixel")

pixel_index= 1;
[1:N_pixels]; %Intervall of the pixel_index

%data extraction
pixel_spectrum = Fluo_File(pixel_index,3:end);

%data formating
N = numel(pixel_spectrum); % Number of wavelengths considered in the spectrum
lambda = pixel_spectrum(mod(1:N,2) == 1); % Extrect the lambdas from the data array of the pixel
counts = pixel_spectrum(mod(1:N,2) == 0); % Extrect the counts from the data array of the pixel

%save data to start processing
handles.lambda = lambda;
handles.counts = counts;
handles.pixel_spectrum = pixel_spectrum;

%plot raw data
plot(lambda,handles.counts,'Parent',gca)
title("Histogram of the pixel",'Parent',gca)
xlabel("Wavelength (in nm)",'Parent',gca)
ylabel("Bin Count",'Parent',gca)


%_________________________________________________________________________
%
%   Functions
%
%_________________________________________________________________________

function [SubData]=SubAvanced(AllData,N_pixels,BG_intensity,lambda)
    %
    % Input
    %
    %     BG_intensity is the array that contains the counts of the BG spectrum
    %     (It should be a spectra taken from a pixel where ther's no lumi
    %     
    %     AllData should contain all of the spectras of the hyper spectral
    %     image as a matrix where the rows are the pixels and the colomns the
    %     counts of the given lambda
    %
    % Output
    %     SubData contains all of the corrected data
    %
    
    CoeffCor=linspace(0.001,10,1001);
    
    SubData=zeros(N_pixels,1024);
    
    for i=1:N_pixels
        
        % We repeat the data so that we generate enough correction
        % backgrounds and chose the best among them
        [~,idx]=min(sum(( (AllData(1:200,i).*ones(200,1001))-BG_intensity(1:200)'.*CoeffCor ).^2,1));
        SubData(i,:)=AllData(i,:)-BG_intensity.*CoeffCor(idx); %Correction
        if i<10
            figure
            %Verfication of the correction
            plot(lambda,SubData(i,:),'Parent',gca,'DisplayName','Corrected')
            title("Histogram of the pixel",'Parent',gca)
            xlabel("Wavelength (in nm)",'Parent',gca)
            ylabel("Bin Count",'Parent',gca)
            hold on
            plot(lambda,AllData(i,:),'Parent',gca,'DisplayName','Corrected')
        end
    end

end