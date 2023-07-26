function plotDol(imgSet, dolType, baseName, targetName)

% one plot, DOL vs. concetration
% one color per time
% solid line for gSEP, dashed for LynG

dol = nan(8,5,2);
dolErr = nan(8,5,2);
timeArray = repmat(repmat([0.25 0.5 1 3 16],8,1),[1,1,2]);
concArray = repmat(repmat([0 0.1 1 5 10 50 100 250]',1,5),[1,1,2]);
cellArray = cat(3, repmat({'gSEP'}, 8, 5), repmat({'LynG'}, 8, 5));

    for i = 1:length(imgSet)
        thisTime = imgSet(i).descriptors.incubationTime;
        thisConc = imgSet(i).descriptors.concentration;
        thisCell = imgSet(i).descriptors.cellType;
        dolan = imgSet(i).results.dolanByVars('varName', dolType,...
            'basePointSet', baseName, 'targetPointSet', targetName);

        idx = timeArray == thisTime & concArray == thisConc & strcmp(cellArray, thisCell);

        dol(idx) = dolan.value;
        dolErr(idx) = dolan.uncertainty;

    end
    
    concPlot = repmat(repmat([0.01 0.1 1 5 10 50 100 250]',1,5),[1,1,2]);
    timeLinear = [0.25 0.5 1 3 16];
    concLinear = [0 0.1 1 5 10 50 100 250];
    for l = 1:2
        figure
        drawBand(squeeze(concPlot(:,:,l)), squeeze(dol(:,:,l)), squeeze(dolErr(:,:,l)))
        title(sprintf('%s - %s\n%s - %s', cellArray{1,1,l}, dolType, baseName, targetName))
        set(gca, 'XScale', 'log')
        
        xlabel('concentration [nM]')
        xlim([0.01 250])
        ylabel('DOL')
        ylim([0 1])
        set(gca,'xscale','log')
        legend(strcat(cellfun(@num2str, num2cell(timeLinear), 'UniformOutput', false), ' h'))
    end
    
end