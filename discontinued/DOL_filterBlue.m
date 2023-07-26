
input_matfile = 'y:\DOL Calibration\Data\sigi\analysis\sigi_rg-90-0nM.mat';
load(input_matfile);


%% Multi threshold test at one condition
% mean DOL for Green, 50nM, 1h
myCondi = concentration == 50 & incubation_time == 1 & strcmp(CellType, 'gSEP');
thresholdColoc = 1.7;

% base dataset
thresh = 0;
DOL = mean(pGreen(myCondi,thresholdColoc*10));
DOL_s = std(pGreen(myCondi,thresholdColoc*10));
numPoints = length([Points_Blue_A{myCondi}]);


% threshold amplitudes to test: 100:50:1000
thresholds = 50:50:2000;
figure(2)
axes()
cla
yyaxis left
errorbar(thresh,DOL, DOL_s, 'Marker', 'x', 'LineStyle', 'none');
ylim([0.26 0.4]);
yyaxis right
plot(thresh,numPoints, 'Marker', 'x', 'LineStyle', 'none');
xlim([-50 2050]);
for ii = 1:length(thresholds)
    filterPointsDOL_Blue(input_matfile, thresholds(ii), thresholdColoc);
    thresh(ii+1) = thresholds(ii);
    DOL(ii+1) = mean(pGreen(myCondi,thresholdColoc*10));
    DOL_s(ii+1) = std(pGreen(myCondi,thresholdColoc*10));
    numPoints(ii+1) = length([Points_Blue_A{myCondi}]);
    figure(2)
    yyaxis left
    errorbar(thresh,DOL,DOL_s, 'Marker', 'x', 'LineStyle', 'none');
    yyaxis right
    plot(thresh,numPoints, 'Marker', 'x', 'LineStyle', 'none');
end

xlabel('amplitude threshold')
yyaxis left
ylabel('DOL')
yyaxis right
ylabel('total number of points')
title({'blue point filtering' 'DOL Red on Sigi, gSEP, 50nM, 1h (11 cells)'})

return
%% Single threshold on full dataset

thresholdColoc = 0.1:0.1:4;

filterPointsDOL_blueOnly(input_matfile, 500, thresholdColoc);

%% MUlti threshold on full dataset

input_matfile = 'y:\DOL Calibration\Data\wioleta\analysis\wioleta_rg-75-0nM.mat';
load(input_matfile, 'pGreen', 'pRed', 'Points_Blue_A', 'CellType', ...
    'incubation_time', 'concentration', 'replicate');

thresholdColoc = 1.7;
thresholds = 0:50:2000;

DOLt = struct('Green', [], 'Red', []);
DOLt.Green = pGreen(:,thresholdColoc*10);
DOLt.Red = pRed(:,thresholdColoc*10);
numP = cellfun(@length,Points_Blue_A);

% Filter them blue points
for ii = 2:length(thresholds)
    fprintf('\n%d / %d\n', ii, length(thresholds));
    filterPointsDOL_blueOnly(input_matfile, thresholds(ii), thresholdColoc);
    DOLt.Green = [DOLt.Green, pGreen(:,thresholdColoc*10)];
    DOLt.Red = [DOLt.Red, pRed(:,thresholdColoc*10)];
    numP = [numP, cellfun(@length,Points_Blue_A)];
end
concrange = [0 0.1 1 5 10 50 100 250];
inctime = [0.25 0.5 1 3 16];
uisave({'DOLt' 'numP' 'thresholds' 'input_matfile', 'concrange', 'inctime',...
    'concentration', 'incubation_time', 'CellType'})

%% plot
myCT = 'gSEP';
myTime = 3;
myConc = 0;
myCh = 'Green';

for i = 1:length(inctime)
    myTime = inctime(i);
    myCondi = concentration == myConc & incubation_time == myTime & strcmp(CellType, myCT);
    figure()
    yyaxis left
    cla
%     errorbar(thresholds,mean(DOLt.(myCh)(myCondi,:)), std(DOLt.Green(myCondi,:)), 'Marker', '+', 'MarkerSize', 5, 'LineStyle', 'none', 'LineWidth', 3);
    plot(thresholds,mean(DOLt.(myCh)(myCondi,:)), 'Marker', 'x', 'LineStyle', 'none');
%     ylim([0 0.5]);
    grid on
    yyaxis right
    cla
    plot(thresholds,sum(numP(myCondi,:)), 'Marker', 'x', 'MarkerSize', 10, 'LineStyle', 'none', 'LineWidth', 3);
    xlim([-50 2050]);
%     xlabel('amplitude threshold')
    yyaxis left
%     ylabel('DOL')
    yyaxis right
%     ylabel('total number of points')
    ylim([0 50000]);
    params = [myCT ', ' num2str(myTime), 'h, ' num2str(myConc), 'nM (' num2str(sum(myCondi)) ' cells)'];
    title({params})
end
