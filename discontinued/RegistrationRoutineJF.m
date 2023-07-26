function RegistrationRoutineJF(movieListPath)

if not(nargin)
    movieListPath = 'y:\DOL Calibration\Data\JF-dyes\u-track\movieList_A-B-C-D.mat';
end

movielist = load(movieListPath);

path = movielist.ML.movieDataFile_;

%% Initialize Variables
tic
wb = waitbar(0, 'Step 1: Initialize Variables', 'Name', 'RegistrationRoutine');
% Sample Information
incubation_time = zeros(length(path),1);
concentration = zeros(length(path),1);
replicate = zeros(length(path),1);
CellType = cell(length(path),1);
% Point Detection Parameters
PointDetectionParameters = cell(length(path),1);
Points_Blue_x = cell(length(path),1);
Points_Blue_y = cell(length(path),1);
Points_Blue_A = cell(length(path),1);
Points_Blue_c = cell(length(path),1);
Points_Blue_s = cell(length(path),1);
Points_Green_x = cell(length(path),1);
Points_Green_y = cell(length(path),1);
Points_Green_A = cell(length(path),1);
Points_Green_c = cell(length(path),1);
Points_Green_s = cell(length(path),1);
Points_Red_x = cell(length(path),1);
Points_Red_y = cell(length(path),1);
Points_Red_A = cell(length(path),1);
Points_Red_c = cell(length(path),1);
Points_Red_s = cell(length(path),1);
% Rotated Points for random colocalization
Points_BlueRot_x = cell(length(path),1);
Points_BlueRot_y = cell(length(path),1);
Points_GreenRot_x = cell(length(path),1);
Points_GreenRot_y = cell(length(path),1);
Points_RedRot_x = cell(length(path),1);
Points_RedRot_y = cell(length(path),1);
% Registration
MeanScaleFactorXBlueGreen = 0.5523;
MeanScaleFactorYBlueGreen = 0.4909;
MeanScaleFactorXBlueRed = 0.6773;
MeanScaleFactorYBlueRed = 0.5682;
TranslationXBlueRed = zeros(length(path),1);
TranslationYBlueRed = zeros(length(path),1);
FlagRed = cell(length(path),1);
TranslationXBlueGreen = zeros(length(path),1);
TranslationYBlueGreen = zeros(length(path),1);
FlagGreen = cell(length(path),1);
Points_RedReg_x = cell(length(path),1);
Points_RedReg_y = cell(length(path),1);
SignalStrengthXBlueRed  = zeros(length(path),1);
SignalStrengthYBlueRed = zeros(length(path),1);
peakWidthXBlueRed = zeros(length(path),1);
peakWidthYBlueRed = zeros(length(path),1);
Points_GreenReg_x = cell(length(path),1);
Points_GreenReg_y = cell(length(path),1);
SignalStrengthXBlueGreen = zeros(length(path),1);
SignalStrengthYBlueGreen = zeros(length(path),1);
peakWidthXBlueGreen = zeros(length(path),1);
peakWidthYBlueGreen = zeros(length(path),1);
% Colocalisation Analysis
BlueParticles=zeros(length(path),1);
GreenParticles=zeros(length(path),1);
RedParticles=zeros(length(path),1);
BleachedParticles=zeros(length(path),1);
ColocalizationBlueGreen=zeros(length(path),40);
ColocalizationBlueRed=zeros(length(path),40);
pGreen=zeros(length(path),40);
pRed=zeros(length(path),40);
pBlue=zeros(length(path),40);
pBlue2=zeros(length(path),40);
pGreenRandom=zeros(length(path),40);
pRedRandom=zeros(length(path),40);
multipleassigned_particlesGreen=zeros(length(path),40);
multipleassigned_particlesRed=zeros(length(path),40);
ColocalizationRedRandom=zeros(length(path),40);
ColocalizationGreenRandom=zeros(length(path),40);
multipleassigned_particlesGreenRandom=zeros(length(path),40);
multipleassigned_particlesRedRandom=zeros(length(path),40);

%% Extract Conditions

waitbar(0, wb, 'Step 2: Extract Conditions');
tic

% only for Jf-dye experiments
[dye_combination, dye_load] = deal(cell(length(path),1));

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 2: Extract Conditions. ' num2str(round(remaining,0)) ' min remaining']);

% only for JF-dye experiments
[CellType{i}, dye_combination{i}, dye_load{i}, replicate(i)] = ...
    conditionsFromString_JF(path{i});

end

%% Point Detection

waitbar(0,wb, 'Step 3: Get Points');
tic

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 3: Get Points. ' num2str(round(remaining,0)) ' min remaining']);

[PointDetectionParameters{i}, Points_Blue_x{i}, Points_Blue_y{i}, Points_Blue_A{i},...
    Points_Blue_c{i}, Points_Blue_s{i}] = pointsFromMovieData(path{i}, 2);
[~, Points_Green_x{i}, Points_Green_y{i}, Points_Green_A{i},...
    Points_Green_c{i}, Points_Green_s{i}] = pointsFromMovieData(path{i}, 3);
[~, Points_Red_x{i}, Points_Red_y{i}, Points_Red_A{i},...
    Points_Red_c{i}, Points_Red_s{i}] = pointsFromMovieData(path{i}, 5);
end

%% Registration

waitbar(0,wb, 'Step 4: Registration');
tic

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 4: Registration. ' num2str(round(remaining,0)) ' min remaining']);

% perform registration if there are more than 10 points in channels
if isempty(Points_Blue_x{i}) || length(Points_Blue_x{i}) < 20
    warning(['Not enough points for registration on cell ' num2str(i)...
        ' in Blue Channel']);
    FlagRed{i} = 'Registration might not be reliable';
    FlagGreen{i} = 'Registration might not be reliable';
else
    
    if isempty(Points_Red_x{i}) || length(Points_Red_x{i}) < 20
        warning(['Not enough points for registration on cell ' num2str(i)...
        ' in Red Channel']);
        FlagRed{i} = 'Registration might not be reliable';
    else
    
        % Registration Red to Blue
        [TranslationXBlueRed(i), TranslationYBlueRed(i), FlagRed{i},...
            SignalStrengthXBlueRed(i), SignalStrengthYBlueRed(i),...
            peakWidthXBlueRed(i), peakWidthYBlueRed(i)] = ...
            SigiRegistrationCells(Points_Blue_x{i}, Points_Blue_y{i}, Points_Red_x{i}, Points_Red_y{i},...
            MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);
    end
    
    if isempty(Points_Green_x{i}) || length(Points_Green_x{i}) < 20
        warning(['Not enough points for registration on cell ' num2str(i)...
        ' in Green Channel']);
        FlagGreen{i} = 'Registration might not be reliable';
    else

        % Registration Green to Blue
        [TranslationXBlueGreen(i), TranslationYBlueGreen(i), FlagGreen{i},...
            SignalStrengthXBlueGreen(i), SignalStrengthYBlueGreen(i),...
            peakWidthXBlueGreen(i), peakWidthYBlueGreen(i)] = ...
            SigiRegistrationCells(Points_Blue_x{i}, Points_Blue_y{i}, Points_Green_x{i}, Points_Green_y{i},...
            MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);
    end
    
end

end

%% Keep only points with A > c

% waitbar(0,wb, 'Step 5: Filtering Points');
% tic
% 
% for i = 1:length(path)
%     
% time = toc;
% remaining = (length(path) - i) * time / (i * 60);
%     
% waitbar(i/(length(path)),wb,...
%     ['Step 5: Filtering Points. ' num2str(round(remaining,0)) ' min remaining']);
% 
% A2c = 2;
%     
% index_Blue{i} = (Points_Blue_A{i} ./ Points_Blue_c{i}) > 0.25;
% Points_Blue_A{i} = Points_Blue_A{i}(index_Blue{i});
% Points_Blue_c{i} = Points_Blue_c{i}(index_Blue{i});
% Points_Blue_s{i} = Points_Blue_s{i}(index_Blue{i});
% Points_Blue_x{i} = Points_Blue_x{i}(index_Blue{i});
% Points_Blue_y{i} = Points_Blue_y{i}(index_Blue{i});
% 
% index_Green{i} = (Points_Green_A{i} ./ Points_Green_c{i}) > 0.5;
% Points_Green_A{i} = Points_Green_A{i}(index_Green{i});
% Points_Green_c{i} = Points_Green_c{i}(index_Green{i});
% Points_Green_s{i} = Points_Green_s{i}(index_Green{i});
% Points_Green_x{i} = Points_Green_x{i}(index_Green{i});
% Points_Green_y{i} = Points_Green_y{i}(index_Green{i});
% 
% index_Red{i} = (Points_Red_A{i} ./ Points_Red_c{i}) > 0.33;
% Points_Red_A{i} = Points_Red_A{i}(index_Red{i});
% Points_Red_c{i} = Points_Red_c{i}(index_Red{i});
% Points_Red_s{i} = Points_Red_s{i}(index_Red{i});
% Points_Red_x{i} = Points_Red_x{i}(index_Red{i});
% Points_Red_y{i} = Points_Red_y{i}(index_Red{i});
% 
% fprintf('%s %.2fh %.1fnM %02d: Blue %d / %d; Green %d / %d; Red %d / %d\n',...
% CellType{i}, incubation_time(i), concentration(i), replicate(i),...
% sum(index_Blue{i}), length(index_Blue{i}), sum(index_Green{i}), length(index_Green{i}),...
% sum(index_Red{i}), length(index_Red{i}))
% 
% end

%% Rotate Particles

waitbar(0,wb, 'Step 6: Rotate Particles');
tic

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 6: Rotate Particles. ' num2str(round(remaining,0)) ' min remaining']);

Points_BlueRot_x{i} = Points_Blue_y{i};
Points_BlueRot_y{i} = 512 - Points_Blue_x{i};
Points_GreenRot_x{i} = Points_Green_y{i};
Points_GreenRot_y{i} = 512 - Points_Green_x{i};
Points_RedRot_x{i} = Points_Red_y{i};
Points_RedRot_y{i} = 512 - Points_Red_x{i};

end

%% Calculate Mean Translation 
waitbar(0,wb, 'Step 7: Calculate Mean Translation');

MeanTranslationXBlueGreen = 0.8; %mean(TranslationXBlueGreen(strcmp (FlagGreen,'Registration successfull')))
MeanTranslationYBlueGreen = -1.5; %mean(TranslationYBlueGreen(strcmp (FlagGreen,'Registration successfull')))
MeanTranslationXBlueRed = 0.5; %mean(TranslationXBlueRed(strcmp (FlagRed,'Registration successfull')))
MeanTranslationYBlueRed = -1.5; %mean(TranslationYBlueRed(strcmp (FlagRed,'Registration successfull')))

%% Apply Registration

waitbar(0,wb, 'Step 8: Apply Registration');
tic

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 8: Apply Registration. ' num2str(round(remaining,0)) ' min remaining']);

% Decide if registration values, correlated values or mean values are used
if strcmp(FlagRed{i},'Registration successfull') && ...
        strcmp(FlagGreen{i},'Registration might not be reliable')
    
    TranslationXBlueGreen(i) = (TranslationXBlueRed(i) + 0.18) / 1.41;
    TranslationYBlueGreen(i) = (TranslationYBlueRed(i) + 0.26 ) / 1.09;
    FlagGreen{i} = 'derived from correlation';
    
elseif strcmp(FlagRed{i},'Registration might not be reliable') && ...
        strcmp(FlagGreen{i},'Registration successfull')
    
    TranslationXBlueRed(i) = 1.41*TranslationXBlueGreen(i)-0.18;
    TranslationYBlueRed(i) = 1.09*TranslationYBlueGreen(i)-0.26;
    FlagRed{i}='derived from correlation';
    
elseif strcmp(FlagRed{i},'Registration might not be reliable') && ...
        strcmp(FlagGreen{i},'Registration might not be reliable')
    
    TranslationXBlueRed(i) = MeanTranslationXBlueRed;
    TranslationYBlueRed(i) = MeanTranslationYBlueRed;
    FlagRed{i}='Warning: mean Values used';
    
    TranslationXBlueGreen(i) = MeanTranslationXBlueGreen;
    TranslationYBlueGreen(i) = MeanTranslationYBlueGreen;
    FlagGreen{i}='Warning: mean Values used';
    
end

% Apply Registration
Points_RedReg_x{i} = (Points_Red_x{i} - (Points_Red_x{i} - 256)./256.*MeanScaleFactorXBlueRed)+TranslationXBlueRed(i);
Points_RedReg_y{i} = (Points_Red_y{i} - (Points_Red_y{i} - 256)./256.*MeanScaleFactorYBlueRed)+TranslationYBlueRed(i);
Points_GreenReg_x{i} = (Points_Green_x{i} - (Points_Green_x{i} - 256)./256.*MeanScaleFactorXBlueGreen)+TranslationXBlueGreen(i);
Points_GreenReg_y{i} = (Points_Green_y{i} - (Points_Green_y{i} - 256)./256.*MeanScaleFactorYBlueGreen)+TranslationYBlueGreen(i);
 
end

%% Colocalisation Analysis

waitbar(0,wb, 'Step 9: Calculate Colocalisation');
tic

for i = 1:length(path)
    
time = toc;
remaining = (length(path) - i) * time / (i * 60);
    
waitbar(i/(length(path)),wb,...
    ['Step 9: Calculate Colocalisation. ' num2str(round(remaining,0)) ' min remaining']);

if isempty(Points_Blue_x{i})
    warning(['No points on cell ' num2str(i) ' in Blue Channel']);
    nopointsBlue = true;
else
    nopointsBlue = false;
end
if isempty(Points_RedReg_x{i})
    warning(['No points on cell ' num2str(i) ' in Red Channel']);
    nopointsRed = true;
else
    nopointsRed = false;
end
if  isempty(Points_GreenReg_x{i})
    warning(['No points on cell ' num2str(i) ' in Green Channel']);
    nopointsGreen = true;
else
    nopointsGreen = false;
end

%%%%%%%%%%%%%%%%%%%%%%%
% Degree of Labelling
%%%%%%%%%%%%%%%%%%%%%%%

j=0;
for k=0.1:0.1:4
    ToleranceBlueGreenX=k;
    ToleranceBlueGreenY=k;

    ToleranceBlueRedX=k;
    ToleranceBlueRedY=k;

    j=j+1;
    if not(nopointsBlue | nopointsRed)
    [BlueParticles(i), RedParticles(i), ColocalizationBlueRed(i,j), multipleassigned_particlesRed(i,j)] = ...
        detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
        Points_RedReg_x{i}, Points_RedReg_y{i}, ...
        ToleranceBlueRedX, ToleranceBlueRedY);

    [~, ~, ColocalizationRedRandom(i,j),multipleassigned_particlesRedRandom(i,j)] = ...
        detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i},...
        Points_RedRot_x{i}, Points_RedRot_y{i}, ...
        ToleranceBlueRedX, ToleranceBlueRedY);
    
    pBlue2(i,j)=ColocalizationBlueRed(i,j)/RedParticles(i);
    pRed(i,j)=ColocalizationBlueRed(i,j)/BlueParticles(i);
    pRedRandom(i,j)=ColocalizationRedRandom(i,j)/BlueParticles(i);
    
    end
    if not(nopointsBlue | nopointsGreen)
    [~, GreenParticles(i), ColocalizationBlueGreen(i,j),multipleassigned_particlesGreen(i,j)] = ...
        detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
        Points_GreenReg_x{i}, Points_GreenReg_y{i}, ...
        ToleranceBlueGreenX, ToleranceBlueGreenY);

    [~, ~, ColocalizationGreenRandom(i,j),multipleassigned_particlesGreenRandom(i,j)] = ...
        detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
        Points_GreenRot_x{i}, Points_GreenRot_y{i}, ...
        ToleranceBlueGreenX, ToleranceBlueGreenY);
    
    
    pBlue(i,j)=ColocalizationBlueGreen(i,j)/GreenParticles(i);
    pGreen(i,j)=ColocalizationBlueGreen(i,j)/BlueParticles(i);
    pGreenRandom(i,j)=ColocalizationGreenRandom(i,j)/BlueParticles(i);
    end
    

end

end

close(wb);

variables = who;
for l=1:length(variables)
    assignin('caller', variables{l}, eval(variables{l}))
end

end