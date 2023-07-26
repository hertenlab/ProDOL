
% dataType:
%   'mean DOL', 'mean DOL Random', 'mean DOL corrected', 
%   'mean multi-assignments', 'mean multi-assignments Random'
%   'mean Density'
% cellType:
%   'gSEP', 'LynG'
% targetName:
%   pointSetName of reference pointset, set to [] for 'mean Density'
% baseName:
%   pointSetName of pointset of interest

function plotSurf(imgSets, cellType, dataType, baseName, targetName)

    cellTypeSets = imgSets.imageSetByDescriptor('cellType', cellType);
    time = [0.25 0.5 1 3 16];
    conc = [0 0.1 1 5 10 50 100 250];
    for t = 1:length(time)
        for c = 1:length(conc)
            thisSet = cellTypeSets.imageSetByDescriptor('incubationTime', time(t),...
                'concentration', conc(c));
            sampleConc(t,c) = time(t);
            sampleTime(t,c) = conc(c);
            dolans = thisSet.results.dolanByVars('varName', dataType,...
                'basePointSet', baseName,...
                'targetPointSet' , targetName);
            meanData(t,c) = dolans.value;
            stdData(t,c) = dolans.uncertainty;
        end
    end

    % PLOT DOL surface plots
    xlinear = [0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
    ylinear = [0.25 0.5 1 3 16]; %incubation time

    figure
    surf(xlinear, ylinear, stdData, 'FaceColor', 'interp');

    xlabel('concentration [nM]')
    ylabel('incubation time [h]')
    zlabel('degree of labeling')

    set(gca,'xscale','log')
    set(gca,'yscale','log')
    ax = gca;
    ax.XTick = xlinear;%[1:8];
    ax.YTick = ylinear;%[1:5];
    ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
    ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
    ylim([0.25 16])
    xlim([0 500])
    text(0.02,0.25,'//')
    view(ax,[-19.5 34]);
    
    title({[cellType ' ' dataType]; ['base: ' baseName]; ['target: ' targetName]})
    
    % print results to console output
    
    rowNames = strcat('c_', cellfun(@num2str, num2cell(conc), 'UniformOutput', false), 'nM');
    varNames = {'t_15min', 't_30min', 't_1h', 't_3h', 't_16h'};
    dispData = array2table(round(meanData,3)', 'VariableNames', varNames, 'RowNames', rowNames);
    disp([inputname(1), ' - ' cellType, ' - ' dataType, ' - ', baseName, ' - ', targetName])
    disp(dispData);

end