% mat-file path containing cellAnalysis data
cellData = '';
valid = true(length(replicate),1);


% load data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(cellData)
    load(cellData)
end

% correct falsely labeled cells

dye_load = dyes_switchHigh2no(CellType, dye_combination, dye_load);


% Densities and DOL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Calculate Particle Densities
pixelSize = 0.095 * ones(length(replicate),1);

Density_Blue = BlueParticles./(AllAreas.*(pixelSize.^2));
Density_Green = GreenParticles./(AllAreas.*(pixelSize.^2));
Density_Red = RedParticles./(AllAreas.*(pixelSize.^2));

% Calculate colocalisation distance threshold
Reg_both = (strcmp(FlagRed,'Registration successfull') |...
    strcmp(FlagRed,'successfull registration')) &...
    (strcmp(FlagGreen,'Registration successfull') |...
    strcmp(FlagGreen,'successfull registration'));
FinalThresholdGreen = colocalisationThreshold(ColocalizationBlueGreen(Reg_both,:),...
    ColocalizationGreenRandom(Reg_both,:), tolerance);
FinalThresholdRed = colocalisationThreshold(ColocalizationBlueRed(Reg_both,:), ...
    ColocalizationRedRandom(Reg_both,:), tolerance);

% Set DOL at colocalisation distance threshold
DOL_Blue = pBlue(:,tolerance == FinalThresholdGreen);
DOL_Green = pGreen(:,tolerance == FinalThresholdGreen);
DOL_GreenRandom = pGreenRandom(:,tolerance == FinalThresholdGreen);
DOL_Red = pRed(:,tolerance == FinalThresholdRed);
DOL_RedRandom = pRedRandom(:,tolerance == FinalThresholdRed);

% Correct DOL for particle density
DOL_GreenC = DOL_Green./(-0.17*Density_Green+1);
DOL_RedC = DOL_Red./(-0.17*Density_Red+1);
DOL_BlueC = DOL_Blue./(-0.17*Density_Blue+1);

% Rotate Variables to get the dimensions right
BackgroundBlue = BackgroundBlue';
BackgroundGreen = BackgroundGreen';
BackgroundRed = BackgroundRed';


% Map channels to dyes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dyes = {'JF549-HA', 'JF646-BG', 'JF646-HA', 'JF549-BG', 'TMR-HA', 'SiR-BG', 'SiR-HA', 'TMR-BG'};
combination = {'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D'};

[DOL_HaloTag, DOL_SnapTag, Density_HaloTag, Density_SnapTag] = ...
    deal(zeros(1,length(CellType)));

for i = 1:length(CellType)
    if any(strcmp(dye_combination{i}, {'A', 'C'}))
        DOL_HaloTag(i) = DOL_GreenC(i);
        DOL_SnapTag(i) = DOL_RedC(i);
        Density_HaloTag(i) = Density_Green(i);
        Density_SnapTag(i) = Density_Red(i);
    elseif any(strcmp(dye_combination{i}, {'B', 'D'}))
        DOL_HaloTag(i) = DOL_RedC(i);
        DOL_SnapTag(i) = DOL_GreenC(i);
        Density_HaloTag(i) = Density_Red(i);
        Density_SnapTag(i) = Density_Green(i);
    end
end

% Calculate mean values over replicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[groups, ID_combi, ID_load, ID_ct] = findgroups(dye_combination,dye_load,CellType);

data = meanAndStd(valid, groups, ...
        DOL_HaloTag, DOL_SnapTag, Density_HaloTag, Density_SnapTag);
    
data.numCells = splitapply(@length,groups,groups);
data.ID = struct('dye_combination', ID_combi, 'CellType', ID_ct,...
    'dye_load', ID_load);
