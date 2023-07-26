if (exist('redSimPoints', 'var') ~=1) || isempty(redSimPoints)

    %% Create dataset
    red_rootdir = 'y:\DOL Calibration\Data\SimData_realistic\red_background\Density-Simulation\3ChannelsMask\';
    redSimPoints = pointSim.createImageSets(red_rootdir);

    %% Import data

    % u-track single emitter fit
    disp('Importing u-track single emitter fit')
    uTrackSinglePath = 'Y:\DOL Calibration\Data\SimData_realistic\red_background\Density-Simulation\u-track single\movieList_Density-Simulation_red_single.mat';
    redSimPoints = pointSim.importUtrack(redSimPoints, 'u-track single', uTrackSinglePath);

    % u-track multi emitter fit
    disp('Importing u-track multi emitter fit')
    uTrackMultiPath = 'Y:\DOL Calibration\Data\SimData_realistic\red_background\Density-Simulation\u-track multi\movieList_Density-Simulation_red_multi.mat';
    redSimPoints = pointSim.importUtrack(redSimPoints, 'u-track multi', uTrackMultiPath);

    % thunderStorm (single and multi emitter fit)
    disp('Importing thunderStorm data')
    datasets_path = 'Y:\DOL Calibration\Data\SimData_realistic\red_background\Density-Simulation\analysis\thunderSTORM\points_allDensities_complete.mat';
    redSimPoints = pointSim.importThunderStorm(redSimPoints, 'thunderStorm', datasets_path, red_rootdir);

    % ground truth coordinates
    disp('Importing ground truth coordinates')
    coords_dir = 'y:\DOL Calibration\Data\SimData_realistic\pointSim_raw_coords\';
    redSimPoints = pointSim.importGroundTruth(redSimPoints, coords_dir);

    % % OR
    % % load data
    % load('y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\analysis\greenSimPoints.mat');
    
end


%% perform registration

redSimPoints.fullTransformation('ground truth', 'u-track single');
redSimPoints.fullTransformation('ground truth', 'u-track multi');
redSimPoints.fullTransformation('ground truth', 'thunderStorm single');
redSimPoints.fullTransformation('ground truth', 'thunderStorm multi');

%% point filtering

% filter points by sigma with interval median+-stdev
disp('Filtering points by sigma')
setNames = {'u-track single' 'u-track multi'  'thunderStorm single' 'thunderStorm multi'};
sigmaFilterNames = strcat(setNames, ' fltr sigma');
[medianSigma, stdSigma] = sigmaHistogram(redSimPoints, setNames);
filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
disp(filterSummary)
for i = 1:length(setNames)
    redSimPoints.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
end

disp('Filtering points by amplitude percentile of background points')
backgroundSet = redSimPoints.imageSetByDescriptor('simulatedDensity', 0);
ampFilterNames = strcat(sigmaFilterNames, ', amp');
redSimPoints.filterPointsByPercentile(backgroundSet, 'u-track single fltr sigma', 'u-track single fltr sigma, amp', 'amplitude', 90, 'replace');
redSimPoints.filterPointsByPercentile(backgroundSet, 'u-track multi fltr sigma', 'u-track multi fltr sigma, amp', 'amplitude', 90, 'replace');
redSimPoints.filterPointsByPercentile(backgroundSet, 'thunderStorm single fltr sigma', 'thunderStorm single fltr sigma, amp', 'amplitude', 50, 'replace');
redSimPoints.filterPointsByPercentile(backgroundSet, 'thunderStorm multi fltr sigma', 'thunderStorm multi fltr sigma, amp', 'amplitude', 50, 'replace');

%% calculate mean densities

redSimPoints.calculateAllMeanDensities();

%% calculate recall and false-positive

pointSetNames = [setNames, sigmaFilterNames, ampFilterNames];
for n = 1:length(pointSetNames)
    redSimPoints.colocalisation('ground truth', pointSetNames{n});
end