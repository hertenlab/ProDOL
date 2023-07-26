%% load data
load('Y:\DOL Calibration\Data\SimData_realistic\red_background\DOL-Simulation\dolSimRed.mat')
load('Y:\DOL Calibration\Data\SimData_realistic\green_background\DOL-Simulation\dolSimGreen.mat')

%% Channel images

ROI = [300 300+100; 75 75+100];

figure(1)
dolSim.showImage(dolSimGreen(10).childImages(2), {'partial' 'mask'}, {'ground truth' 'thunderStorm multi partial fltr sigma'})
xlim(ROI(1,:))
ylim(ROI(2,:))

%% plots
red = figure(2);
dolSim.analysis.plotDolRecall(dolSimRed, [0.7847, -0.2513], red);
title('red background')
green = figure(3);
dolSim.analysis.plotDolRecall(dolSimGreen, [0.8633, -0.2385], green);
title('green background')

%%
figure(4)
subSet = dolSimGreen.imageSetByDescriptor('simulatedDensity', 0.6);
simDol = [descriptors.simulatedDOL];
subResults = [subSet.results];
meanDol = [subResults.dolanByVars('varName', 'mean DOL corrected', ...
    'targetPointSet', 'thunderStorm multi partial fltr sigma',...
    'basePointSet', 'ground truth').value];
errDol = [subResults.dolanByVars('varName', 'mean DOL corrected', ...
    'targetPointSet', 'thunderStorm multi partial fltr sigma',...
    'basePointSet', 'ground truth').uncertainty];
errorbar(simDol, meanDol, errDol, '+k', 'LineWidth', 1);
hold on
set(gca, 'PlotBoxAspectRatio', [1 1 1]);
xticks([0 0.25 0.5 0.75 1])
yticks(xticks)
ylim(xlim)
plot(xlim,ylim, ':k')
xlabel('simulated DOL')
ylabel('found DOL')
title('green background, density 0.6 um^-^2')


