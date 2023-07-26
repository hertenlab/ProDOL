function datasets = singlecondition_pointExtraction_thunderSTORM(mode,pixelsize,dataP,fittype,threshold,varargin)
% use this function to import outputs from thunderSTORM point detection
% using 'DOL_thunderSTORMlocalization_efficient.ijm'.

% input: mode --> 'none', 'load', 'import'
% input: pixelsize
% input: dataP --> used to construct channelsMask_dir

% output: datasets
% output: AllAreas -->  include in datasets/movie object?!

% Script to extract point data from thunderSTORM analysis of a single
% condition dataset. Import from .csv files is rather slow, load dataset if import has already
% been performed.

%% load data
switch mode
    case 'none'
        fprintf('dataset already loaded. Proceeding.\n')
    case 'load'
        datasets_path = varargin{1};
        if exist(datasets_path)
            fprintf('loading datasets .mat file.\n')
            load(datasets_path);
        else
            fprintf('datasets file not found')
            return
        end
    case 'import'
        imagelists = findMatchFiles(fullfile(dataP,'analysis','thunderSTORM'),'imagelist','.txt');
        tsoutputs = findMatchFiles(fullfile(dataP,'analysis','thunderSTORM'),'tsoutput_','.csv');
        fprintf('importing thunderSTORM data from .csv files.\n')
        datasets = importTSeff(imagelists,tsoutputs);
        fprintf('saving datasets object.\n')
        save(fullfile(dataP,'analysis','thunderSTORM','datasets.mat'),'datasets');
end

% perform point filtering based on masks
singlecondition_filterbyMasks_thunderSTORM(datasets,fullfile(dataP,'3ChannelsMask'),pixelsize);
save(fullfile(dataP,'analysis','thunderSTORM','datasets_filtered.mat'),'datasets');

end