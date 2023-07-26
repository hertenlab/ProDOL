% Script to collect point coordinates, identifiers and properties for the
% screen experiments.

movieListPath = 'y:\DOL Calibration\Data\sigi\u-track\movieList_all.mat';
savePath = '';

%
% collect points from u-track movieList
% 

movielist = load(movieListPath);
MDpaths = movielist.ML.movieDataFile_;

[PointDetectionParameters, Points_Blue_x, Points_Blue_y, Points_Blue_A,...
    Points_Blue_c, Points_Blue_s] = pointsFromMovieData(MDpaths, 2);
[~, Points_Green_x, Points_Green_y, Points_Green_A,...
    Points_Green_c, Points_Green_s] = pointsFromMovieData(MDpaths, 3);
[~, Points_Red_x, Points_Red_y, Points_Red_A,...
    Points_Red_c, Points_Red_s] = pointsFromMovieData(MDpaths, 5);

% 
% read conditions from u-track movieList
% 

[CellType, incubation_time, concentration, replicate] = ...
    screen_conditionsFromString(MDpaths);


% 
% read cell areas and background intensities from files generated by
% ImangeJ scripts
% 

Intensity_path = {...
    'y:\DOL Calibration\Data\sigi\Intensities\Intensities_15min.txt'
    'y:\DOL Calibration\Data\sigi\Intensities\Intensities_30min.txt'
    'y:\DOL Calibration\Data\sigi\Intensities\Intensities_3h.txt'
    'y:\DOL Calibration\Data\sigi\Intensities\Intensities_60min.txt'
    'y:\DOL Calibration\Data\sigi\Intensities\Intensities_overnight.txt'
};


[AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = ...
    screen_Intensities2mat(Intensity_path, CellType, incubation_time, concentration, replicate);


% 
% Save variables under savePath. If savePath is empty vars are not saved
% 

if ~isempty(savePath)
    vars = who;
    save(savePath, vars)
end