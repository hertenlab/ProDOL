function outputFilepath = extractConditionData(input_matfilepath)

load(input_matfilepath);
[pathstr, matname, ~] = fileparts(input_matfilepath);

colors = {'Red', 'Green', 'Blue'};
proteins = {'SNAP-tag', 'HaloTag', 'GFP'};        % Order according to colors
pixelSize = 0.104;         % in µm

validpath = 'y:\DOL Calibration\Data\sigi\analysis\sigi_base_cherryPicking.mat';
load(validpath);
valid = cherryPick.valid;

exp_system = matname;

%% Global Parameters

Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];

sampleName = cell(2,5,8);
for l=1:2
for t=1:5
for c=1:8
sampleName{l,t,c} = [Cells{l} ' ' num2str(inctime(t)) 'h ' num2str(concrange(c)) 'nM'];
sampleConc{l,c,t} = concrange(c);
sampleTime{l,c,t} = inctime(t);
sampleCellType{l,c,t} = Cells{l};
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

%Select all replicates where the registration worked in both channels
Selection = (strcmp(FlagRed,'Registration successfull') |...
    strcmp(FlagRed,'successfull registration')) &...
    (strcmp(FlagGreen,'Registration successfull') |...
    strcmp(FlagGreen,'successfull registration'));

SelectionMatrix = Selection;
for i=1:39
    SelectionMatrix=[SelectionMatrix Selection];
end

ColGreen = ColocalizationBlueGreen(SelectionMatrix);
ColGreen = reshape(ColGreen,[length(ColGreen)/40,40]);
ColGreenRandom = ColocalizationGreenRandom(SelectionMatrix);
ColGreenRandom = reshape(ColGreenRandom,[length(ColGreenRandom)/40,40]);
ColRed = ColocalizationBlueRed(SelectionMatrix);
ColRed = reshape(ColRed,[length(ColRed)/40,40]);
ColRedRandom = ColocalizationRedRandom(SelectionMatrix);
ColRedRandom = reshape(ColRedRandom,[length(ColRedRandom)/40,40]);

% Find Tolerance Threshold as mean value
meanGreen = mean(ColGreen,1);
meanGreenRandom = mean(ColGreenRandom,1);
meanRed = mean(ColRed,1);
meanRedRandom = mean(ColRedRandom,1);

[~,indexGreen] = max(meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom));
ToleranceGreen = round(indexGreen)/10;
FinalThresholdGreen = ToleranceGreen;

[~,indexRed] = max(meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom));
ToleranceRed = round(indexRed)/10;
FinalThresholdRed = ToleranceRed; %1.4;

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
    
pxSize = pixelSize * ones(length(CellType),1);

if strfind(exp_system, 'felix')
    pixelSize_2 = 0.104;
    index = incubation_time == 0.25 | incubation_time == 0.5;
    pxSize(index) = pixelSize_2;
end


praw_Blue = pBlue;
pRaw_Green = pGreen;
pRaw_Red = pRed;

Density_Blue = BlueParticles./(AllAreas.*(pxSize.^2));
Density_Green = GreenParticles./(AllAreas.*(pxSize.^2));
Density_Red = RedParticles./(AllAreas.*(pxSize.^2));

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
            condition_index = valid & ...
                isfinite(pGreen) &...
                concentration == concrange(c) & ...
                incubation_time == inctime(t) & ...
                strcmp (CellType,Cells{l});
            %DOL
            MeanDOLGreen(l,t,c) = mean(pGreen(condition_index));
            StdDOLGreen(l,t,c) = std(pGreen(condition_index));

            MeanDOLRed(l,t,c) = mean(pRed(condition_index));
            StdDOLRed(l,t,c) = std(pRed(condition_index));

            MeanDOLBlue(l,t,c) = mean(pBlue(condition_index));
            StdDOLBlue(l,t,c) = std(pBlue(condition_index));

            MeanDOLGreenRandom(l,t,c) = mean(pGreenRandom(condition_index));
            MeanDOLRedRandom(l,t,c) = mean(pRedRandom(condition_index));

            %particle densities
            MeanParticlesGreen(l,t,c) = mean(Density_Green(condition_index));
            StdParticlesGreen(l,t,c) = std(Density_Green(condition_index));

            MeanParticlesRed(l,t,c) = mean(Density_Red(condition_index));
            StdParticlesRed(l,t,c) = std(Density_Red(condition_index));

            MeanParticlesBlue(l,t,c) = mean(Density_Blue(condition_index));
            StdParticlesBlue(l,t,c) = std(Density_Blue(condition_index));
            
            %Background
            BackgroundGreen_all(l,t,c) = mean(BackgroundGreen(condition_index));
            StdBackgroundGreen_all(l,t,c) = std(BackgroundGreen(condition_index));

            BackgroundRed_all(l,t,c) = mean(BackgroundRed(condition_index));
            StdBackgroundRed_all(l,t,c) = std(BackgroundRed(condition_index));

            BackgroundBlue_all(l,t,c) = mean(BackgroundBlue(condition_index));
            StdBackgroundBlue_all(l,t,c) = std(BackgroundBlue(condition_index));

            
            %numCells
            numCells(l,t,c) = sum(condition_index);
            
            % Number of Particles
            numPoints{l,t,c}.r = length([Points_Red_A{condition_index}]);
            numPoints{l,t,c}.g = length([Points_Green_A{condition_index}]);
            numPoints{l,t,c}.b = length([Points_Blue_A{condition_index}]);
            totalParticlesBlue(l,t,c) = sum(BlueParticles(condition_index));
            totalParticlesGreen(l,t,c) = sum(GreenParticles(condition_index));
            totalParticlesRed(l,t,c) = sum(RedParticles(condition_index));
                        
        end

    end

end

%% Results table
variables = {...
    'matname'
    'colors'
    'proteins'
    'pixelSize'
    'FinalThresholdGreen'
    'FinalThresholdRed'
    'meanGreen'
    'meanGreenRandom'
    'meanRed'
    'meanRedRandom'
    'sampleTime'
    'sampleConc'
    'sampleCellType'
    'MeanDOLGreen'
    'StdDOLGreen'
    'MeanDOLRed'
    'StdDOLRed'
    'MeanDOLBlue'
    'StdDOLBlue'
    'MeanDOLGreenRandom'
    'MeanDOLRedRandom'
    'MeanParticlesGreen'
    'StdParticlesGreen'
    'MeanParticlesRed'
    'StdParticlesRed'
    'MeanParticlesBlue'
    'StdParticlesBlue'
    'BackgroundGreen_all'
    'StdBackgroundGreen_all'
    'BackgroundBlue_all'
    'StdBackgroundBlue_all'
    'BackgroundRed_all'
    'StdBackgroundRed_all'
    'numCells'
    'totalParticlesBlue'
    'totalParticlesGreen'
    'totalParticlesRed'};

outputFilepath = fullfile(pathstr, [matname '_ConditionData.mat']);
save(outputFilepath, variables{:})

end
