function imgSets = createImageSets(data_rootdir)

    nameStem = 'fullImage_density';
    
    pixelSize = 0.104;
    
    if strfind(data_rootdir, 'no_background')
        noBack = true;
        density = [.1 .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6];
        density_str = {'0-1' '0-2' '0-4' '0-6' '0-8' '1-0' '1-2' '1-4' '1-6' '1-8' '2-0' '2-2' '2-4' '2-6'};
    else
        noBack = false;
        density = [0 .1 .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6];
        density_str = {'0-0' '0-1' '0-2' '0-4' '0-6' '0-8' '1-0' '1-2' '1-4' '1-6' '1-8' '2-0' '2-2' '2-4' '2-6'};

        channelsIn = {'blue' 'mask'};
        channelsOut = {'gray' 'mask'};
    end

    imgSets = imageset.empty;
    
    disp('Creating imagesets');
    
    for i = 1:length(density)
        dispProgress(i, length(density));
        
        imageset_dir = fullfile(data_rootdir, ['density_' density_str{i}]);
        
        % determine number of replicates by stripping filenames 
        imgSetNameStem = [nameStem '_' density_str{i}, '_'];
        imgSetDir = dir(imageset_dir);
        imgSetFNames = {imgSetDir(3:end).name};
        replicates = unique(cellfun(@(x) x(length(imgSetNameStem)+1:length(imgSetNameStem)+2), imgSetFNames, 'UniformOutput', false));
        numReplicates = length(replicates);
        
        imgSet = imageset(struct('simulatedDensity', density(i)));
        
        % generate multichannelimage objects
        for r = 1 : numReplicates
            
            fileNameStem = [imgSetNameStem, replicates{r}];
            if noBack
                channelsOut = {'gray'};
                fName = [fileNameStem '.tif'];
                channelPath = {fullfile(imageset_dir, fName)};
            else
                channelPath = cell(1,length(channelsIn));
                    for k = 1:length(channelsIn)
                        fName = [fileNameStem '_' channelsIn{k} '.tif'];
                        channelPath{k} = fullfile(imageset_dir, fName);
                    end
            end

            % construct multichannelimage
            mci = multichannelimage(imgSet, [channelsOut; channelPath], str2num(replicates{r}));
            mci.pixelSize = pixelSize;
            % add image to imageset
            imgSet.addImage(mci);
        end
        
        imgSets = [imgSets imgSet];
        
    end

end