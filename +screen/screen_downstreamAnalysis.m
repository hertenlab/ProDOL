% function for downstream analysis 
% 
%  input
% - cellData
%   Data from cell analysis. Can be a structure containing all necessary
%   variables or a path to a mat-file containing these variables
% - varargin
%   cherryPick valid vector
%   selector for cells that will be used for mean value calculation etc.
%   Can be a logical vector or the path to a mat-file containing this
%   vector.

function data = screen_downstreamAnalysis(cellData, varargin)

    % load cellAnalysis data from input path or assign variables from input
    % structure 
    if isstruct(cellData)
        v2struct(cellData)
    elseif ischar(cellData)
        load(cellData)
    else
        error('Input error. cellData must be struct of cellAnalysis variables or path to mat-file')
    end
    
    if ~isempty(varargin)
        valid = varargin{1};
        if ischar(valid)
            load('valid')
            valid = cherryPick.valid;
        end
    else
        valid = true(length(replicate),1);
    end
    
    if ~exist('pixelSize','var')
        warning('No pixel size defined. Using default value 0.104 µm.')
        pixelSize = 0.104; %input('Enter pixel size in µm. Hit enter to confirm.\n');
    end
    
    if ~exist('tolerance','var')
        tolerance = (0.1:0.1:4);
    end
    
    % Global Parameters
    Cells = {'gSEP' 'LynG'};
    inctime = [0.25 0.5 1 3 16];
    concrange = [0 0.1 1 5 10 50 100 250];

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
    
    % Calculate particle Densities
    Density_Blue = BlueParticles./(AllAreas.*(pixelSize^2));
    Density_Green = GreenParticles./(AllAreas.*(pixelSize^2));
    Density_Red = RedParticles./(AllAreas.*(pixelSize^2));

    % Calculate colocalisation distance threshold
    Reg_both = (strcmp(FlagRed,'Registration successfull') |...
        strcmp(FlagRed,'successfull registration')) &...
        (strcmp(FlagGreen,'Registration successfull') |...
        strcmp(FlagGreen,'successfull registration'));
    FinalThresholdGreen = colocalisationThreshold(ColocalizationBlueGreen(Reg_both,:), ColocalizationGreenRandom(Reg_both,:), tolerance);
    FinalThresholdRed = colocalisationThreshold(ColocalizationBlueRed(Reg_both,:), ColocalizationRedRandom(Reg_both,:), tolerance);
    
    % Set DOL at colocalisation distance threshold
    DOL_Blue = pBlue(:,tolerance == FinalThresholdGreen);
    DOL_Green = pGreen(:,tolerance == FinalThresholdGreen);
    DOL_GreenRandom = pGreenRandom(:,tolerance == FinalThresholdGreen);
    DOL_Red = pRed(:,tolerance == FinalThresholdRed);
    DOL_RedRandom = pRedRandom(:,tolerance == FinalThresholdRed);
    
    % Correct DOL for particle density
    DOL_GreenC = pGreen./(-0.17*Density_Green+1);
    DOL_RedC = pRed./(-0.17*Density_Red+1);
    DOL_BlueC = pBlue./(-0.17*Density_Blue+1);
    
    % Rotate Variables to get the dimensions right
    BackgroundBlue = BackgroundBlue';
    BackgroundGreen = BackgroundGreen';
    BackgroundRed = BackgroundRed';
    
    % Calculate mean values
    [groups, concID, CellTypeID, timeID] = findgroups(concentration, CellType, incubation_time);

    data = meanAndStd(valid, groups, ...
        DOL_BlueC, DOL_Blue, Density_Blue, BlueParticles, BackgroundBlue,...
        DOL_GreenC, DOL_Green, DOL_GreenRandom, Density_Green, GreenParticles, BackgroundGreen,...
        DOL_RedC, DOL_Red, DOL_RedRandom, Density_Red, RedParticles, BackgroundRed);
    data.numCells = splitapply(@length,groups,groups);
    data.ID = struct('concentration', concID, 'CellType', CellTypeID,...
        'incubation_time', timeID);
    
end