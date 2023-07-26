tic
if (exist('beadsImageSets', 'var') ~=1) || isempty(beadsImageSets)
    
    % Import data
    beadsImageSets = imageset.empty;
    disp('Creating imagesets');
    beadsImageSets = beads.createImageSets(beadsImageSets);
    
    disp('Import thunderStorm data')
    datasets_path = 'y:\DOL Calibration\Data\beads-control\intensity_screen2\analysis\beads_thunderSTORM_thresh_2.0.mat';
    
    beadsImageSets = beads.importThunderStorm(beadsImageSets, 'thunderStorm', datasets_path);

end

%% perform registration

beadsImageSets.fullTransformation('thunderStorm multi blue', 'thunderStorm multi green');
beadsImageSets.fullTransformation('thunderStorm multi blue', 'thunderStorm multi red');

%% point filtering
disp('Filtering points by sigma')
setNames = {'thunderStorm multi red'
            'thunderStorm multi green'
            'thunderStorm multi blue'};
sigmaFilterNames = strcat(setNames, ' fltr sigma');
[medianSigma, stdSigma] = sigmaHistogram(beadsImageSets, setNames);
filterSigmas = [medianSigma-2*stdSigma; medianSigma+2*stdSigma];

filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
disp(filterSummary)
for i = 1:length(setNames)
    beadsImageSets.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
end

%% calculate DOL between point sets

beadsImageSets.colocalisation('thunderStorm multi blue', 'thunderStorm multi green');
beadsImageSets.colocalisation('thunderStorm multi green', 'thunderStorm multi red');
beadsImageSets.colocalisation('thunderStorm multi blue', 'thunderStorm multi red');
beadsImageSets.colocalisation('thunderStorm multi blue fltr sigma', 'thunderStorm multi green fltr sigma');
beadsImageSets.colocalisation('thunderStorm multi green fltr sigma', 'thunderStorm multi red fltr sigma');
beadsImageSets.colocalisation('thunderStorm multi blue fltr sigma', 'thunderStorm multi red fltr sigma');

fprintf('\ndone!\n');
toc