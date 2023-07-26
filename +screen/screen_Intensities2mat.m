function [AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = Intensities2mat(Intensity_path, CellType, incubation_time, concentration, replicate)

%% Initialize variables.

% [filenames, rootdir, ~] = uigetfile('*.txt','Select all Intensities.txt files to be imported (multi-selection)', 'Multiselect', 'on');

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

for i=1:length(converted)

    converted{i,8} = strrep(converted{i,8},'30min','0.5');
    converted{i,8} = strrep(converted{i,8},'60min','1');
    converted{i,8} = strrep(converted{i,8},'15min','0.25');
    converted{i,8} = strrep(converted{i,8},'3h','3');
    converted{i,8} = strrep(converted{i,8},'overnight','16');
    
    converted{i,8} = strrep(converted{i,8},'/','');
    converted{i,8} = strrep(converted{i,8},'\','');
    
    converted{i,7} = converted{i,6}(1:4);
    
    nMIndex = strfind(converted{i,5},'nM');
    if strfind(converted{i,5},'_')
        delimIndex = strfind(converted{i,5},'_');
    elseif strfind(converted{i,5},' ')
        delimIndex = strfind(converted{i,5},' ');
    end
    converted{i,5} = converted{i,5}(delimIndex+1:nMIndex-1);
    converted{i,5} = strrep(converted{i,5},',','.');
    
    maskIndex = strfind(converted{i,6},'mask');
    converted{i,6} = converted{i,6}(maskIndex-3:maskIndex-2);
end

%% Find matching entries in Intensities and registration data

% load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\a\Registration_all_a.mat');

AllAreas = zeros(length(converted),1);

wb = waitbar(0, 'Assignment', 'Name', 'Intensities Import');

for i=1:length(AllAreas)
    
    waitbar(i/length(AllAreas),wb);
    
    tempCellType = CellType{i};
    tempincubation_time = incubation_time(i);
    tempconcentration = concentration(i);
    tempreplicate = replicate(i);
    
    index = find(strcmp(converted(:,7),tempCellType) &...
    str2double(converted(:,8)) == tempincubation_time &...
    str2double(converted(:,5)) == tempconcentration &...
    str2double(converted(:,6)) == tempreplicate);

    fprintf('u-track index %3d - AllAreas index %3d\n', i, index)
    
    AllAreas(i) = str2double(string(converted(index,1)));
    BackgroundBlue(i) = str2double(string(converted(index,2)));
    BackgroundGreen(i) = str2double(string(converted(index,3)));
    BackgroundRed(i) = str2double(string(converted(index,4)));
    
end

close(wb);

% save('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllAreas.mat', 'AllAreas');
% save('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllIntensities.mat', 'Background*');