% This function displays a dolan multicolorimage and overlays points. The
% coloring depends on the number of channels to be shown: a single channel
% is displayed in gray scale, two channels are shown in magenta and green
% and three channels are shown in red, green and blue (in the order of
% input variable showChannels)
% 
% inputs:
% mci: dolan multicolor image
% showChannels: cell array containing channel names to be displayed (e.g.
%     'red', 'green', 'blue', 'mask', 'gray', 'partial', ...)
% pointSetNames: string or cell array of pointset names to be overlaid over
%     the image
% 
% example:
% showImage(myImage, {'red', 'blue', 'mask'}, {'u-track red', 'u-track blue'})
% displays the red and blue image channel in magenta and green, the outline 
% from the segmentation mask and overlays points from pointset 'u-track
% red' and 'u-track blue'.

function figH = showImage(mci, showChannels, pointSetNames, figH)

    if ischar(showChannels)
        showChannels = {showChannels};
    end
    
    if any(strcmp(showChannels,'mask'))
        colorChannels = showChannels(~strcmp(showChannels,'mask'));
        segmentation = createSegmentation(mci);
    else
        colorChannels = showChannels;
        segmentation = [];
    end
        
    % check input
    if length(colorChannels) > 3
        error('Cannot display more than 3 color channels at the same time');
    end
    
    imageArray = createImage(mci, colorChannels);
    
    if nargin > 3
        figure(figH)
    else
        figH = figure();
        imshow([]);
    end    
    cla;
        
    % display image
    if ~isempty(imageArray)
            switch size(imageArray,3)
                case 1
                    imshow(imageArray,[prctile(imageArray(:),5), prctile(imageArray(:),99)]);
                    %imshow(imageArray,[300, 2500]);
                case 2
                    rgbArray = imageArray / 2^16;
                    m = imadjust(rgbArray(:,:,1), stretchlim(rgbArray(:,:,1),[0.15 .995]),[]);
                    g = imadjust(rgbArray(:,:,2), stretchlim(rgbArray(:,:,2),[0.15 .995]),[]);
                    dispImage = cat(3, m, g, m);
                    imshow(dispImage);
                case 3
                    rgbArray = imageArray / 2^16;
                    r = imadjust(rgbArray(:,:,1), stretchlim(rgbArray(:,:,1),[0.05 .99]),[]);
                    g = imadjust(rgbArray(:,:,2), stretchlim(rgbArray(:,:,2),[0.05 .99]),[]);
                    b = imadjust(rgbArray(:,:,3), stretchlim(rgbArray(:,:,3),[0.05 .99]),[]);
                    dispImage = cat(3,r,g,b);
                    imshow(dispImage);
            end
    else
        set(gca, 'Visible', 'on', 'Layer', 'bottom', 'GridLineStyle', '-', ...
            'GridAlpha', 1, 'GridColor', [.7 .7 .7], 'MinorGridLineStyle', '-', ...
            'MinorGridAlpha', 1, 'MinorGridColor', [.9 .9 .9], 'XGrid', 'on', ...
            'XMinorGrid', 'on', 'YGrid', 'on', 'YMinorGrid', 'on');
    end
    
    % plot points of selected pointsets
    if ~isempty(pointSetNames)
        markers = 'xosd^<>v';
        [points, names] = getPoints(mci, pointSetNames);
        for i = 1:length(points)
            hold on
            if ~isempty(points{i})
                set(gca, 'ColorOrderIndex', i);
                scatter(points{i}(:,1), points{i}(:,2), 50, markers(i), 'LineWidth', 1.5, 'MarkerEdgeAlpha', 0.7);
            end
%             scatter(points{i}(:,1), points{i}(:,2), 50, 'o', 'filled', 'MarkerFaceAlpha', 0.6, 'MarkerEdgeColor', [.1 .1 .1]);
        end
        legend(names(~cellfun(@isempty,names)));
    end
    
%     display segmentation
    if ~isempty(segmentation)
        hold on
        for i = 1:length(segmentation)
            if length(segmentation{i}) > 300
                x = floor(length(segmentation{i}) / 150);
                trimmed = segmentation{i}(1:x:end-1, :);
                segmentation{i} = [trimmed; segmentation{i}(end, :)];
            end
            plot(segmentation{i}(:,2), segmentation{i}(:,1), 'y', 'LineWidth', 5);
        end
    end
    
end

function imageArray = createImage(mci, colorChannels)
    
    % load channel images
    availableChannels = {mci.channels.name};
    info = imfinfo(mci.channels(1).path);
    imageArray = zeros(info.Width,info.Height,length(colorChannels));
    for i = 1:length(colorChannels)
        imageArray(:,:,i) = double(imread(mci.channels(strcmp(availableChannels, colorChannels{i})).path));
    end
    
end

function segmentation = createSegmentation(mci)
    
    availableChannels = {mci.channels.name};
    maskArray = double(imread(mci.channels(strcmp(availableChannels, 'mask')).path));
    segmentation = bwboundaries(maskArray);
    
end

function [points, names] = getPoints(mci, pointSetNames)

    avalablePointSets = {mci.childPointSets};
    if ischar(pointSetNames)
        pointSetNames = {pointSetNames};
    end
    
    [points, names] = deal(cell(0));
    for i = 1:length(pointSetNames)
        ptSet = mci.pointSetByName(pointSetNames{i});
        if ~isempty(ptSet)
            points{i} = ptSet.getAllPositions('original');
            names{i} = pointSetNames{i};
        else
            fprintf('''%s'' not available\n', pointSetNames{i});
        end
    end
    
end