function imSet = createImageSet(imSet,imPath,pxSize,channels,imSetProps)

allFiles = dir(imPath);
allFiles = allFiles(~[allFiles.isdir] & cellfun(@(x) contains(x,'.tif'),{allFiles.name}));

% Determine number of cells 
for i=1:numel(allFiles)
    p1 = strfind(allFiles(i).name,'cell');
    p2 = strfind(allFiles(i).name(p1:end),'_');
    if size(p1)>0 & size(p2)>0 & p2>p1 
        allIDs{i} = allFiles(i).name(p1:p2-1);
    else
        allIDs{i} = '';
    end
end
cellIDs = unique(allIDs);

% Check if all channels and mask are present for each cell
test = {allFiles(contains({allFiles.name},'cell01')).name};
for i=1:numel(cellIDs)
    if ~sum(contains(test,channels))==numel(channels) & ~sum(contains(test,'mask'))==1
        error('incomplete image sets. Check image files!')
    end
end
        
% Create imageset
imSet = singlecondition.imageset(imSetProps)

% Create multichannel images for each cell
for i=1:numel(cellIDs)
    for j=1:numel(channels)
        imFile = allFiles(contains({allFiles.name},cellIDs(i)) & contains({allFiles.name},channels(j)));
        paths{j} = fullfile(imFile.folder,imFile.name);
    end
        
    mci = singlecondition.multichannelimage(imSet, [channels; paths], str2num(cellIDs{1}(5:end)));
    mci.pixelSize = pxSize;
    imSet.addImage(mci);
end

end

