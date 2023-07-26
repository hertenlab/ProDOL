function imgSets = pointSim_importUtrack(imgSets, pointSetName, movieListPath)

    movielist = load(movieListPath);
    MDpaths = movielist.ML.movieDataFile_;

    for setIndex = 1:length(imgSets)
        for repIndex = 1:length(imgSets(setIndex).childImages)
            dispProgress(setIndex, length(imgSets), repIndex, length(imgSets(setIndex).childImages));
            
            thisImage = imgSets(setIndex).childImages(repIndex);
            
            % construct u-track movie data folder name frome descriptors
            density_str = strrep(num2str(imgSets(setIndex).descriptors.simulatedDensity, '%1.1f'), '.', '-');
            replicate_str = num2str(thisImage.replicate, '%02.0f');
            mdFolderName = ['fullImage_density_' density_str '_' replicate_str '_'];
            thisMDpath = MDpaths{~cellfun(@isempty, strfind(MDpaths,mdFolderName))};
            
            [PointDetectionParameters, x, y, A, c, s] = ...
                pointsFromMovieData(thisMDpath, 1);
            pointSourcePath = strrep(thisMDpath, 'movieData.mat', ['TrackingPackage\point_sources\channel_1.mat']);
            
            ptSet = pointset(pointSetName, thisImage, pointSourcePath);
            ptSet.pointDetectionParameters = PointDetectionParameters;
            ptSet.parentImage.addPointSet(ptSet);
            
            % add points to pointet
            ptSet.addPoints(x, y, A, s, c);
            
            % calculate density
            ptSet.calculateDensity();
        end
    end

end