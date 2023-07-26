function imgSets = importGroundTruth(imgSets, coords_dir)

    for setIndex = 1:length(imgSets)
        density = imgSets(setIndex).descriptors.simulatedDensity;
        
        for repIndex = 1:length(imgSets(setIndex).childImages)
            dispProgress(setIndex, length(imgSets), repIndex, length(imgSets(setIndex).childImages));
            
            thisImage = imgSets(setIndex).childImages(repIndex);
            replicate = thisImage.replicate;
            
            maskPath = thisImage.channelPath('mask');
            
            [x, y, txtFileName] = pointSim.pointsFromGroundTruth(density, replicate, coords_dir, maskPath);
            
            ptSet = pointset('ground truth', thisImage, txtFileName);
            ptSet.parentImage.addPointSet(ptSet);
            
            % add points to pointet
            ptSet.addPoints(x, y, nan(length(x),1), nan(length(x),1), nan(length(x),1));
            
            % calculate density
            ptSet.calculateDensity();
            
        end
    end
    

end