function [AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = Intensities2mat(Intensity_path, CellType, dye_combination, dye_load, replicate)

%% Initialize variables.

data_all = {};

for i=1:length(Intensity_path)
    filename = Intensity_path{i}; % [rootdir filenames{i}];
    delimiter = '\t';
    startRow = 2;

    %% Format for each line of text:
    %   column2: double (%f)
    %	column3: double (%f)
    %   column4: double (%f)
    %	column5: double (%f)
    %   column6: text (%s)
    %	column7: text (%s)
    %   column8: text (%s)
    %	column9: text (%s)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%*s%f%f%f%f%s%s%s%s%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    %% Create output variable
    dataArray([1, 2, 3, 4]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4]), 'UniformOutput', false);
    data = [dataArray{1:end-1}];
    data_all = [data_all; data];
    %% Clear temporary variables
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;

end

%% Convert data from Intensities.txt file to format of registration data

converted = data_all;
imagePath = converted(:,7);

for j=1:length(converted)
    
    [AA_CellType{j} AA_dye_combination{j} AA_dye_load{j} AA_replicate(j)] = ...
        conditionsFromStringJF(imagePath{j});
    
end

%% Find matching entries in Intensities and registration data

% load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\a\Registration_all_a.mat');

AllAreas = zeros(length(converted),1);

wb = waitbar(0, 'Assignment', 'Name', 'Intensities Import');

for i=1:length(AllAreas)
    
    waitbar(i/length(AllAreas),wb);
    
    this_CellType = CellType{i};
    this_dye_combination = dye_combination(i);
    this_dye_load = dye_load(i);
    this_replicate = replicate(i);

    
    index = find(strcmp(AA_CellType,this_CellType) &...
    strcmp(AA_dye_combination, this_dye_combination) &...
    strcmp(AA_dye_load, this_dye_load) &...
    AA_replicate == this_replicate);

    fprintf('u-track index %3d - AllAreas index %3d\n', i, index)
    
    AllAreas(i) = str2double(string(converted(index,1)));
    BackgroundBlue(i) = str2double(string(converted(index,2)));
    BackgroundGreen(i) = str2double(string(converted(index,3)));
    BackgroundRed(i) = str2double(string(converted(index,4)));
    
end

close(wb);

% save('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllAreas.mat', 'AllAreas');
% save('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllIntensities.mat', 'Background*');