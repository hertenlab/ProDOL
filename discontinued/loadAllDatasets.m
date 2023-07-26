%%
klaus = load('y:\DOL Calibration\Data\klaus\analysis\klaus_base_1.2.mat');

felix = load('y:\DOL Calibration\Data\felix\analysis\felix_base_1.2.mat');

sigi = load('y:\DOL Calibration\Data\sigi\analysis\sigi_base_1.2.mat');

wioleta = load('y:\DOL Calibration\Data\wioleta\analysis\wioleta_base_1.2.mat');


%%
% population A/c for 0nM cells, cdf at 80%

for i = 1 : length(klaus.incubation_time)
    klaus.A2C_Blue{i} = klaus.Points_Blue_A{i} ./ klaus.Points_Blue_c{i};
    klaus.A2C_Green{i} = klaus.Points_Green_A{i} ./ klaus.Points_Green_c{i};
    klaus.A2C_Red{i} = klaus.Points_Red_A{i} ./ klaus.Points_Red_c{i};
end

for i = 1 : length(felix.incubation_time)
    felix.A2C_Blue{i} = felix.Points_Blue_A{i} ./ felix.Points_Blue_c{i};
    felix.A2C_Green{i} = felix.Points_Green_A{i} ./ felix.Points_Green_c{i};
    felix.A2C_Red{i} = felix.Points_Red_A{i} ./ felix.Points_Red_c{i};
end

for i = 1 : length(sigi.incubation_time)
    sigi.A2C_Blue{i} = sigi.Points_Blue_A{i} ./ sigi.Points_Blue_c{i};
    sigi.A2C_Green{i} = sigi.Points_Green_A{i} ./ sigi.Points_Green_c{i};
    sigi.A2C_Red{i} = sigi.Points_Red_A{i} ./ sigi.Points_Red_c{i};
end

for i = 1 : length(wioleta.incubation_time)
    wioleta.A2C_Blue{i} = wioleta.Points_Blue_A{i} ./ wioleta.Points_Blue_c{i};
    wioleta.A2C_Green{i} = wioleta.Points_Green_A{i} ./ wioleta.Points_Green_c{i};
    wioleta.A2C_Red{i} = wioleta.Points_Red_A{i} ./ wioleta.Points_Red_c{i};
end

%%
figure
histogram([klaus.A2C_Green{klaus.concentration == 0}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
hold on
histogram([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == 0.25}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == 0.5}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == 1}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == 3}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == 16}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
xlim([0 2])
legend({'all' '15min' '30min' '60min' '3h' '16h'})
plot([0 2], [0.8 0.8]);

%%
figure
histogram([klaus.A2C_Green{klaus.concentration == 0}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
hold on
histogram([felix.A2C_Green{felix.concentration == 0}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([wioleta.A2C_Green{wioleta.concentration == 0}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
histogram([sigi.A2C_Green{sigi.concentration == 0}], 'Normalization', 'cdf', 'DisplayStyle', 'stairs', 'BinWidth', 0.005)
xlim([0 2])
legend({'klaus' 'felix' 'wioleta' 'sigi'})
plot([0 2], [0.8 0.8]);

%%
inctime = [0.25 0.5 1 3 16];
for i = 1:5
    klaus.prctile(i) = prctile([klaus.A2C_Green{klaus.concentration == 0 & klaus.incubation_time == inctime(i)}], 80);
end