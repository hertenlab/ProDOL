

function AllAreas = singlecondition_AreaFromMovieList(movieListPath, maskChannel)

    movielist = load(movieListPath);
    MDpaths = movielist.ML.movieDataFile_;
    
    AllAreas = zeros(length(MDpaths),1);
    
    for i = 1:length(MDpaths)
        load(MDpaths{i}, 'MD');
        maskDir = MD.channels_(1,maskChannel).channelPath_;
        filedir = dir(maskDir);
        maskDirPath = fullfile(maskDir, filedir(3).name);
        im = imread(maskDirPath);
        AllAreas(i) = nnz(im);
    end
    
end