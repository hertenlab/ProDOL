function imgSets = importThunderStorm(imgSets, pointSetNameStem, datasets_path, channelsMask_dir)

    data = datasets_path;
    switch exist(data)
        case 2
            fprintf('loading datasets .mat file.\n')
            load(data);
            datasets_path = data;
        case 7
            fprintf('importing thunderSTORM data from .csv files.\n')
            ilPath = fullfile(data, 'image_list.txt');
            datasets = importTSeff(data, ilPath);
        case 0
            error('could not find thunderSTORM data here\n%s\n', data);
    end
    
    
    % perform point filtering based on masks
    pixelsize = 1000*imgSets(1).childImages(1).pixelSize; % ts importing uses pixel size in nm (not in um)
    thresholds = {'2.0'};
    pointSim.filterbyMasks_thunderSTORM(datasets, channelsMask_dir, pixelsize);

    for t = 1:length(thresholds)
        threshold = thresholds{t};
        for fittype = {'single' 'multi'}
            [x, y, A, c, s, ...
                ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, tsDensity, tsReplicate, ~] = convertTStoDOL(datasets, fittype, threshold);
            for setIndex = 1:length(imgSets)
                density = imgSets(setIndex).descriptors.simulatedDensity;
                dispProgress(setIndex, length(imgSets));
                childImages = imgSets(setIndex).childImages;
                for repIndex = 1:length(imgSets(setIndex).childImages)
                    thisImage = childImages(repIndex);
                    replicate = thisImage.replicate;

                    tsIndex = find(tsDensity == density & tsReplicate == replicate);
                    if length(thresholds) > 1
                        pointSetName = [pointSetNameStem ' ' 'threshold ' threshold ' ' fittype{:}];
                    else
                        pointSetName = [pointSetNameStem ' ' fittype{:}];
                    end
                    ptSet = pointset(pointSetName, thisImage, datasets_path);
                    ptSet.pointDetectionParameters = struct('threshold', threshold, 'fittype', fittype);
                    ptSet.parentImage.addPointSet(ptSet);

                    % add points to pointet
                    ptSet.addPoints(x{tsIndex}, y{tsIndex}, A{tsIndex}, s{tsIndex}, c{tsIndex})

                    % calculate density
                    ptSet.calculateDensity();

                end
            end
        end
    end

end