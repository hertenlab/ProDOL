function figH = plotRecallFoundDensity(dataset, pointSetFilterStrings, algorithms)

    % pointsets of interest are filtered on sigma and amplitude
    if nargin == 2
        ptSetNames = dataset.getPointSetNames();
        algorithms = pointSim.analysis.matchPointSets(ptSetNames, pointSetFilterStrings);
        algorithms = algorithms(~strcmp(algorithms, 'ground truth'));
    end
    
    [recall, recallErr, foundD, foundDErr] = imageSetData(dataset, algorithms);

    % Recall vs. simulated density
    figH = figure;
    axes
    hold on
    drawBand(foundD, recall, recallErr);
    xlabel('found density / um^-^2')
    ylabel('recall')
    ylim([0 1])
    legend(algorithms)

end

function [recall, recallErr, foundD, foundDErr] = imageSetData(dataset, algorithms)
    n = length(dataset);
    [recall, recallErr, simulatedDensity] = ...
        deal(zeros(n,length(algorithms)));
    for i = 1:length(algorithms)
        [recall(:,i), recallErr(:,i)] = ...
            dataset.resultByName('mean DOL', 'ground truth', algorithms{i});
        [foundD(:,i), foundDErr(:,i), simulatedDensity(:,i)] = ...
            dataset.resultByName('mean Density', algorithms{i}, []);
    end
end