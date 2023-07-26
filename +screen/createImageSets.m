% pixelSize: single value (same for all imagesets) or 2x5x8 array for every
% imageset individually (in um/px)
% order: celltype x incubationTime x concentration
%        {'gSEP' 'LynG'} x [0.25 0.5 1 3 16] x [0 0.1 1 5 10 50 100 250]


function screenImageSet = createImageSets(screenImageSet, imageDir, pixelSize)

    % descriptors: celltype, incubationTime, concentration
    cellType = {'gSEP' 'LynG'};
    time = [0.25 0.5 1 3 16];
    time_str = {'15min' '30min' '60min' '3h' 'overnight'};
    concentration = [0 0.1 1 5 10 50 100 250];
    concentration_str = strcat({'0' '0,1' '1' '5' '10' '50' '100' '250'}, 'nM');
    
    channelsIn = {'bleached' 'blue' 'green' 'mask' 'red'};
    channelsOut = {'greenBleached' 'blue' 'green' 'mask' 'red'};
    
    for t = 1:length(time)
        for l = 1:length(cellType)
            dispProgress(t, 5, l, 2);
            for c = 1:length(concentration)
                imgSetDir = fullfile(imageDir, time_str{t}, [cellType{l}, ' ', concentration_str{c}]);
                
                fileNameStem = [cellType{l}, '_', concentration_str{c} '_'];
                setDirFileList = dir(imgSetDir);
                imgSetFNames = {setDirFileList(3:end).name};
                
                replicates = unique(cellfun(@(x) x(length(fileNameStem)+1:length(fileNameStem)+2), imgSetFNames, 'UniformOutput', false));
                numReplicates = length(replicates);
                
                imgSet = imageset(struct('cellType', cellType{l}, 'concentration', concentration(c),...
                    'incubationTime', time(t)));
                
                % generate multichannelimage objects
                for r = 1 : numReplicates
                    channelPath = cell(1,length(channelsIn));
                        for k = 1:length(channelsIn)
                            fName = [fileNameStem replicates{r} '_' channelsIn{k} '.tif'];
                            channelPath{k} = fullfile(imgSetDir, fName);
                        end

                    % construct multichannelimage
                    mci = multichannelimage(imgSet, [channelsOut; channelPath], str2num(replicates{r}));
                    switch numel(pixelSize)
                        case 1
                            mci.pixelSize = pixelSize;
                        case 2*5*8
                            mci.pixelSize = pixelSize(l, t, c);
                        otherwise
                            error('pixelSize dimension mismatch. Must be a single value or a 2x5x8-array')
                    end
                    % add image to imageset
                    imgSet.addImage(mci);
                end

                screenImageSet = [screenImageSet imgSet];
            end
        end
    end
end