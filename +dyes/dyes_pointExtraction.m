
movieListPath = 'y:\DOL Calibration\Data\JF-dyes\u-track\movieList_A-B-C-D.mat';


% Point Extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

movielist = load(movieListPath);
MDpaths = movielist.ML.movieDataFile_;

[PointDetectionParameters, Points_Blue_x, Points_Blue_y, Points_Blue_A,...
    Points_Blue_c, Points_Blue_s] = pointsFromMovieData(MDpaths, 2);
[~, Points_Green_x, Points_Green_y, Points_Green_A,...
    Points_Green_c, Points_Green_s] = pointsFromMovieData(MDpaths, 3);
[~, Points_Red_x, Points_Red_y, Points_Red_A,...
    Points_Red_c, Points_Red_s] = pointsFromMovieData(MDpaths, 5);

% Extract conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[CellType, dye_combination, dye_load, replicate] = ...
    dyes_conditionsFromString(MDpaths);

% Cell areas & Background %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Intensity_path = {...
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_JF549-HA_JF646-BG_A.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_JF646-BG_JF549-BG_B.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_SiR-HA_TMR-BG_D.txt'
    'y:\DOL Calibration\Data\JF-dyes\Intensitites\Intensities_Huh_TMR-HA_SiR-BG_C.txt'
};
    
% Segmentation areas and background intensities
% with identical indexing to cells
[AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = ...
    dyes_Intensities2mat(Intensity_path, CellType, dye_combination, dye_load, replicate);