function [medianSigmas, stdSigmas] = sigmaHistogram(imgSet, pointSetNames)
    
    figure
    axes
    hold on
    for i = 1:length(pointSetNames)
        sigmas{i} = collectSigmas(imgSet, pointSetNames{i});
        histogram(sigmas{i}, 'BinWidth', .1, 'Normalization', 'probability');
    end
    legend(pointSetNames);
    xlim([0 5])
    xlabel('sigma / px')
    ylabel('probability')
    
    medianSigmas = cellfun(@median,sigmas);
    stdSigmas = cellfun(@std,sigmas);
    
end

function sigmas = collectSigmas(imgSet, pointSetName)

    pointSets = imgSet.getPointSetsByName(pointSetName);
    allPoints = cat(1,pointSets.points);
    sigmas = allPoints(:,8);

end