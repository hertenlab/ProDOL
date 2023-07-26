function figH = plotDolRecall(dolSimSet, correctionParams, figH)

    offset = correctionParams(1);
    slope = correctionParams(2);

    % density correction
    dolSimSet.densityCorrection('ground truth', 'thunderStorm multi partial fltr sigma',  offset, slope);

    density = [0.6 1.6];
    [simDol, meanDol, errDol] = deal(nan(19,4));
    for d = 1:2
        subSet = dolSimSet.imageSetByDescriptor('simulatedDensity', density(d));

        subResults = [subSet.results];
        descriptors = [subSet.descriptors];
        simDol(:,d) = [descriptors.simulatedDOL];
        simDol(:,d+2) = [descriptors.simulatedDOL];
        % raw dol
        meanDol(:,d) = [subResults.dolanByVars('varName', 'mean DOL', ...
            'targetPointSet', 'thunderStorm multi partial fltr sigma',...
            'basePointSet', 'ground truth').value];
        errDol(:,d) = [subResults.dolanByVars('varName', 'mean DOL', ...
            'targetPointSet', 'thunderStorm multi partial fltr sigma',...
            'basePointSet', 'ground truth').uncertainty];
        % density corrected dol
        meanDol(:,d+2) = [subResults.dolanByVars('varName', 'mean DOL corrected', ...
            'targetPointSet', 'thunderStorm multi partial fltr sigma',...
            'basePointSet', 'ground truth').value];
        errDol(:,d+2) = [subResults.dolanByVars('varName', 'mean DOL corrected', ...
            'targetPointSet', 'thunderStorm multi partial fltr sigma',...
            'basePointSet', 'ground truth').uncertainty];
    end

    if nargin < 3 || isempty(figH)
        figH = figure;
    else
        figure(figH);
    end
    cla reset
    drawBand(simDol, meanDol, errDol)
    set(gca, 'PlotBoxAspectRatio', [1 1 1]);
    set(gca, 'Box', 'on')
    xlabel('simulated DOL')
    ylabel('found DOL')
    xticks([0 0.25 0.5 0.75 1])
    yticks(xticks)
    ylim(xlim)
    legend('raw 0.6 um^-^2', 'raw 1.6 um^-^2', 'corrected 0.6 um^-^2', 'corrected 1.6 um^-^2', 'Location', 'northwest')
    plot(xlim,ylim, ':k')

end