function filterPointsDOLJF(matfilepath, thresholdA_Blue)

load(matfilepath);

if nargin<2
    thresholdA_Blue = 500;
end

wb = waitbar(0, 'Step 1: Initialize Variables', 'Name', 'RegistrationRoutine');

%% Keep only points with A > c

waitbar(0,wb, 'Step 5: Filtering Points');
tic

for i = 1:length(CellType)
    A2C_Blue{i} = Points_Blue_A{i} ./ Points_Blue_c{i};
    A2C_Green{i} = Points_Green_A{i} ./ Points_Green_c{i};
    A2C_Red{i} = Points_Red_A{i} ./ Points_Red_c{i};
end

dyes = unique(dye_combination);
Cells = {'gSEP', 'LynG'};
for j = 1:2
for i = 1:length(dyes)
    threshAmplitude(i,j,1) = prctile([Points_Green_A{strcmp(CellType, Cells{j}) & strcmp(dye_combination, dyes{i}) & strcmp(dye_load, 'no')}], 90);
    threshAmplitude(i,j,2) = prctile([Points_Red_A{strcmp(CellType, Cells{j}) & strcmp(dye_combination, dyes{i}) & strcmp(dye_load, 'no')}], 90);
end
end

% threshAmplitude

index_Green = cell(length(CellType),1);
index_Red = cell(length(CellType),1);

for i = 1:length(CellType)
    
time = toc;
remaining = (length(CellType) - i) * time / (i * 60);
    
waitbar(i/(length(CellType)),wb,...
    ['Step 5: Filtering Points. ' num2str(round(remaining,0)) ' min remaining']);

x = find(strcmp(dye_combination{i}, dyes));
y = find(strcmp(CellType{i},Cells));

index_Green{i} = Points_Green_A{i} > threshAmplitude(x,y,1);

Points_Green_A{i} = Points_Green_A{i}(index_Green{i});
Points_Green_c{i} = Points_Green_c{i}(index_Green{i});
Points_Green_s{i} = Points_Green_s{i}(index_Green{i});
Points_Green_x{i} = Points_Green_x{i}(index_Green{i});
Points_Green_y{i} = Points_Green_y{i}(index_Green{i});

index_Red{i} = Points_Red_A{i} > threshAmplitude(x,y,2);

Points_Red_A{i} = Points_Red_A{i}(index_Red{i});
Points_Red_c{i} = Points_Red_c{i}(index_Red{i});
Points_Red_s{i} = Points_Red_s{i}(index_Red{i});
Points_Red_x{i} = Points_Red_x{i}(index_Red{i});
Points_Red_y{i} = Points_Red_y{i}(index_Red{i});

index_Blue{i} = Points_Blue_A{i} > thresholdA_Blue;

Points_Blue_A{i} = Points_Blue_A{i}(index_Blue{i});
Points_Blue_c{i} = Points_Blue_c{i}(index_Blue{i});
Points_Blue_s{i} = Points_Blue_s{i}(index_Blue{i});
Points_Blue_x{i} = Points_Blue_x{i}(index_Blue{i});
Points_Blue_y{i} = Points_Blue_y{i}(index_Blue{i});

% fprintf('%s %s %3s %02d: Blue %d / %d; Green %d / %d; Red %d / %d\n',...
% dye_combination{i}, CellType{i}, dye_load{i}, replicate(i),...
% sum(index_Blue{i}), length(index_Blue{i}), sum(index_Green{i}), length(index_Green{i}),...
% sum(index_Red{i}), length(index_Red{i}))

end

%% Rotate Particles

waitbar(0,wb, 'Step 6: Rotate Particles');
tic

for i = 1:length(CellType)
    
time = toc;
remaining = (length(CellType) - i) * time / (i * 60);
    
waitbar(i/(length(CellType)),wb,...
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

MeanTranslationXBlueGreen = mean(TranslationXBlueGreen(strcmp (FlagGreen,'Registration successfull')));
MeanTranslationYBlueGreen = mean(TranslationYBlueGreen(strcmp (FlagGreen,'Registration successfull')));
MeanTranslationXBlueRed = mean(TranslationXBlueRed(strcmp (FlagRed,'Registration successfull')));
MeanTranslationYBlueRed = mean(TranslationYBlueRed(strcmp (FlagRed,'Registration successfull')));

%% Apply Registration

waitbar(0,wb, 'Step 8: Apply Registration');
tic

for i = 1:length(CellType)
    
time = toc;
remaining = (length(CellType) - i) * time / (i * 60);
    
waitbar(i/(length(CellType)),wb,...
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

for i = 1:length(CellType)
    
time = toc;
remaining = (length(CellType) - i) * time / (i * 60);
    
waitbar(i/(length(CellType)),wb,...
    ['Step 9: Calculate Colocalisation. ' num2str(round(remaining,0)) ' min remaining']);

if isempty(Points_Blue_x{i})
    fprintf('No points on cell %d in Blue Channel\n(%s %.2fh %.1fnM %02d)\n', i, CellType{i}, incubation_time(i), concentration(i), replicate(i));
    nopointsBlue = true;
else
    nopointsBlue = false;
end
if isempty(Points_RedReg_x{i})
    fprintf('No points on cell %d in Red Channel\n(%s %.2fh %.1fnM %02d)\n', i, CellType{i}, incubation_time(i), concentration(i), replicate(i));
    nopointsRed = true;
else
    nopointsRed = false;
end
if  isempty(Points_GreenReg_x{i})
    fprintf('No points on cell %d in Green Channel\n(%s %.2fh %.1fnM %02d)\n', i, CellType{i}, incubation_time(i), concentration(i), replicate(i));
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