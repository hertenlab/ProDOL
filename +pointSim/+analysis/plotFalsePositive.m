function figH = plotFalsePositive(dataset, pointSetFilterStrings, algorithms)

    % pointsets of interest are filtered on sigma and amplitude
    if nargin == 2
        ptSetNames = dataset.getPointSetNames();
        algorithms = pointSim.analysis.matchPointSets(ptSetNames, pointSetFilterStrings);
        algorithms = algorithms(~strcmp(algorithms, 'ground truth'));
    end
    
    [falsePosD, falsePosDErr, simulatedDensity] = imageSetData(dataset, algorithms);
    
    % False positive density vs. simulated density
    figH = figure;
    axes
    hold on
    drawBand(simulatedDensity, falsePosD, falsePosDErr);
    xlabel('simulated density / um^-^2')
    xlim([0 2])
    ylabel('false positive density / um^-^2')
    legend(algorithms)
    
end

function [falsePosD, falsePosDErr, simulatedDensity] = imageSetData(dataset, algorithms)
    n = length(dataset);
    [falsePosD, falsePosDErr, simulatedDensity] = ...
        deal(zeros(n,length(algorithms)));
    for i = 1:length(algorithms)
        [falsePosD(:,i), falsePosDErr(:,i), simulatedDensity(:,i)] = ...
            calcFPD(dataset, algorithms{i});
    end
end

function [meanFPD, stdFPD, simD] = calcFPD(obj, alg)
    
    [meanFPD, stdFPD, simD] = deal(zeros(length(obj),1));
    
    for i = 1:length(obj)
        
        falsePositiveDensity = zeros(length(obj(i).childImages),1);
        for j = 1:length(obj(i).childImages)
            mci = obj(i).childImages(j);
            algSet = mci.pointSetByName(alg);
            gtSet = mci.pointSetByName('ground truth');
            specificity = mci.resultByName('DOL', algSet, gtSet);
            falsePositiveDensity(j) = (1 - specificity) * algSet.pointDensity;
        end
        
        simD(i) = obj(i).descriptors.simulatedDensity;
        meanFPD(i) = mean(falsePositiveDensity);
        stdFPD(i) = std(falsePositiveDensity);
    
    end

end