%% Pipeline for analyzing DOL data from a single experimental condition, i.e. a given cell type, dye concentration, incubation time.
% Required data format:
% Movie list from u-track analysis

%% Define parameters etc.
% Define processing parameters
pixelsize = 0.096; % pixelsize in images in um
refChannel = 1; % channel number in u-track for GFP channel (blue)
anylChannel = 3; % channel number in u-track for dol channel (green / red)
anylColor = 'red'; % color of dol channel ('green' or 'red');
maskChannel = 2; % channel number in u-track for mask

% Define paths
movieListPath = 'E:\USERS\Wioleta\181024_SG_18_SLP76-Halo_D8_10nM\DOL_neue_Ordnerstruktur\u-track\movieList_60min.mat';
unstainedIdentifier = {''}; % string identifier uniquely found in path to unstained cells moviedata

%% Dataset initialization

movielist = load(movieListPath);
MDpaths = movielist.ML.movieDataFile_;
%idxUnstained = cellfun(@isempty,strfind(MDpaths, unstainedIdentifier));
idxUnstained = contains(MDpaths,unstainedIdentifier);

%% Point extraction

% extract points into datasets object (includes filtering with mask files)
refPoints = singlecondition_pointExtraction(movieListPath, refChannel);
anylPoints = singlecondition_pointExtraction(movieListPath, anylChannel);


%% Construct all areas

% Assemble point arrays from datasets object
AllAreas = singlecondition_AreaFromMovieList(movieListPath, maskChannel);

%% Point Filtering

% by percentile in anyl channel
if sum(idxUnstained) >= length(MDpaths) || sum(idxUnstained) == 0
    warning('all or no cells identified with unstainedIdentifier, no filtering possible')
else
    [~, anylPoints.A, anylPoints.x, anylPoints.y, anylPoints.c, anylPoints.s] = ...
        filterPointsByPercentile(90, idxUnstained, true(length(idxUnstained),1), ...
        anylPoints.A, anylPoints.x, anylPoints.y, anylPoints.c, anylPoints.s);
end
% by threshold in ref channel
[refPoints.A, refPoints.x, refPoints.y, refPoints.c, refPoints.s] = ...
    filterPointsByThreshold(200, refPoints.A, refPoints.x, refPoints.y, ...
    refPoints.c, refPoints.s);

%% Registration

% choose scale factor
switch anylColor
    case 'green'
        meanScaleX = 0.5523;
        meanScaleY = 0.4909;
    case 'red'
        meanScaleX = 0.6773;
        meanScaleY = 0.5682;
end

% calculate translation
[translationX, translationY, flag] = channelRegistration(refPoints.x, refPoints.y, ...
    anylPoints.x, anylPoints.y, meanScaleX, meanScaleY);
% mean translation from succesful regestration
[meanTransX, meanTransY, translationX, translationY, flag] = ...
    meanTranslation(translationX, translationY, flag);
succes = strcmp(flag,'Registration successfull');
% apply translation
[anylPoints.xReg, anylPoints.yReg] = applyTranslation(anylPoints.x, anylPoints.y,...
    translationX, translationY, meanScaleX, meanScaleY);
% rotate points
[anylPoints.xRot, anylPoints.xRot] = deal(cell(size(anylPoints.xReg)));
for i = 1:length(anylPoints.xReg)
    anylPoints.xRot{i} = anylPoints.y{i};
    anylPoints.yRot{i} = 512 - anylPoints.x{i};
end

%% Colocalisation

cells.tolerance = (0.1:0.1:4);

for i = 1:length(anylPoints.x)
    for t = 1:length(cells.tolerance)
        
        dispProgress(i, length(anylPoints.x), t, length(cells.tolerance));

        [cells.numRef(i), cells.numAnyl(i), cells.coloc(i,t), cells.multi(i,t)] = ...
            detectColocalisation(refPoints.x{i}, refPoints.y{i}, anylPoints.xReg{i}, anylPoints.yReg{i},...
            cells.tolerance(t), cells.tolerance(t));
        
        [~, ~, cells.colocRandom(i,t), cells.multiRandom(i,t)] = ...
            detectColocalisation(refPoints.x{i}, refPoints.y{i}, anylPoints.xRot{i}, anylPoints.yRot{i},...
            cells.tolerance(t), cells.tolerance(t));
        
        cells.anylP(i,t) = cells.coloc(i,t) / cells.numRef(i);
        cells.refP(i,t) = cells.coloc(i,t) / cells.numAnyl(i);
        cells.randomP(i,t) = cells.colocRandom(i,t) / cells.numRef(i);
    
    end
end

%% Particle Density

cells.densityRef = cells.numRef ./ (AllAreas .* pixelsize^2);
cells.densityAnyl = cells.numAnyl ./ (AllAreas .* pixelsize^2);

%% Significant Colocalisation Distance Threshold

cells.distThreshold = colocalisationThreshold...
    (cells.coloc(succes,:),cells.colocRandom(succes,:),cells.tolerance);
cells.dol = cells.anylP(:,cells.tolerance == cells.distThreshold);
cells.dolRandom = cells.randomP(:,cells.tolerance == cells.distThreshold);

%% Density Correction
% density correction 'pCorr = p / (-0.17 * density + 1)' originally 
% determined by Sigi with simulated points (see Thesis)

pCorr = cells.anylP ./ (-0.17 * cells.densityAnyl + 1);
pCorrRandom = cells.randomP ./ (-0.17 * cells.densityAnyl + 1);
cells.dolCorr = pCorr(:,cells.tolerance == cells.distThreshold);         
cells.dolCorrRandom = pCorrRandom(:,cells.tolerance == cells.distThreshold);
cells.densityAnyl = cells.densityAnyl(:,cells.tolerance == cells.distThreshold);

%% Results table

resultsTable = table(MDpaths', cells.dolCorr, cells.dolCorrRandom, cells.numRef',...
    cells.numAnyl');
resultsTable.Properties.VariableNames = {'filePath', 'DOL', 'DOLRandom_rotated', 'Number_of_Points_Ref',...
    'Number_of_Points_Anyl'};

resultsTable