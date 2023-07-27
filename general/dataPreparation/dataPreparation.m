% This script prepares raw data for DOL Calibration analyis
% 
% First directories containing raw data (in folders named as defined in the
% mandatory folder structure template) can be selected.
% 
% Fiji scripts for averaging and segmentation (processAverageIJ.ijm) and
% for intensity analysis (processIntensitiesIJ.ijm) have to be located
% manually
%
% Output folders for 3Channels_Mask and Intensities.txt files have to be
% set manually
%
% Then the script performs the following for all defined experiment
% directories:
% - run script 1 (averaging and segmentation)
% - run script 2 (intensities)
% - move 3ChannelsMask folder
% - copy intensities.txt files with experiment name to selected folder
%
% Performing the analysis on a full dataset can take up to several hours

tic

%% Hard coding of necessary variables

% path to experiment folders
experiment_path = {...
    'y:\DOL Calibration\Data\felix\raw\Huh_TMR-Star_SiR-HA 15min'
    'y:\DOL Calibration\Data\felix\raw\Huh_TMR-Star_SiR-HA 30min'
    'y:\DOL Calibration\Data\felix\raw\Huh_TMR-Star_SiR-HA 3h'
    'y:\DOL Calibration\Data\felix\raw\Huh_TMR-Star_SiR-HA 60min'
    'y:\DOL Calibration\Data\felix\raw\Huh_TMR-Star_SiR-HA overnight'};
% experiment identifiers (e.g. 'felix_15min') (match indeces to path)
experiment_name = {...
    '30min'
    '15min'
    'overnight'
    '60min'
    '3h'};
% Data in MM format or Tif files
MM = 0;

% path for storing averaging results
outdir_3Channels_Mask = 'Y:\DOL Calibration\Data\felix\3ChannelsMask';
% path for storing intensities results
outdir_Intensities = 'Y:\DOL Calibration\Data\felix\Intensities';

% path to averaging script
IJ1 = 'e:\Software\Repos\dol\general\dataPreparation\processAverageIJ.ijm';
% path to intensity analysis script
IJ2 = 'e:\Software\Repos\dol\general\dataPreparation\processIntensitiesIJ.ijm';

%% include ij.jar and mij.jar

ijPath = fullfile(matlabroot, 'java', 'jar', 'ij.jar');
mijPath = fullfile(matlabroot, 'java', 'jar', 'mij.jar');

if not(exist(ijPath, 'file')) || not(exist(mijPath, 'file'))
    error(['ij.rar and/or mij.jar files are not installed. ' ...
        'Go to http://bigwww.epfl.ch/sage/soft/mij/ to download these files '...
        'and save them to your matlab folder: '...
        fullfile(matlabroot, 'java', 'jar')]);
end

eval(['javaaddpath ''' ijPath '''']);
eval(['javaaddpath ''' mijPath '''']);


%% Start Analysis

wb = waitbar(0,'','Name', 'Preparing Calibration Raw Data');

%% Convert MM data format to named tif files

waitbar(0,wb,'1/4 Converting MM data')
disp('Converting MM data');

if MM
    for i = 1:length(experiment_path)
        
        waitbar(i/length(experiment_path),wb);
        
        processMMData(experiment_path{i});
    
    end
end

%% perform averaging and intensities scripts on selected directories

waitbar(0.25,wb,'2/4 Averaging and segmentation')
disp('Averaging and segmentation');

MIJ.start;
    
for i = 1:length(experiment_path)
    
    msg = ['2/4 Averaging and segmentation ',...
        num2str(round(100*i/length(experiment_path)),3),...
        '%'];
    waitbar((1 + i/length(experiment_path))/4,wb,msg);
    
    directory = experiment_path{i};
    runAverageIJ(directory, IJ1);
    runIntensitiesIJ(directory, IJ2);
        
end

MIJ.exit;

%% copy and rename Intensities.txt files

waitbar(0.5,wb,'3/4 Copying Intensities.txt')
disp('Copying Intensities.txt');

for i = 1:length(experiment_path)
    
    msg = ['3/4 Copying Intensities.txt ',...
        num2str(round(100*i/length(experiment_path)),3),...
        '%'];
    waitbar((2 + i/length(experiment_path))/4,wb,msg);
    
    int_path = fullfile(experiment_path{i},'Intensities.txt');
    new_int_path = fullfile(outdir_Intensities, ['Intensities_', experiment_name{i}, '.txt']);
    copyfile(int_path, new_int_path);
    
end

%% move 3Channels_Mask folders

waitbar(0.75,wb,'4/4 Copying 3Channels_Mask folders')
disp('Copying 3Channels_Mask folders');

for i = 1:length(experiment_path)
    
    msg = ['4/4 Copying 3Channels_Mask folders ',...
        num2str(round(100*i/length(experiment_path)),3),...
        '%'];
    waitbar((3 + i/length(experiment_path))/4,wb,msg);
    
    rootDir = experiment_path{i};
    mkdir(outdir_3Channels_Mask,experiment_name{i});
    outDir = fullfile(outdir_3Channels_Mask,experiment_name{i});
    
    move3ChannelFolders(rootDir, outDir, 'move');
    
end

close(wb);

toc

%% Functions

function runAverageIJ(directory, macropath)

    path = [directory filesep];
    IJ=ij.IJ();
    
    args = path;
    
    IJ.runMacroFile(java.lang.String(macropath),java.lang.String(args));

end

function runIntensitiesIJ(directory, macropath)

    path = [directory filesep];
    IJ=ij.IJ();
    
    args = path;
    
    IJ.runMacroFile(java.lang.String(macropath),java.lang.String(args));
    
end