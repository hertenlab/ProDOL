%%
load('Y:\DOL Calibration\Data\klaus\analysis\klausSet.mat')
load('Y:\DOL Calibration\Data\wioleta_JTag\analysis\wioletaSet.mat')
load('Y:\DOL Calibration\Data\felix\analysis\felixSet.mat')
load('y:\DOL Calibration\Data\sigi\analysis\sigiSet.mat')
imgSet = sigiSet;

%% density correction

% imgSet.densityCorrection(baseName, targetName, offset, slope)
% 'thunderStorm green fltr sigma': offset = 0.8633, slope = -0.2385
% 'thunderStorm red fltr sigma': offset = 0.7847, slope = -0.2513
imgSet.calculateMeanColocalisation('thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma')
imgSet.calculateMeanColocalisation('thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma')

imgSet.densityCorrection('thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma', 0.8633, -0.2385)
imgSet.densityCorrection('thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma', 0.7847, -0.2513)
imgSet.densityCorrection('thunderStorm blue', 'thunderStorm green', 0.8633, -0.2385)
imgSet.densityCorrection('thunderStorm blue', 'thunderStorm red', 0.7847, -0.2513)

imgSet.calculateMeanColocalisation('uTrack blue', 'uTrack green')
imgSet.calculateMeanColocalisation('uTrack blue', 'uTrack red')
imgSet.densityCorrection('uTrack blue', 'uTrack green', 1, -0.17)
imgSet.densityCorrection('uTrack blue', 'uTrack red', 1, -0.17)



%% DOL errorband plots 

screen.analysis.plotDol(imgSet, 'mean DOL', 'thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma')
screen.analysis.plotDol(imgSet, 'mean DOL', 'thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma')
screen.analysis.plotDol(imgSet, 'mean DOL corrected', 'thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma')
screen.analysis.plotDol(imgSet, 'mean DOL corrected', 'thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma')
screen.analysis.plotDol(imgSet, 'mean DOL corrected', 'uTrack blue', 'uTrack red')
screen.analysis.plotDol(imgSet, 'mean DOL corrected', 'uTrack blue', 'uTrack green')

%% DOL surface plots
screen.analysis.plotSurf(imgSet, 'gSEP', 'mean DOL', 'uTrack blue', 'uTrack green')

screen.analysis.plotSurf(imgSet, 'gSEP', 'mean DOL corrected', 'thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma')
caxis([0 0.5])
zlim([0 .7])
screen.analysis.plotSurf(imgSet, 'LynG', 'mean DOL corrected', 'thunderStorm blue fltr sigma', 'thunderStorm red fltr sigma')
caxis([0 0.5])
zlim([0 .7])


screen.analysis.plotSurf(imgSet, 'gSEP', 'mean DOL corrected', 'thunderStorm blue', 'thunderStorm green')
caxis([0 0.5])
zlim([0 .7])
screen.analysis.plotSurf(imgSet, 'LynG', 'mean DOL corrected', 'thunderStorm blue fltr sigma', 'thunderStorm green fltr sigma')
caxis([0 0.5])
zlim([0 .7])
%% Density surface plots

screen.analysis.plotSurf(imgSet, 'gSEP', 'mean Density', 'thunderStorm blue fltr sigma', [])
caxis([0 1])
zlim([0 1.5])
