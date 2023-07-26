% Load Workspace variables from file or import from u-track movielist and Intensities.txt

clear all

% load('y:\DOL Calibration\Data\felix\analysis\15-30-60auto-3h-overnight.mat');

movielistpath = 'y:\DOL Calibration\Data\JF-dyes\u-track\movieList_A-B-C-D.mat';

% Registration routine
RegistrationRoutineJF(movielistpath);

load('y:\DOL Calibration\Data\JF-dyes\analysis\JF_analysis.mat');

Intensity_path = {...
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_JF549-HA_JF646-BG_A.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_JF646-BG_JF549-BG_B.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_SiR-HA_TMR-BG_D.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_TMR-HA_SiR-BG_C.txt'
};
    
% Segmentation areas and background intensities
% with identical indexing to cells
[AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = ...
    Intensities2matJF(Intensity_path, CellType, dye_combination, dye_load, replicate);

% Single emitter Intensities
[SingleEmitter_Blue, SingleEmitter_Green, SingleEmitter_Red] = deal([]);

clear('userinput');
variables = who;
uisave(variables, 'y:\DOL Calibration\Data\JF-dyes\analysis');


