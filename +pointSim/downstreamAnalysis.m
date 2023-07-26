load('y:\DOL Calibration\Data\SimData_realistic\green_background\Density-Simulation\analysis\greenSimPoints_full.mat');

imgSets = greenSimPoints;
%% bad performer: u-track single (unfiltered)
% low recall at high density (1.6 / um^-2)
figure(1)
showImage(imgSets(9).childImages(1), {'gray', 'mask'}, {'ground truth', 'u-track single'})
ROI = [300 300+100; 75 75+100];
xlim(ROI(1,:))
ylim(ROI(2,:))
% high false-positive at low density (0.2 / um^-2)
figure(2)
showImage(imgSets(3).childImages(7), {'gray', 'mask'}, {'ground truth', 'u-track single'})
ROI = [280 280+100; 40 40+100];
xlim(ROI(1,:))
ylim(ROI(2,:))

%% good performers: 
% u-track multi fltr sigma, amp
figure(3)
showImage(imgSets(9).childImages(15), {'gray', 'mask'}, {'ground truth', '', 'u-track multi fltr sigma, amp'})
ROI = [280 280+100; 6 6+100];
xlim(ROI(1,:))
ylim(ROI(2,:))
% thunderStorm multi fltr sigma
figure(4)
showImage(imgSets(9).childImages(11), {'gray', 'mask'}, {'ground truth', '', '', '', 'thunderStorm multi fltr sigma'})
ROI = [323 323+100; 40 40+100];
xlim(ROI(1,:))
ylim(ROI(2,:))

%% algorithm comparison

algorithms = {'u-track single', 'u-track multi fltr sigma, amp', 'thunderStorm multi fltr sigma'};
pointSim.analysis.plotRecallFoundDensity(imgSets, [], algorithms);
yticks([0 0.25 0.5 0.75 1])
legend('Location','southwest')

pointSim.analysis.plotRecall(imgSets, [], algorithms);
xticks(0:0.5:2)
yticks([0 0.25 0.5 0.75 1])
legend('Location','southwest')

pointSim.analysis.plotFalsePositive(imgSets, [], algorithms);
xticks(0:0.5:2)
yticks(0:.1:.5)
legend('hide')

pointSim.analysis.plotDensityCorrelation(imgSets, [], algorithms);
xticks(0:0.5:2)
yticks(0:0.5:2)
legend('hide')

%% algorithm comparison

pointSim.analysis.plotRecallFoundDensity(redSimPoints, [], algorithms);
yticks([0 0.25 0.5 0.75 1])
legend('Location','southwest')

pointSim.analysis.plotRecall(redSimPoints, [], algorithms);
xticks(0:0.5:2)
yticks([0 0.25 0.5 0.75 1])
legend('Location','southwest')

pointSim.analysis.plotFalsePositive(redSimPoints, [], algorithms);
xticks(0:0.5:2)
yticks(0:.1:.5)
legend('hide')

pointSim.analysis.plotDensityCorrelation(redSimPoints, [], algorithms);
xticks(0:0.5:2)
yticks(0:0.5:2)
legend('hide')

%% density correction for optimized algorithms

pointSim.analysis.plotDensityCorrection(greenSimPoints, {'thunderStorm multi fltr sigma'});
yticks([0 0.25 0.5 0.75 1])

pointSim.analysis.plotDensityCorrection(redSimPoints, {'thunderStorm multi fltr sigma'});
yticks([0 0.25 0.5 0.75 1])

pointSim.analysis.plotDensityCorrection(imgSets, {'u-track multi fltr sigma, amp'});
yticks([0 0.25 0.5 0.75 1])