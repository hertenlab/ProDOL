function figH = plotDensityCorrection(dataset, algorithm)

    [cellSimulatedDensity, cellFoundDensity, cellRecall] = imageData(dataset, algorithm);
    
    if iscell(algorithm)
        for i = 1:length(algorithm)
            figH(i) = plotSingleDensityCorrection(algorithm{i}, ...
                cellRecall(:,:,i), cellSimulatedDensity(:,:,i), cellFoundDensity(:,:,i));
%             plotSingleDensityCorrelation(algorithm, ...
%                 cellRecall(:,:,i), cellSimulatedDensity(:,:,i), cellFoundDensity(:,:,i));
        end
    else
        figH = plotSingleDensityCorrection(algorithm, ...
            cellRecall, cellSimulatedDensity, cellFoundDensity);
%         plotSingleDensityCorrelation(algorithm, ...
%             cellRecall, cellSimulatedDensity, cellFoundDensity);
    end
end

function [cellSimD, cellFoundD, cellRecall] = imageData(dataset, algorithms)

    [cellSimD, cellFoundD, cellRecall] = deal(nan(length(dataset(1).childImages), length(dataset), length(algorithms)));
    for k = 1:length(dataset)
        for j = 1:length(dataset(k).childImages)
            dolans = dataset(k).childImages(j).results;
            gtSet = dataset(k).childImages(j).pointSetByName('ground truth');
            for i = 1:length(algorithms)
                targetSet = dataset(k).childImages(j).pointSetByName(algorithms{i});
                cellFoundD(j,k,i) = targetSet.pointDensity;
                cellSimD(j,k,i) = dataset(k).descriptors.simulatedDensity;
                dolDolan = dolans.dolanByVars('varName', 'DOL', 'basePointSet', gtSet, 'targetPointSet', targetSet);
                cellRecall(j,k,i) = dolDolan.value;
            end
        end
    end
    
end

function figH = plotSingleDensityCorrection(algorithm, cellRecall, cellSimulatedDensity, cellFoundDensity)
        
    % Per cell recall vs. found density
    figH = figure;

    fitRecall = cellRecall(~isnan(cellRecall));
    fitDensity = cellFoundDensity(~isnan(fitRecall));
    linfit = fit(fitDensity, fitRecall, 'poly1');

    plot(fitDensity, fitRecall, 'o');
    hold on
    plot(linfit)
    text(.1, .1, sprintf('Recall = %.4f * x + %.4f', linfit.p1, linfit.p2), 'Color', 'red')
    p11 = predint(linfit,xlim,0.95);
    plot(xlim,p11, 'r:');
    legend('cell data', 'linear fit', '95 % prediction')

    title(algorithm)
    xlabel('found density / um^-^2')
    ylabel('recall')
    xlim([0 1.5])
    ylim([0 1])

end

function plotSingleDensityCorrelation(algorithm, cellRecall, cellSimulatedDensity, cellFoundDensity)

    figure
    plot(cellSimulatedDensity, cellFoundDensity, 'o');
    
    title(algorithm)
    xlabel('simulated density / um^-^2')
    ylabel('found density / um^-^2')

end