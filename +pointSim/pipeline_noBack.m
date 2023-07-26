if (exist('voidSimPoints', 'var') ~=1) || isempty(voidSimPoints)

    %% Create dataset
    void_rootdir = 'y:\DOL Calibration\Data\SimData_realistic\no_background\pointImages';
    voidSimPoints = imageset.empty;
    voidSimPoints = pointSim.createImageSets(void_rootdir);

    %% Import data
    
    % thunderStorm (single and multi emitter fit)
    disp('Importing thunderStorm data')
    ilPath = 'y:\DOL Calibration\Data\SimData_realistic\no_background\thunderSTORM_pointImages\image_list.txt';
    root_dir = 'y:\DOL Calibration\Data\SimData_realistic\no_background\thunderSTORM_pointImages';
    datasets_path = 'y:\DOL Calibration\Data\SimData_realistic\no_background\thunderSTORM_pointImages\datasets_pointSim_noBackground.mat';
    
    % (if necessary) create movie and analysis objects from csv-files
    datasets = importTSeff(ilPath,root_dir);
    for i = 1:length(datasets)
        [datasets(i).analysis.channel] = deal('blue');
    end
    save(datasets_path, 'datasets');
    
    voidSimPoints = pointSim.importThunderStorm(voidSimPoints, 'thunderStorm', datasets_path, void_rootdir);

    % ground truth coordinates
    disp('Importing ground truth coordinates')
    coords_dir = 'y:\DOL Calibration\Data\SimData_realistic\pointSim_raw_coords\';
    voidSimPoints = pointSim.importGroundTruth(voidSimPoints, coords_dir);

    % % OR
    % % load data
    % load('y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\analysis\greenSimPoints.mat');
    
end


%% perform registration

voidSimPoints.fullTransformation('ground truth', 'thunderStorm threshold 1.5 single');
voidSimPoints.fullTransformation('ground truth', 'thunderStorm threshold 1.5 multi');
voidSimPoints.fullTransformation('ground truth', 'thunderStorm threshold 2.0 single');
voidSimPoints.fullTransformation('ground truth', 'thunderStorm threshold 2.0 multi');

%% point filtering

% filter points by sigma with interval median+-stdev
disp('Filtering points by sigma')
setNames = {'thunderStorm threshold 1.5 single'
            'thunderStorm threshold 2.0 single'
            'thunderStorm threshold 1.5 multi'
            'thunderStorm threshold 2.0 multi'};
sigmaFilterNames = strcat(setNames, ' fltr sigma');
[medianSigma, stdSigma] = sigmaHistogram(voidSimPoints, setNames);
filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
disp(filterSummary)
for i = 1:length(setNames)
    voidSimPoints.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
end

%% calculate mean densities

voidSimPoints.calculateAllMeanDensities();

%% calculate colocalisation

pointSetNames = [setNames; sigmaFilterNames];
for n = 1:numel(pointSetNames)
    voidSimPoints.colocalisation('ground truth', pointSetNames{n});
end