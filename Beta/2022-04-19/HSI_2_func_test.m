raw_data = importdata('./30.txt');

delimiter = ';';

%Initializing array that will contain data (correct shape)
raw_spectrum = ones(2,2);

for i=1:size(raw_data)
    if isequal(strfind(cell2mat(raw_data(i,1)),delimiter),[])
        row_limit = i;
    else
        row_cell = strsplit(cell2mat(raw_data(i,1)), delimiter);
        for j=1:length(row_cell)
        raw_spectrum(i-row_limit,j) = str2double(strrep(strtrim(row_cell(1,j)),',','.'));
        end
    end
end