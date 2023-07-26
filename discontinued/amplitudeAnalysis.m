%%
% Amplitude-to-offset histograms for different samples
load('y:\DOL Calibration\Data\sigi\analysis\sigi_base_1.2.mat')
clr_c = jet(5);
concrange = [0 250] %0.1 1 5 10 50 100 250];
%% amplitudes histograms green
figure(1)
cla

exp_index = incubation_time == 3 & strcmp(CellType, 'gSEP');
hist_binwidth = 3;
histogram([Points_Green_A{exp_index & concentration == 0}],...
    'BinWidth', hist_binwidth, 'Normalization','cdf',...
    'DisplayStyle', 'stairs','LineWidth', 1.5, 'LineStyle', '-', 'EdgeColor', 'g');
hold on
histogram([Points_Green_A{exp_index & concentration == 50}],...
    'BinWidth', hist_binwidth, 'Normalization','cdf',...
    'DisplayStyle', 'stairs','LineWidth', 1.5, 'LineStyle', '-', 'EdgeColor', 'g');

m3 = prctile([Points_Green_A{exp_index & concentration == 0}],90)
plot([m3 m3], ylim, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1.5)


histogram([Points_Red_A{exp_index & concentration == 0}],...
    'BinWidth', hist_binwidth, 'Normalization','cdf',...
    'DisplayStyle', 'stairs','LineWidth', 1.5, 'LineStyle', '-', 'EdgeColor', 'r');
hold on
histogram([Points_Red_A{exp_index & concentration == 50}],...
    'BinWidth', hist_binwidth, 'Normalization','cdf',...
    'DisplayStyle', 'stairs','LineWidth', 1.5, 'LineStyle', '-', 'EdgeColor', 'r');

m3 = prctile([Points_Red_A{exp_index & concentration == 0}],90);
plot([m3 m3], ylim, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1.5)

plot(xlim, [0.9 0.9], '-k')
xlim([0 1000])
xticks([0 500 1000])
xlabel('amplitude [a.u.]')
ylim([0 1])
yticks([0 0.5 0.9 1])
ylabel('cumulative density')
legend({'unstained 16h' '250 nM 16h' 'threshold value'})
autoArrangeFigures
