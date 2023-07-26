if (exist('greenSimPoints', 'var') ~=1) || isempty(greenSimPoints)

    %% Create dataset
    green_rootdir = 'y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\3ChannelsMask\';
    greenSimPoints = pointSim.createImageSets(green_rootdir);

    %% Import data

    % u-track single emitter fit
    disp('Importing u-track single emitter fit')
    uTrackSinglePath = 'y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\u-track single\movieList_Density-Simulation_green_single.mat';
    greenSimPoints = pointSim.importUtrack(greenSimPoints, 'u-track single', uTrackSinglePath);

    % u-track multi emitter fit
    disp('Importing u-track multi emitter fit')
    uTrackMultiPath = 'y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\u-track multi\movieList_Density-Simulation_green_multi.mat';
    greenSimPoints = pointSim.importUtrack(greenSimPoints, 'u-track multi', uTrackMultiPath);

    % thunderStorm (single and multi emitter fit)
    disp('Importing thunderStorm data')
    datasets_path = 'y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\analysis\thunderSTORM\points_allDensities_complete.mat';
    greenSimPoints = pointSim.importThunderStorm(greenSimPoints, 'thunderStorm', datasets_path, green_rootdir);

    % ground truth coordinates
    disp('Importing ground truth coordinates')
    coords_dir = 'y:\DOL Calibration\Data\SimData_realistic\pointSim_raw_coords\';
    greenSimPoints = pointSim.importGroundTruth(greenSimPoints, coords_dir);

    % % OR
    % % load data
    % load('y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\analysis\greenSimPoints.mat');
    
end


%% perform registration

greenSimPoints.fullTransformation('ground truth', 'u-track single');
greenSimPoints.fullTransformation('ground truth', 'u-track multi');
greenSimPoints.fullTransformation('ground truth', 'thunderStorm single');
greenSimPoints.fullTransformation('ground truth', 'thunderStorm multi');

%% point filtering

% filter points by sigma with interval median+-stdev
disp('Filtering points by sigma')
setNames = {'u-track single' 'u-track multi'  'thunderStorm single' 'thunderStorm multi'};
sigmaFilterNames = strcat(setNames, ' fltr sigma');
[medianSigma, stdSigma] = sigmaHistogram(greenSimPoints, setNames);
filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
disp(filterSummary)
for i = 1:length(setNames)
    greenSimPoints.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
end

disp('Filtering points by amplitude percentile of background points')
backgroundSet = greenSimPoints.imageSetByDescriptor('simulatedDensity', 0);
ampFilterNames = strcat(sigmaFilterNames, ', amp');
greenSimPoints.filterPointsByPercentile(backgroundSet, 'u-track single fltr sigma', 'u-track single fltr sigma, amp', 'amplitude', 90, 'replace')
greenSimPoints.filterPointsByPercentile(backgroundSet, 'u-track multi fltr sigma', 'u-track multi fltr sigma, amp', 'amplitude', 90, 'replace')
greenSimPoints.filterPointsByPercentile(backgroundSet, 'thunderStorm single fltr sigma', 'thunderStorm single fltr sigma, amp', 'amplitude', 50, 'replace')
greenSimPoints.filterPointsByPercentile(backgroundSet, 'thunderStorm multi fltr sigma', 'thunderStorm multi fltr sigma, amp', 'amplitude', 50, 'replace')

%% calculate mean densities

greenSimPoints.calculateAllMeanDensities();

%% calculate colocalisation

pointSetNames = [setNames, sigmaFilterNames, ampFilterNames];
for n = 1:length(pointSetNames)
    greenSimPoints.colocalisation('ground truth', pointSetNames{n});
end