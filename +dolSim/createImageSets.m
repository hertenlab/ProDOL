function imgSets = createImageSets(data_rootdir)

    nameStem = 'fullImage_';
    
    pixelSize = 0.104;
    
    density = [0.6 1.6];
    density_str = {'density_0-6', 'density_1-6'};
    
    simDol = 0.05:0.05:0.95;
    simDol_str = strcat('DOL_', strrep(cellfun(@(x) num2str(x,'%1.2f'), num2cell(simDol), 'UniformOutput', false), '.', '-'));
    
    channelsIn = {'blue' 'green' 'mask'};
    channelsOut = {'partial' 'complete' 'mask'};
    
    imgSets = imageset.empty;
    
    disp('Creating imagesets');
    
    for i = 1:length(density)
        for j = 1:length(simDol)
            dispProgress(i, length(density), j, length(simDol))
            
            imgSet_dir = fullfile(data_rootdir, density_str{i}, simDol_str{j});
            
            % determine number of replicates by stripping filenames 
            imgSetNameStem = [nameStem, density_str{i}, '_', simDol_str{j} '_'];
            imgSetDir = dir(imgSet_dir);
            imgSetFNames = {imgSetDir(3:end).name};
            replicates = unique(cellfun(@(x) x(length(imgSetNameStem)+1:length(imgSetNameStem)+2), imgSetFNames, 'UniformOutput', false));
            numReplicates = length(replicates);
            
            imgSet = imageset(struct('simulatedDensity', density(i),...
                'simulatedDOL', simDol(j)));
            
            % generate multichannelimage objects
            for r = 1 : numReplicates
                fileNameStem = [imgSetNameStem, replicates{r}];
                channelPath = cell(1,length(channelsIn));
                    for k = 1:length(channelsIn)
                        fName = [fileNameStem '_' channelsIn{k} '.tif'];
                        channelPath{k} = fullfile(imgSet_dir, fName);
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

end