%% Pipeline for analyzing DOL data from a single experimental condition, i.e. a given cell type, dye concentration, incubation time.
% Required data format:
% The pipeline can deal with one or two dye channels. Dye channels still
% have to be named green or red.

%% Define parameters etc.
% Define processing parameters
prepAveraging = 1; % data preparation - create mask, perform averaging and moving to 3ChannelsMask
prepIntAnalysis = 0; % data preparation - perform intensity analysis on averaged images
pixelsize = 96; % pixelsize in images (identical value to be used for thunderSTORM point detection!)
fittype = 'multi'; % thunderSTORM point detection parameters
threshold = '2.0'; % thunderSTORM point detection parameters

% Define paths
dolP = '/media/klaus/data/diss/software/DOL/general/'; % DOL software directory
dataP = '/media/smss_exchange/Klaus/180413_Philipp_DOL/'; % 
saveDir = '/media/smss_exchange/Klaus/180413_Philipp_DOL/analysis/'; % output directory for results data and plots
impdataP = '';

%%%%%%%%%%%%%%%%%%%%%
% Pipeline
%%%%%%%%%%%%%%%%%%%%%

%% Prepare raw data
%dataPreparation(dataP,strcat(dolP,'dataPreparation',filesep),prepAveraging,prepIntAnalysis);

%% Point detection
% Manual u-track or thunderSTORM pd
% --> can be automated for thunderSTORM

%% Point extraction
% extract points into datasets object (includes filtering with mask files)
if isa(datasets,'movie')
    fprintf('Using existing datasets object\n');
elseif ~isempty(impdataP)
    datasets = singlecondition_pointExtraction_thunderSTORM('load',pixelsize,dataP,fittype,threshold,impdataP);
else
    datasets = singlecondition_pointExtraction_thunderSTORM('import',pixelsize,dataP,fittype,threshold,impdataP);
end

%% Determine which color channels are to be processed
chans_temp = unique({datasets(1).analysis(:).channel});
chans = false(1,3); % order: (blue, green, red)
if sum(strcmp(chans_temp,'blue'))>0
    chans(1,1) = true;
else
    error('Can not proceed without blue channel. Aborting.');
end
if sum(strcmp(chans_temp,'green'))>0
    chans(1,2) = true;
end
if sum(strcmp(chans_temp,'red'))>0
    chans(1,3) = true;
end

%% Construct vectors for DOL analysis
% decide on number of spectral channels
% All images need to have identical channels
% --> Can this code be put into pointExtraction_thunderSTORM?

if chans(1,1)
    fprintf('Importing blue channel\n')
    [Points_Blue_x, Points_Blue_y, Points_Blue_A, Points_Blue_c, Points_Blue_s, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, replicate, ~] = convertTStoDOL(datasets,fittype,threshold,pixelsize);
end
if chans(1,2)
    fprintf('Importing green channel\n')
    [~, ~, ~, ~, ~, Points_Green_x, Points_Green_y, Points_Green_A, Points_Green_c, Points_Green_s, ~, ~, ~, ~, ~, ~, ~, replicate, ~] = convertTStoDOL(datasets,fittype,threshold,pixelsize);
end
if chans(1,3)
    fprintf('Importing red channel\n')
    [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Points_Red_x, Points_Red_y, Points_Red_A, Points_Red_c, Points_Red_s, ~, ~, replicate, ~] = convertTStoDOL(datasets,fittype,threshold,pixelsize);
end

%% Construct all areas
% Assemble point arrays from datasets object
AllAreas = zeros(length(datasets),1);
for i=1:length(datasets)
    AllAreas(i) = singlecondition_AreaFromMaskTS(datasets(i),fullfile(dataP,'3ChannelsMask'));
end

%% Cell analysis


%singlecondition_cellAnalysis

%singlecondition_downstreamAnalysis

%singlecondition_plot

%singlecondition_datasave