function imgSets = importThunderStorm(imgSets,  pointSetNameStem, datasets_path, channelsMask_dir)

    data = datasets_path;
    switch exist(data)
        case 2
            fprintf('loading datasets .mat file.\n')
            load(data);
            datasets_path = data;
            tsPixelSize = 104;
        case 7
            fprintf('importing thunderSTORM data from .csv files.\n')
            tsPixelSize = pixelSizeTS(data);
            ilPath = fullfile(data, 'image_list.txt');
            datasets = importTSeff(ilPath, data);
    end
    
    threshold = '2.0';
    channelsIn = {'blue' 'green'};
    channelsOut = {'complete' 'partial'};
    dolSim.filterbyMasks_thunderSTORM(datasets, channelsMask_dir, tsPixelSize);
    
    for fittype = {'multi', 'single'}
        % 'green' channel contains all points, 'blue' the subset
        [x.complete, y.complete, A.complete, c.complete, s.complete,...
            x.partial, y.partial, A.partial, c.partial, s.partial, ...
            ~, ~, ~, ~, ~,...
            tsDol, tsDensity, tsReplicate, ~] = ...
            convertTStoDOL(datasets, fittype, threshold);
        
        for setIndex = 1:length(imgSets)
            dispProgress(setIndex, length(imgSets));
            
            simDol = imgSets(setIndex).descriptors.simulatedDOL;
            simDensity = imgSets(setIndex).descriptors.simulatedDensity;
            childImages = imgSets(setIndex).childImages;
            
            for repIndex = 1:length(imgSets(setIndex).childImages)
                thisImage = childImages(repIndex);
                replicate = thisImage.replicate;

                tsIndex = find(round(tsDol, 2) == round(simDol, 2) & ...
                    round(tsDensity, 1) == round(simDensity, 1) & ...
                    round(tsReplicate, 2) == round(replicate, 2));
                
                for ch = 1:length(channelsIn)
                    setName = [pointSetNameStem ' ' fittype{:} ' ' channelsOut{ch}];
                    ptSet = pointset(setName, thisImage, datasets_path);
                    ptSet.pointDetectionParameters = struct('threshold', threshold, 'fittype', fittype, 'channel', channelsIn{ch});
                    ptSet.parentImage.addPointSet(ptSet);

                    % add points to pointet
                    if isempty(x.(channelsOut{ch}){tsIndex})
                        error('stop');
                    end
                    ptSet.addPoints(x.(channelsOut{ch}){tsIndex}, y.(channelsOut{ch}){tsIndex},...
                        A.(channelsOut{ch}){tsIndex}, s.(channelsOut{ch}){tsIndex}, c.(channelsOut{ch}){tsIndex})

                    % calculate density
                    ptSet.calculateDensity();

                end
            end
        end
    end
    
end
                    
                    
                    