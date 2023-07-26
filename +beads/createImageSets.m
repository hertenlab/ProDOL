function beadsImageSets = createImageSets(beadsImageSets)


% classification of microscopy data

data_rootdir = 'y:\DOL Calibration\Data\beads-control\intensity_screen2\3ChannelsMask';
nameStem = 'beads';

pixelSize = 0.095;

ndFilter = [0 8 16 32];
ndFolder_str = {'ND00' 'ND08' 'ND16' 'ND32'};
ndFile_str = {'nd00' 'nd8' 'nd16' 'nd32'};
laserIntensity = [.001 .0025 .005 .01 .02 .05 .1 .2 .5 1];
laserIntensity_str = {'0-0010' '0-0025' '0-0050' '0-01' '0-02' '0-05' '0-1' '0-2' '0-5' '1-0'};

channels = {'blue' 'green' 'mask' 'red'};
channels_str = channels;


for i = 1:4
    for j = 1:10
        dispProgress(i,4,j,10);
        
        nd = ndFilter(i);
        li = laserIntensity(j);
        
        % find respective subfolder
        imageset_dir = fullfile(data_rootdir, ndFolder_str{i},...
            laserIntensity_str{j});
        
        % determine number of replicates by stripping filenames 
        imgSetNameStem = [nameStem '_' ndFile_str{i}, '_' laserIntensity_str{j} '_'];
        imgSetDir = dir(imageset_dir);
        imgSetFNames = {imgSetDir(3:end).name};
        replicates = unique(cellfun(@(x) x(length(imgSetNameStem)+1:length(imgSetNameStem)+2), imgSetFNames, 'UniformOutput', false));
        numReplicates = length(replicates);
        
        % construct empty imageset
        if nd == 0
            ieff = li;
        else
            ieff = li / nd;
        end
        imgSet = imageset(struct('ndFilter', nd, 'laserIntensity', li, 'effectiveIntensity', ieff));
        
        % generate multichannelimage objects
        for r = 1 : numReplicates
            fileNameStem = [imgSetNameStem, replicates{r}];
            channelPath = cell(1,length(channels));
                for k = 1:length(channels)
                    fName = [fileNameStem '_' channels_str{k} '.tif'];
                    channelPath{k} = fullfile(imageset_dir, fName);
                end

            % construct multichannelimage
            mci = multichannelimage(imgSet, [channels; channelPath], str2num(replicates{r}));
            mci.pixelSize = pixelSize;
            % add image to imageset
            imgSet.addImage(mci);
        end
        
        beadsImageSets = [beadsImageSets, imgSet];
        
    end
end

end