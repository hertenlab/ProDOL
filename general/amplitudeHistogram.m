function [medianSigmas, stdSigmas] = amplitudeHistogram(imgSet, pointSetNames)
    
    figure
    axes
    hold on
    for i = 1:length(pointSetNames)
        amps{i} = collectAmps(imgSet, pointSetNames{i});
        histogram(amps{i}, 'BinWidth', 20, 'Normalization', 'probability');
    end
    legend(pointSetNames);
    xlim([0 2000])
    xlabel('amplitude / photons')
    ylabel('probability')
    
    medianSigmas = cellfun(@median,amps);
    stdSigmas = cellfun(@std,amps);
    
end

function amps = collectAmps(imgSet, pointSetName)

    pointSets = imgSet.getPointSetsByName(pointSetName);
    allPoints = cat(1,pointSets.points);
    amps = allPoints(:,7);

end