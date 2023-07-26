function imgSets = importThunderStorm(imgSets, pointSetNameStem, datasets_path)
   
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
    
    for fittype = {'multi', 'single'}
        [x.blue, y.blue, A.blue, c.blue, s.blue, ...
            x.green, y.green, A.green, c.green, s.green,...
            x.red, y.red, A.red, c.red, s.red,...
            tsNdFilter, tsLaserIntensity, tsReplicate, ~] = ...
            convertTStoDOL(datasets, fittype, threshold);
        
        for setIndex = 1:length(imgSets)
            dispProgress(setIndex, length(imgSets));
            
            nd = imgSets(setIndex).descriptors.ndFilter;
            li = imgSets(setIndex).descriptors.laserIntensity;
            childImages = imgSets(setIndex).childImages;
            
            for repIndex = 1:length(imgSets(setIndex).childImages)
                thisImage = childImages(repIndex);
                replicate = thisImage.replicate;

                tsIndex = find(tsNdFilter == nd & tsLaserIntensity == li & tsReplicate == replicate);
                
                for channel = {'blue' 'green' 'red'}
                    setName = [pointSetNameStem ' ' fittype{:} ' ' channel{:}];
                    ptSet = pointset(setName, thisImage, datasets_path);
                    ptSet.pointDetectionParameters = struct('threshold', threshold, 'fittype', fittype, 'channel', channel);
                    ptSet.parentImage.addPointSet(ptSet);
                    
                    % convert nm-coordinates to px coordiantes
                    x.(channel{:}){tsIndex} = x.(channel{:}){tsIndex} / tsPixelSize;
                    y.(channel{:}){tsIndex} = y.(channel{:}){tsIndex} / tsPixelSize;
                    s.(channel{:}){tsIndex} = s.(channel{:}){tsIndex} / tsPixelSize;
                    % add points to pointet
                    ptSet.addPoints(x.(channel{:}){tsIndex}, y.(channel{:}){tsIndex},...
                        A.(channel{:}){tsIndex}, s.(channel{:}){tsIndex}, c.(channel{:}){tsIndex})
                    if isempty(x.(channel{:}){tsIndex})
                        disp('no points here')
                    end

                    % calculate density
                    ptSet.calculateDensity();
                end
                
            end
        end
    end

end