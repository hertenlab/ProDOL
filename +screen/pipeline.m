%{

sigiRoot = 'y:\DOL Calibration\Data\sigi\3ChannelsMask\';
sigiTS = 'y:\DOL Calibration\Data\sigi\thunderSTORM2019\sigi_thunderSTORM_2019.mat';
sigiUT = 'y:\DOL Calibration\Data\sigi\u-track\movieList_all.mat';
sigiPixelSize = 0.104;
sigiSet = screen.pipeline(sigiRoot, sigiTS, sigiUT, sigiPixelSize);


felixRoot = 'y:\DOL Calibration\Data\felix\3ChannelsMask\';
felixTS = 'y:\DOL Calibration\Data\felix\thunderSTORM2019\felix_thunderSTORM2019.mat';
felixUT = 'y:\DOL Calibration\Data\felix\u-track\movieList_Huh_TMR-Star_SiR-HA all.mat';
felixPixelSize = permute(repmat([0.104 0.104 0.095 0.095 0.095],2,1,8), [1,3,2]);  % (l,c,t)
felixSet = screen.pipeline(felixRoot, felixTS, felixUT, felixPixelSize);

klausRoot = 'y:\DOL Calibration\Data\klaus\3ChannelsMask\';
klausTS = 'y:\DOL Calibration\Data\klaus\thunderSTORM2019\klaus_thunderSTORM2019.mat';
klausUT = 'y:\DOL Calibration\Data\klaus\u-track\movieList_H838_HA-TMR_BG-SiR_all.mat';
klausPixelSize = 0.095;
klausSet = screen.pipeline(klausRoot, klausTS, klausUT, klausPixelSize);

wioletaRoot = 'y:\DOL Calibration\Data\wioleta_JTag\3ChannelsMask\';
wioletaTS = 'y:\DOL Calibration\Data\wioleta_JTag\thunderSTORM2019\wioleta_thunderSTORM2019.mat';
wioletaUT = 'y:\DOL Calibration\Data\wioleta_JTag\u-track\movieList_all.mat';
wioletaPixelSize = 0.095;
wioletaSet = screen.pipeline(wioletaRoot, wioletaTS, wioletaUT, wioletaPixelSize);

%}

function screenSet = pipeline(imageRootDir, thunderStormPath, movieListPath, pixelSize)

    %% Create imageset

    screenSet = imageset.empty;
    screenSet = screen.createImageSets(screenSet, imageRootDir, pixelSize);

    %% import thunderSTORM points
    
    screenSet = screen.importThunderStorm(screenSet, thunderStormPath);
    
    %% import u-track points
    
    screenSet = screen.importUtrack(screenSet, movieListPath);

    %% transformation
    
    screenSet.fullTransformation('thunderStorm blue', 'thunderStorm green');
    screenSet.fullTransformation('thunderStorm blue', 'thunderStorm red');
    screenSet.fullTransformation('uTrack blue', 'uTrack green');
    screenSet.fullTransformation('uTrack blue', 'uTrack red');

    %% point filtering
    
    % filter by sigma
    disp('Filtering points by sigma')
    setNames = {'thunderStorm blue'
                'thunderStorm green'
                'thunderStorm red'
                'uTrack blue'
                'uTrack green'
                'uTrack red'};
    sigmaFilterNames = strcat(setNames, ' fltr sigma');
    [medianSigma, stdSigma] = sigmaHistogram(screenSet, setNames);
    filterSigmas = [medianSigma - 1*stdSigma; medianSigma + 1*stdSigma];
    
    filterSummary = table(setNames, medianSigma', stdSigma', filterSigmas(1,:)', filterSigmas(2,:)', 'VariableNames', {'pointset', 'medianSigma', 'stdSigma', 'lowLimit', 'highLimit'});
    disp(filterSummary)
    for i = 1:length(setNames)
        screenSet.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', filterSigmas(:,i), 'replace');
    end
    

    %% calculate mean densities
    screenSet.calculateAllMeanDensities();

    %% calculate colocalisation
    
    screenSet.colocalisation('thunderStorm blue' , 'thunderStorm red')
    screenSet.colocalisation('thunderStorm blue', 'thunderStorm green')
    screenSet.colocalisation('thunderStorm green', 'thunderStorm red')
    screenSet.colocalisation('thunderStorm blue fltr sigma' , 'thunderStorm red fltr sigma')
    screenSet.colocalisation('thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma')
    screenSet.colocalisation('thunderStorm green fltr sigma', 'thunderStorm red fltr sigma')
    screenSet.colocalisation('uTrack blue' , 'uTrack red')
    screenSet.colocalisation('uTrack blue', 'uTrack green')
    screenSet.colocalisation('uTrack green', 'uTrack red')
    screenSet.colocalisation('uTrack blue fltr sigma' , 'uTrack red fltr sigma')
    screenSet.colocalisation('uTrack blue fltr sigma', 'uTrack green fltr sigma')
    screenSet.colocalisation('uTrack green fltr sigma', 'uTrack red fltr sigma')

    fprintf('\n***\tColocalisation analysis pipeline complete!\t***\n\n');
    
end