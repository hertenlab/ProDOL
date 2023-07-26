%% dataset construction
if (exist('dolSimRed', 'var') ~=1) || isempty(dolSimRed)
    % create imageset
    red_rootdir = 'y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\3Channels_Mask';
    dolSimRed = dolSim.createImageSets(red_rootdir);

    % import thunderStorm (single and multi emitter fit)
    disp('Importing thunderStorm data')
    csvDir = 'y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\thunderSTORM';
    matDir = 'y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\thunderSTORM\SimsVaryDOL_red_datasets_withoutDoubleEntry.mat';
    dolSimRed = dolSim.importThunderStorm(dolSimRed, 'thunderStorm', matDir, red_rootdir);

    % import ground truth data
    disp('Importing ground truth coordinates')
    coords_dir = 'y:\DOL Calibration\Data\SimData_realistic\dolSim_raw_coords\';
    dolSimRed = dolSim.importGroundTruth(dolSimRed, coords_dir);

    % TODO import u-track data
end

%% transformation
dolSimRed.fullTransformation('ground truth', 'thunderStorm single complete');
dolSimRed.fullTransformation('ground truth', 'thunderStorm single partial');
dolSimRed.fullTransformation('ground truth', 'thunderStorm multi complete');
dolSimRed.fullTransformation('ground truth', 'thunderStorm multi partial');

%% point filtering
disp('Filtering points by sigma')
setNames = {'thunderStorm single complete'
            'thunderStorm single partial'
            'thunderStorm multi complete'
            'thunderStorm multi partial'};
sigmaFilterNames = strcat(setNames, ' fltr sigma');
[medianSigma, stdSigma] = sigmaHistogram(dolSimRed, setNames);
filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

for i = 1:length(setNames)
    dolSimRed.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
end

%% calculate mean densities
dolSimRed.calculateAllMeanDensities();

%% calculate colocalisation
dolSimRed.colocalisation('thunderStorm single complete', 'thunderStorm single partial')
dolSimRed.colocalisation('thunderStorm multi complete', 'thunderStorm multi partial')
dolSimRed.colocalisation('thunderStorm single complete fltr sigma', 'thunderStorm single partial fltr sigma')
dolSimRed.colocalisation('thunderStorm multi complete fltr sigma', 'thunderStorm multi partial fltr sigma')

dolSimRed.colocalisation('ground truth', 'thunderStorm single partial')
dolSimRed.colocalisation('ground truth', 'thunderStorm multi partial')
dolSimRed.colocalisation('ground truth', 'thunderStorm single partial fltr sigma')
dolSimRed.colocalisation('ground truth', 'thunderStorm multi partial fltr sigma')