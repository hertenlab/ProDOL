function imgSets = importUtrack(imgSets, movieListPath)


    movielist = load(movieListPath);
    MDpaths = movielist.ML.movieDataFile_;
    
    uTrackChannels = [2 3 5];
    uTrackChNames = strcat({'uTrack '}, {'blue' 'green' 'red'});
    
    [uT_CellType, uT_incubation_time, uT_concentration, uT_replicate] = ...
        screen.conditionsFromString(MDpaths);
    
    for setIndex = 1:length(imgSets)
        thisSet = imgSets(setIndex);
        childImages = thisSet.childImages;
        cellType = thisSet.descriptors.cellType;
        concentration = thisSet.descriptors.concentration;
        incubationTime = thisSet.descriptors.incubationTime;
        
        for repIndex = 1:length(imgSets(setIndex).childImages)
            dispProgress(setIndex, length(imgSets), repIndex, length(imgSets(setIndex).childImages));
            
            thisImage = imgSets(setIndex).childImages(repIndex);
            replicate = thisImage.replicate;
            
            uT_idx = strcmp(uT_CellType, cellType) & uT_concentration == concentration &...
                uT_incubation_time == incubationTime & uT_replicate == replicate;
            
            thisMDpath = MDpaths(uT_idx);
            
            % loop through channels
            for ch = 1:length(uTrackChannels)

                [PointDetectionParameters, x, y, A, c, s] = ...
                    pointsFromMovieData(thisMDpath, uTrackChannels(ch));
                % path to actual point_sources data of this channel
                pointSourcePath = strrep(thisMDpath, 'movieData.mat', ['TrackingPackage\point_sources\channel_' uTrackChannels(ch) '.mat']);
                % create pointset for every channel of u-track data
                ptSet = pointset(uTrackChNames{ch}, thisImage, pointSourcePath);

                % store point detection parameters
                ptSet.pointDetectionParameters = PointDetectionParameters;

                % link pointset to parent image
                ptSet.parentImage.addPointSet(ptSet);

                % add points to pointet
                ptSet.addPoints(x{:}, y{:}, A{:}, s{:}, c{:});

                % calculate density
                ptSet.calculateDensity();

            end
        end
    end
end