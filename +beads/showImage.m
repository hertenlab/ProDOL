% This function displays a dolan multicolorimage and overlays points
% 
% inputs:
% mci: dolan multicolor image
% showChannels: boolean 5-element vector to display channels red, green,
%     blue, gray and mask, respectively (if available)
% pointSetNames: string or cell array of pointset names to be overlaid over
%     the image
% 
% example:
% showImage(myImage, [1 0 1 0 1], {'u-track red', 'u-track blue'})
% displays the red and blue image channel, the outline from the
% segmentation mask and overlays points from pointset 'u-track red' and
% 'u-track blue'.

function beads_showImage(mci, showChannels, pointSetNames)

    % check input
    if any(showChannels(1:3)) && showChannels(4)
        error('Cannot display rgb channel and gray channel at the same time');
    end
    
    channelsArray = loadChannels(mci, showChannels);
    
    imageArray = createImage(showChannels, channelsArray);
    segmentation = bwboundaries(squeeze(channelsArray(:,:,5)));
    
    imshow([]);
    cla;
        
    % display image
    if ~isempty(imageArray)
%         image(imageArray, 'CDataMapping', 'scaled')
            switch size(imageArray,3)
                case 1
                    imshow(imageArray,[prctile(imageArray(:),5), prctile(imageArray(:),98)]);
                case 3
                    rgbArray = imageArray / 2^16;
                    r = imadjust(rgbArray(:,:,1), stretchlim(rgbArray(:,:,1),[0.05 .99]),[]);
                    g = imadjust(rgbArray(:,:,2), stretchlim(rgbArray(:,:,2),[0.05 .99]),[]);
                    b = imadjust(rgbArray(:,:,3), stretchlim(rgbArray(:,:,3),[0.05 .99]),[]);
                    dispImage = cat(3,r,b,r);
                    imshow(dispImage);
                    hold on
            end
    else
        h = imshow(ones(size(channelsArray,1), size(channelsArray,2)));
        hold on
        delete(h);
        set(gca, 'Visible', 'on')
        set(gca, 'Layer', 'bottom');
        set(gca, 'GridLineStyle', '-');
        set(gca, 'GridAlpha', 1);
        set(gca, 'GridColor', [.7 .7 .7]);
        set(gca, 'MinorGridLineStyle', '-');
        set(gca, 'MinorGridAlpha', 1);
        set(gca, 'MinorGridColor', [.9 .9 .9]);
        set(gca, 'XGrid', 'on')
        set(gca, 'XMinorGrid', 'on')
        set(gca, 'YGrid', 'on')
        set(gca, 'YMinorGrid', 'on')
    end
    
    % plot points of selected pointsets
    if ~isempty(pointSetNames)
        [points, names] = getPoints(mci, pointSetNames);
        if iscell(pointSetNames)
            scatter(points{1}(:,1), points{1}(:,2), 2000, 'o', 'filled', ...
                'MarkerFaceColor' , [1 0 1], 'MarkerFaceAlpha', 0.1, ...
                'MarkerEdgeColor', [1 0 1], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
            scatter(points{2}(:,1), points{2}(:,2), 2000, 'o', 'filled', ...
                'MarkerFaceColor' , [0 1 0], 'MarkerFaceAlpha', 0.1, ...
                'MarkerEdgeColor', [0 1 0], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
            legend(names);
            scatter(points{1}(:,1), points{1}(:,2), 200, '+', ...
                'MarkerEdgeColor', [1 0 1], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
            scatter(points{2}(:,1), points{2}(:,2), 200, '+', ...
                'MarkerEdgeColor', [0 1 0], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
        elseif strfind(pointSetNames, 'blue')
            scatter(points{1}(:,1), points{1}(:,2), 2000, 'o', 'filled', ...
                'MarkerFaceColor' , [0 1 0], 'MarkerFaceAlpha', 0.2, ...
                'MarkerEdgeColor', [0 1 0], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
            scatter(points{1}(:,1), points{1}(:,2), 200, '+', ...
                'MarkerEdgeColor', [0 1 0], 'LineWidth', 3);
        elseif strfind(pointSetNames, 'red')
            scatter(points{1}(:,1), points{1}(:,2), 2000, 'o', 'filled', ...
                'MarkerFaceColor' , [1 0 1], 'MarkerFaceAlpha', 0.2, ...
                'MarkerEdgeColor', [1 0 1], 'MarkerEdgeAlpha', 0.6, 'LineWidth', 3);
            scatter(points{1}(:,1), points{1}(:,2), 200, '+', ...
                'MarkerEdgeColor', [1 0 1], 'LineWidth', 3);
        end
    end
    
%     display segmentation
    if ~isempty(segmentation)
        hold on
        for i = 1:length(segmentation)
            plot(segmentation{i}(:,2), segmentation{i}(:,1), 'y', 'LineWidth', 3);
        end
    end
    
end

function channelsArray = loadChannels(mci, showChannels)

    availableChannels = {mci.channels.name};

    chNames = {'red' 'green' 'blue' 'gray' 'mask'};
    info = imfinfo(mci.channels(1).path);
    channelsArray = zeros(info.Width,info.Height,length(chNames));
    for i = 1:length(chNames)
        if showChannels(i) && any(strcmp(availableChannels, chNames{i}))
            channelsArray(:,:,i)  = double(imread(mci.channels(strcmp(availableChannels, chNames{i})).path));
        end
    end
    
end

function imageArray = createImage(showChannels, channelsArray)

    % create single channel or rgb image
    if showChannels(4)
        imageArray = channelsArray(:,:,4);
    elseif any(showChannels(1:3))
        imageArray = zeros(size(channelsArray,1),size(channelsArray,2),3);
        for i = 1:3
            if showChannels(i)
                imageArray(:,:,i) = channelsArray(:,:,i);
            end
        end
    else
        imageArray = [];
    end
    
    imageArray = squeeze(imageArray);
    
end

function [points, names] = getPoints(mci, pointSetNames)

    avalablePointSets = {mci.childPointSets};
    if ischar(pointSetNames)
        pointSetNames = {pointSetNames};
    end
    
    points = cell(0);
    for i = 1:length(pointSetNames)
        if strfind(pointSetNames{i}, ' rotated')
            rotPointSetNames = strrep(pointSetNames{i}, ' rotated', '');
            ptSet = mci.pointSetByName(rotPointSetNames);
            if ~isempty(ptSet)
                points{i} = ptSet.getAllPositions('rotated');
                names{i} = pointSetNames{i};
            end
        elseif strfind(pointSetNames{i}, ' registered')
            rotPointSetNames = strrep(pointSetNames{i}, ' registered', '');
            ptSet = mci.pointSetByName(rotPointSetNames);
            if ~isempty(ptSet)
                points{i} = ptSet.getAllPositions('registered');
                names{i} = pointSetNames{i};
            end
        else
            ptSet = mci.pointSetByName(pointSetNames{i});
            if ~isempty(ptSet)
                points{i} = ptSet.getAllPositions;
                names{i} = pointSetNames{i};
            end
        end
    end
    
end