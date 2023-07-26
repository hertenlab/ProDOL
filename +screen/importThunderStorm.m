function imgSets = importThunderStorm(imgSets, datasets_path)

    data = datasets_path;
    if isa(data, 'movie')
        datasets = data;
    else
        switch exist(data)
            case 2
                fprintf('loading datasets .mat file.\n')
                load(data);
                datasets_path = data;
            case 7
                fprintf('importing thunderSTORM data from .csv files.\n')
                ilPath = fullfile(data, 'image_list.txt');
                datasets = importTSeff(ilPath, data);
        end
    end
    
    tsChannels = {'blue' 'green' 'red'};
    tsTime = cell2mat({datasets.incubation_time}');
    tsConcentration = cell2mat({datasets.concentration}');
    tsReplicate = cell2mat({datasets.replicate}');
    tsCellType = {datasets.CellType}';
    
    fittype = 'multi';
    threshold = '2.0';
    
    for setIndex = 1:length(imgSets)
        thisSet = imgSets(setIndex);
        childImages = thisSet.childImages;
        cellType = thisSet.descriptors.cellType;
        concentration = thisSet.descriptors.concentration;
        incubationTime = thisSet.descriptors.incubationTime;
        
        for repIndex = 1:length(imgSets(setIndex).childImages)
            dispProgress(setIndex, length(imgSets), repIndex, length(imgSets(setIndex).childImages))
            % match datasets index
            thisImage = childImages(repIndex);
            replicate = thisImage.replicate;
            
            tsIndex = find(strcmp(tsCellType, cellType) & ...
                tsConcentration == concentration & ...
                tsTime == incubationTime & ...
                tsReplicate == replicate);
            
            % filter points by mask
            maskFile = thisImage.channelPath('mask');
            pixelSize = thisImage.pixelSize;
            datasets(tsIndex).filteranalysisbymask(maskFile, pixelSize * 1000);
            % extract points
            [x.blue, y.blue, A.blue, c.blue, s.blue,...
                x.green, y.green, A.green, c.green, s.green, ...
                x.red, y.red, A.red, c.red, s.red] = ...
                convertTStoDOL(datasets(tsIndex), fittype, threshold);
            
            for ch = 1:length(tsChannels)
                setName = ['thunderStorm ' tsChannels{ch}];
                ptSet = pointset(setName, thisImage, datasets_path);
                ptSet.pointDetectionParameters = struct('threshold', threshold, 'fittype', fittype, 'channel', tsChannels{ch});
                ptSet.parentImage.addPointSet(ptSet);

                % add points to pointet
                ptSet.addPoints(x.(tsChannels{ch}){:}, y.(tsChannels{ch}){:},...
                    A.(tsChannels{ch}){:}, s.(tsChannels{ch}){:}, c.(tsChannels{ch}){:});

                % calculate density
                ptSet.calculateDensity();
            end
        end
    end
end

        