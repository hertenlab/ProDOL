function downstreamAnalysis(data_filepath, validpath, colors, proteins, saveData)

if nargin
    registration_filepath = data_filepath;
else
    registration_filepath = 'y:\DOL Calibration\Data\felix\analysis\felix_rg-A2C-0.2_b-80-percentile.mat';
    data_filepath = registration_filepath;
    saveData = 0;
    colors = {'Red', 'Green', 'Blue'};
    proteins = {'SNAP-tag', 'HaloTag', 'GFP'};        % Order according to colors
    validpath = 'y:\DOL Calibration\Data\sigi\analysis\sigi_base_cherryPicking.mat'; 
end

load(registration_filepath);
load(validpath);
valid = cherryPick.valid;

valid = true(length(replicate),1);    %% uncomment to ignore cherryPick

registration_filepath = data_filepath;
[pathstr,name,~] = fileparts(registration_filepath);
if saveData
    mkdir(pathstr,name);
    savefolder = fullfile(pathstr,name);
end
exp_system = name;

%% Global Parameters

LynG = strcmp(CellType, 'LynG');
gSEP = strcmp(CellType, 'gSEP');
Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];

sampleName = cell(2,5,8);
for l=1:2
for t=1:5
for c=1:8
sampleName{l,t,c} = [Cells{l} ' ' num2str(inctime(t)) 'h ' num2str(concrange(c)) 'nM'];
end
end
end

conditions = cell(length(CellType),1);
for i=1:length(CellType)
conditions{i} = [CellType{i} ' ' num2str(incubation_time(i)) 'h ' num2str(concentration(i)) 'nM'];
conditions{i} = strrep(conditions{i},'16h','overnight');
end

clr_c = parula(8);
clr_t = lines(5);

%% Colocalisation Threshold

FinalThresholdGreen = ColocalisationThreshold(FlagRed, FlagGreen, ColocalizationBlueGreen, ColocalizationGreenRandom);
FinalThresholdRed = ColocalisationThreshold(FlagRed, FlagGreen, ColocalizationBlueRed, ColocalizationRedRandom);

% original values for all colocalisation thresholds are stored in DOL
DOLRawGreen = pGreen;
DOLRawRed = pRed;
DOLRawBlue = pBlue;
DOLRawGreenRandom = pGreenRandom;
DOLRawRedRandom = pRedRandom;


%% Create 5x8 DOL-Result and number of particle-matrices
%%Create matrix of mean values of labeling efficiencies(x-Axis: concentration 0 to 250nM, y-Axis:
%%incubation time 0.25 to 16 h, 5x8 matrix

pGreen = pGreen(:,round(FinalThresholdGreen*10));
pBlue = pBlue(:,round(FinalThresholdGreen*10));
pGreenRandom = pGreenRandom(:,round(FinalThresholdGreen*10));
pRed = pRed(:,round(FinalThresholdRed*10));
pRedRandom = pRedRandom(:,round(FinalThresholdRed*10));

%% Calculate Particle Densities
% Pixel size in µm
% pixelSize = 0.104;

pixelSize = 0.095 * ones(length(replicate),1);

Density_Blue = BlueParticles./(AllAreas.*(pixelSize.^2));
Density_Green = GreenParticles./(AllAreas.*(pixelSize.^2));
Density_Red = RedParticles./(AllAreas.*(pixelSize.^2));

%%Correct DOL for particle density
pGreen = pGreen./(-0.17*Density_Green+1);
pRed = pRed./(-0.17*Density_Red+1);
pBlue = pBlue./(-0.17*Density_Blue+1);

%Normalize Background to single emitter intensity
if exist(SingleEmitter_Blue)
    BackgroundBlue = BackgroundBlue./mean(SingleEmitter_Blue);
    BackgroundGreen = BackgroundGreen./mean(SingleEmitter_Green);
    BackgroundRed = BackgroundRed./mean(SingleEmitter_Red);
end

%% Parse Data for each condition

[MeanDOLGreen,...
StdDOLGreen,...
MeanDOLRed,...
StdDOLRed,...
MeanDOLBlue,...
StdDOLBlue,...
MeanDOLGreenRandom,...
MeanDOLRedRandom,...
MeanParticlesGreen,...
StdParticlesGreen,...
MeanParticlesRed,...
StdParticlesRed,...
MeanParticlesBlue,...
StdParticlesBlue,...
BackgroundGreen_all,...
StdBackgroundGreen_all,...
BackgroundBlue_all,...
StdBackgroundBlue_all,...
BackgroundRed_all,...
StdBackgroundRed_all,...
numCells]...
    = deal(zeros(2,5,8));

% BackgroundGreenall (and others) are obsolete with all backgrounds in
% BackgroundBlue

sigDOL_Halo_SNAP=zeros(5,8);

for l=1:2
    for c=1:8
        for t=1:5
            [~,sigDOL_Halo_SNAP(t,c)]=ranksum(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')),pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));

            CellIndex = valid & ...
                concentration == concrange(c) & ...
                incubation_time == inctime(t) & ...
                strcmp(CellType,Cells{l});
            
            %DOL
            MeanDOLGreen(l,t,c) = mean(CellIndex & isfinite(pGreen));
            StdDOLGreen(l,t,c) = std(CellIndex & isfinite(pGreen));

            MeanDOLRed(l,t,c) = mean(CellIndex & isfinite(pRed));
            StdDOLRed(l,t,c) = std(CellIndex & isfinite(pRed));

            MeanDOLBlue(l,t,c) = mean(CellIndex & isfinite(pBlue));
            StdDOLBlue(l,t,c) = std(CellIndex & isfinite(pBlue));

            MeanDOLGreenRandom(l,t,c) = mean(CellIndex & isfinite(pGreenRandom));
            MeanDOLRedRandom(l,t,c) = mean(CellIndex & isfinite(pGreenRandom));

            %particle densities
            MeanParticlesGreen(l,t,c) = mean(CellIndex & isfinite(Density_Green));
            StdParticlesGreen(l,t,c) = std(CellIndex & isfinite(Density_Green));

            MeanParticlesRed(l,t,c) = mean(CellIndex & isfinite(Density_Red));
            StdParticlesRed(l,t,c) = std(CellIndex & isfinite(Density_Red));

            MeanParticlesBlue(l,t,c) = mean(CellIndex & isfinite(Density_Blue));
            StdParticlesBlue(l,t,c) = std(CellIndex & isfinite(Density_Blue));
            
            %Background
            BackgroundGreen_all(l,t,c) = mean(BackgroundGreen(CellIndex));
            StdBackgroundGreen_all(l,t,c) = std(BackgroundGreen(CellIndex));

            BackgroundRed_all(l,t,c) = mean(BackgroundRed(CellIndex));
            StdBackgroundRed_all(l,t,c) = std(BackgroundRed(CellIndex));

            BackgroundBlue_all(l,t,c) = mean(BackgroundBlue(CellIndex));
            StdBackgroundBlue_all(l,t,c) = std(BackgroundBlue(CellIndex));
            
            %numCells
            numCells(l,t,c) = sum((CellIndex));

            
        end

    end

end

%% break before plots

beep;
