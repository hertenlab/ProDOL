function pixelSize = pixelSizeTS(csvDir)

    fileList = dir(csvDir);
    protocolList = fileList(~cellfun(@isempty, strfind({fileList.name}, '-protocol.txt')));
    
    for i = 1:length(protocolList)
        path = fullfile(protocolList(i).folder, protocolList(i).name);
        pxVector(i) = extractPixelSize(path);
    end
    
    pixelSize = unique(pxVector);
    if length(pixelSize) > 1
        error('inconsistent pixel size found')
    end

end

function pixelSize = extractPixelSize(protocolPath)

    fileID = fopen(protocolPath);
    textCell = importdata(protocolPath,'');
    pxLine = textCell{~cellfun(@isempty, strfind(textCell, '"pixelSize"'))};
    pixelSize = str2num(pxLine(strfind(pxLine, ':')+2 : strfind(pxLine, ',')-1));

end