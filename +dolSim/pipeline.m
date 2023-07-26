%{

dolSimGreen = dolSim.pipeline(...
    'y:\DOL Calibration\Data\SimData_realistic\green_background\DOL-Simulation\Screen',...
    'y:\DOL Calibration\Data\SimData_realistic\green_background\DOL-Simulation\thunderSTORM\SimsVaryDOL_green_datasets.mat',...
    'y:\DOL Calibration\Data\SimData_realistic\dolSim_raw_coords');

dolSimRed = dolSim.pipeline(...
    'y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\3Channels_Mask',...
    'y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\thunderSTORM\SimsVaryDOL_red_datasets_withoutDoubleEntry.mat',...
    'y:\DOL Calibration\Data\SimData_realistic\dolSim_raw_coords');

%}

function dolSimSet = pipeline(imageRootDir, thunderStormMatPath, groundTruthDir)
    
    fprintf(['Colocalisation analysis pipeline\n'...
        'root dir (3channelsMask folder containing tif-images):\n%s\n'...
        'thunderSTORM dataset mat file:\n%s\n'...
        'ground truth dir (containing coordinates as *_pos_px.txt files):\n%s\n'],...
        imageRootDir, thunderStormMatPath, groundTruthDir)
    
    %% dataset construction
    % create imageset
    disp('Creating imageset objects')
    dolSimSet = dolSim.createImageSets(imageRootDir);

    % import thunderStorm (single and multi emitter fit)
    disp('Importing thunderStorm data')
    dolSimSet = dolSim.importThunderStorm(dolSimSet, 'thunderStorm', thunderStormMatPath, imageRootDir);

    % import ground truth data
    disp('Importing ground truth coordinates')
    dolSimSet = dolSim.importGroundTruth(dolSimSet, groundTruthDir);

    %% transformation
    dolSimSet.fullTransformation('ground truth', 'thunderStorm single complete');
    dolSimSet.fullTransformation('ground truth', 'thunderStorm single partial');
    dolSimSet.fullTransformation('ground truth', 'thunderStorm multi complete');
    dolSimSet.fullTransformation('ground truth', 'thunderStorm multi partial');

    %% point filtering
    disp('Filtering points by sigma')
    setNames = {...
                'thunderStorm single complete'
                'thunderStorm single partial'
                'thunderStorm multi complete'
                'thunderStorm multi partial'};
    sigmaFilterNames = strcat(setNames, ' fltr sigma');
    [medianSigma, stdSigma] = sigmaHistogram(dolSimSet, setNames);
    filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

    filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
    disp(filterSummary)
    for i = 1:length(setNames)
        dolSimSet.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
    end

    %% calculate mean densities
    dolSimSet.calculateAllMeanDensities();

    %% calculate colocalisation

    dolSimSet.colocalisation('ground truth', 'thunderStorm single partial')
    dolSimSet.colocalisation('ground truth', 'thunderStorm multi partial')
    dolSimSet.colocalisation('ground truth', 'thunderStorm single partial fltr sigma')
    dolSimSet.colocalisation('ground truth', 'thunderStorm multi partial fltr sigma')
    
    fprintf('\n***\tColocalisation analysis pipeline complete!\t***\n\n');
end