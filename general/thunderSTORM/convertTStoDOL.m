function [Points_Blue_x, Points_Blue_y, Points_Blue_A, Points_Blue_c, Points_Blue_s, ...
    Points_Green_x, Points_Green_y, Points_Green_A, Points_Green_c, Points_Green_s, ...
    Points_Red_x, Points_Red_y, Points_Red_A, Points_Red_c, Points_Red_s, ...
    incubation_time, concentration, replicate, CellType] = convertTStoDOL(datasets,fittype,threshold)

% initialize variables required by DOL scripts
if length(datasets) > 1
    fprintf('Initializing variables required by DOL scripts.\n')
end
Points_Blue_x = cell(length(datasets),1);
Points_Blue_y = cell(length(datasets),1);
Points_Blue_A = cell(length(datasets),1);
Points_Blue_c = cell(length(datasets),1);
Points_Blue_s = cell(length(datasets),1);
Points_Green_x = cell(length(datasets),1);
Points_Green_y = cell(length(datasets),1);
Points_Green_A = cell(length(datasets),1);
Points_Green_c = cell(length(datasets),1);
Points_Green_s = cell(length(datasets),1);
Points_Red_x = cell(length(datasets),1);
Points_Red_y = cell(length(datasets),1);
Points_Red_A = cell(length(datasets),1);
Points_Red_c = cell(length(datasets),1);
Points_Red_s = cell(length(datasets),1);

% obtain conditions from dataset objects
if length(datasets) > 1
    fprintf('Obtaining sample parameters from dataset.\n')
end
incubation_time = cell2mat({datasets.incubation_time}');
concentration = cell2mat({datasets.concentration}');
replicate = cell2mat({datasets.replicate}');
CellType = {datasets.CellType}';

% loop through datasets and place data into prepared variables

if length(datasets) > 1
    disp('Construction of DOL data structure')
end
    
for i=1:length(datasets)
    
    if length(datasets) > 1
        dispProgress(i, length(datasets));
    end
    
    if (isempty(datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold)) ==0)
        Points_Blue_x{i} = datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold).x(:)';
        Points_Blue_y{i} = datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold).y(:)';
        Points_Blue_A{i} = datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold).intensity(:)';
        Points_Blue_c{i} = datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold).offset(:)';
        Points_Blue_s{i} = datasets(i).returnanalysis('channel','blue','fittype',fittype,'threshold',threshold).sigma(:)';
    end
    
    if (isempty(datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold)) ==0)
        Points_Green_x{i} = datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold).x(:)';
        Points_Green_y{i} = datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold).y(:)';
        Points_Green_A{i} = datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold).intensity(:)';
        Points_Green_c{i} = datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold).offset(:)';
        Points_Green_s{i} = datasets(i).returnanalysis('channel','green','fittype',fittype,'threshold',threshold).sigma(:)';
    end
    
    if (isempty(datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold)) ==0)
        Points_Red_x{i} = datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold).x(:)';
        Points_Red_y{i} = datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold).y(:)';
        Points_Red_A{i} = datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold).intensity(:)';
        Points_Red_c{i} = datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold).offset(:)';
        Points_Red_s{i} = datasets(i).returnanalysis('channel','red','fittype',fittype,'threshold',threshold).sigma(:)';
    end
end

end