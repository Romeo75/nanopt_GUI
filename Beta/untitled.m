
%%input variables


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
i = 1 % Bakcground index
j = 2 % Intensity  index


%Select the Background and intensity data from the folder
Background_File = Load_Fluo(Files(i),Folder); % Output of the Background file
Fluo_File       = Load_Fluo(Files(j),Folder); % Output of the Intensity  file

% Calculate the amount of points per images from data
[N2, ~] = size(Fluo_File);
N = sqrt(N2); % This is the number of points in x or y

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

%Background substraction
Fluo_Intensity_processed = [lumi_raw_image(1:2,:);lumi_raw_image(3,:)-C*background_raw_image(3,:)];

%Draw hyper spectral image of the processed Luminescence
figure("Name","Processed Luminescence")
Plot_Lumi(lumi_raw_image,gca);

%Plots histogram from pixel

figure("Name","Histogram selected pixel")

pixel_index= 10;
[1:N2]; %Intervall of the pixel_index

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




