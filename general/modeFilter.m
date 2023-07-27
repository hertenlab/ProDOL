function filterRange = modeFilter(imgSet,chan,filterParam,filterWidth,showPlot)

pointSets = imgSet.getPointSetsByName(chan);
childImages = [pointSets.parentImage];

if numel(pointSets)==0
    warning('imgSet does not contain channel %s',chan)
    filterRange = [];
    return
end

% check if filterParam is available for pointsets
tmp = vertcat(pointSets.pointsColumns);
tmp2 = sum(strcmp(filterParam,tmp));

if sum(tmp2==numel(pointSets))==1
    paramCol = find(tmp2==numel(pointSets));
else
    error('check input')
end
    
% use only cherrypicked cells if cherrypicking info is available
if sum([childImages.include])>0
    sel = [childImages.include];
else
    sel = repmat(true,1,numel(childImages));
end
points = vertcat(pointSets(sel).points);

% determine mode
winStart = 0;
winWidth = 0.05;
winStop = 5;
bins = [winStart:winWidth:winStop];
xvals = [winStart+(winWidth/2):0.05:winStop-(winWidth/2)];
cts = histcounts(points(:,paramCol),bins,'Normalization','probability');
[~,modeParamDist] = max(cts);

if filterWidth > 1
    filterStart = 0;
else
    filterStart = xvals(modeParamDist)*(1-filterWidth);
end

filterStop = xvals(modeParamDist)*(1+filterWidth);

filterRange = [filterStart,filterStop];

if showPlot
    figure()
    histogram(points(:,paramCol),bins,'Normalization','probability');
    hold on
    line([xvals(modeParamDist),xvals(modeParamDist)],[0,max(cts)*1.1],'Color','r','LineStyle','-');
    line([filterStart filterStart],[0,max(cts)*1.1],'Color','r','LineStyle','--');
    line([filterStop filterStop],[0,max(cts)*1.1],'Color','r','LineStyle','--');
    xlim([winStart,winStop]);
    %ylim([0 max(cts)*1.1]);
    ylabel('Probability')
    xlabel(filterParam)
end
    
end
    
  