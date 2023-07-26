function figH = plotDensityCorrelation(dataset, pointSetFilterStrings, algorithms)

    % pointsets of interest are filtered on sigma and amplitude
    if nargin == 2
        ptSetNames = dataset.getPointSetNames();
        algorithms = pointSim.analysis.matchPointSets(ptSetNames, pointSetFilterStrings);
        algorithms = algorithms(~strcmp(algorithms, 'ground truth'));
    end
    
    [foundD, foundDErr, simulatedDensity] = imageSetData(dataset, algorithms);
    
    
    % Found vs. simulated density
    figH = figure;
    axes
    hold on
    drawBand(simulatedDensity, foundD, foundDErr);
    xlabel('simulated density / um^-^2')
    xlim([0 2])
    ylabel('found density / um^-^2')
    ylim(xlim)
    legend(algorithms)
    hold on
    plot(xlim, ylim, '--k')
    
end
    

function [foundD, foundDErr, simulatedDensity] = imageSetData(dataset, algorithms)

    n = length(dataset);
    [foundD, foundDErr, simulatedDensity] = ...
        deal(zeros(n,length(algorithms)));
    for i = 1:length(algorithms)
        [foundD(:,i), foundDErr(:,i), simulatedDensity(:,i)] = ...
            dataset.resultByName('mean Density', algorithms{i}, []);
    end
    
end