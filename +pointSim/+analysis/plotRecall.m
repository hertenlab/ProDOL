function figH = plotRecall(dataset, pointSetFilterStrings, algorithms)

    % pointsets of interest are filtered on sigma and amplitude
    if nargin == 2
        ptSetNames = dataset.getPointSetNames();
        algorithms = pointSim.analysis.matchPointSets(ptSetNames, pointSetFilterStrings);
        algorithms = algorithms(~strcmp(algorithms, 'ground truth'));
    end
    
    [recall, recallErr, simulatedDensity] = imageSetData(dataset, algorithms);

    % Recall vs. simulated density
    figH = figure;
    axes
    hold on
    drawBand(simulatedDensity, recall, recallErr);
    xlabel('simulated density / um^-^2')
    xlim([0 2])
    ylabel('recall')
    ylim([0 1])
    legend(algorithms)

end

function [recall, recallErr, simulatedDensity] = imageSetData(dataset, algorithms)
    n = length(dataset);
    [recall, recallErr, simulatedDensity] = ...
        deal(zeros(n,length(algorithms)));
    for i = 1:length(algorithms)
        [recall(:,i), recallErr(:,i), simulatedDensity(:,i)] = ...
            dataset.resultByName('mean DOL', 'ground truth', algorithms{i});
    end
end