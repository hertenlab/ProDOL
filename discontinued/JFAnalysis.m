%%
clear all
analysisfilepath = 'y:\DOL Calibration\Data\JF-dyes\analysis\JF_analysis_rg-90-0nM_b-A800.mat';
load(analysisfilepath);
%%

%     filterPointsDOLJF(analysisfilepath, 200);
%     [pth, nm, ext] = fileparts(analysisfilepath);
%     newname = strrep(nm, 'analysis', 'analysis_rg-A2C-0.2_bA2C-0.5');
%     newpath = fullfile(pth, [newname '.mat']);
%     save(newpath);

%% correct falsely labeled cells
% assign "A LynG high" to "A LynG no" and vice versa

dye_load = switchHigh2no(CellType, dye_combination, dye_load);

%%

dyes = {'JF549-HA', 'JF646-BG', 'JF646-HA', 'JF549-BG', 'TMR-HA', 'SiR-BG', 'SiR-HA', 'TMR-BG'};
combination = {'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D'};
loads = {'high', 'low', 'no'};
Cells = {'gSEP', 'LynG'};
distance_threshold = 17;

% Calculate Particle Densities
pixelSize = 0.095 * ones(length(replicate),1);

Density_Blue = BlueParticles./(AllAreas.*(pixelSize.^2));
Density_Green = GreenParticles./(AllAreas.*(pixelSize.^2));
Density_Red = RedParticles./(AllAreas.*(pixelSize.^2));

%%Correct DOL for particle density
pGreen = pGreen./(-0.17*Density_Green+1);
pRed = pRed./(-0.17*Density_Red+1);
pBlue = pBlue./(-0.17*Density_Blue+1);

[MeanDOL, StdDOL] = deal(zeros(length(dyes), length(loads), length(Cells)));
[DOL, annotation] = deal(cell(length(dyes), length(loads), length(Cells)));
S = struct();
l = 1;

[DOL_HaloTag, DOL_SnapTag, Density_HaloTag, Density_SnapTag] = ...
    deal(zeros(length(CellType),1));

for i = 1:length(CellType)
    if any(strcmp(dye_combination{i}, {'A', 'C'}))
        DOL_HaloTag(i) = pGreen(i, distance_threshold);
        DOL_SnapTag(i) = pRed(i, distance_threshold);
        Density_HaloTag(i) = Density_Green(i);
        Density_SnapTag(i) = Density_Red(i);
    elseif any(strcmp(dye_combination{i}, {'B', 'D'}))
        DOL_HaloTag(i) = pRed(i, distance_threshold);
        DOL_SnapTag(i) = pGreen(i, distance_threshold);
        Density_HaloTag(i) = Density_Red(i);
        Density_SnapTag(i) = Density_Green(i);
    end
end

[sampleGroups, ID_combi, ID_load, ID_ct] = findgroups(dye_combination,dye_load,CellType);
ID_groups = [ID_combi, ID_load, ID_ct];
nameGroups = cell(length(ID_groups),1);
for i=1:length(ID_groups)
    nameGroups{i} = [ID_combi{i},' ', ID_load{i}, ' ', ID_ct{i}];
end

mean_DOL_HaloTag = splitapply(@mean,DOL_HaloTag,sampleGroups);
mean_DOL_SnapTag = splitapply(@mean,DOL_SnapTag,sampleGroups);
std_DOL_HaloTag = splitapply(@std,DOL_HaloTag,sampleGroups);
std_DOL_SnapTag = splitapply(@std,DOL_SnapTag,sampleGroups);
mean_Density_HaloTag = splitapply(@mean,Density_HaloTag,sampleGroups);
mean_Density_SnapTag = splitapply(@mean,Density_SnapTag,sampleGroups);
std_Density_HaloTag = splitapply(@std,Density_HaloTag,sampleGroups);
std_Density_SnapTag = splitapply(@std,Density_SnapTag,sampleGroups);
mytable = table(ID_combi, ID_load, ID_ct,mean_DOL_HaloTag, mean_DOL_SnapTag , std_DOL_HaloTag ,std_DOL_SnapTag ,mean_Density_HaloTag, mean_Density_SnapTag ,std_Density_SnapTag);


%%
dye1 = ID_combi;
dye2 = ID_combi;
for i=1:length(ID_combi)
    abc = dyes(strcmp(ID_combi{i},combination))
    dye1(i) = abc(1);
    dye2(i) = abc(2);
end

all_combi = [ID_combi; ID_combi];
all_load = [ID_load; ID_load];
all_ct = [ID_ct; ID_ct];
all_DOL = [mean_DOL_HaloTag; mean_DOL_SnapTag];
all_DOLstd = [std_DOL_HaloTag; std_DOL_SnapTag];
all_Density = [mean_Density_HaloTag; mean_Density_SnapTag];
all_Densitystd = [std_Density_HaloTag; std_Density_SnapTag];
all_dye = [dye1; dye2]

mytable2 = table(all_dye, all_combi, all_load, all_ct, all_DOL, all_DOLstd, ...
    all_Density, all_Densitystd)


%%
index_HA = strcmp(all_load,'high') & strcmp(all_ct,'gSEP') & contains(all_dye, 'HA');
index_BG = strcmp(all_load,'high') & strcmp(all_ct,'gSEP') & contains(all_dye, 'BG');
index_HA_LnyG = strcmp(all_load,'high') & strcmp(all_ct,'LynG') & contains(all_dye, 'HA');
index_BG_LnyG = strcmp(all_load,'high') & strcmp(all_ct,'LynG') & contains(all_dye, 'BG');

dd = {'JF549'; 'JF646'; 'TMR'; 'SiR'};
t = table(dd, all_DOL(index_HA), all_DOLstd(index_HA), all_DOL(index_BG), all_DOLstd(index_BG),...
    all_Density(index_HA_LnyG), all_Densitystd(index_HA_LnyG), all_Density(index_BG_LnyG), all_Densitystd(index_BG_LnyG));
t.Properties.VariableNames = {'name'...
    'DOL_HaloTag_mean' 'DOL_HaloTag_std'...
    'DOL_SnapTag_mean' 'DOL_SnapTag_std'...
    'wtDensity_HaloTag_mean' 'wtDensity_HaloTag_std'...
    'wtDensity_SnapTag_mean' 'wtDensity_SnapTag_std'};

% DOL
figure(1)
cla
data = [t.DOL_HaloTag_mean t.DOL_SnapTag_mean];
err = [t.DOL_HaloTag_std t.DOL_SnapTag_std];
ctrs = (1:size(data,1));
hBar = bar(ctrs, data, 'LineWidth', 1.3);
hBar(1).FaceColor = [0.1 0.75 0.9];
hBar(2).FaceColor = [0.9 0.3 0.6];
hold on

clear ctr ydt
for k1 = 1:size(data,2)
    ctr(:,k1) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
    ydt(:,k1) = hBar(k1).YData;
end
errorbar(ctr, ydt, err, '.k', 'LineWidth', 1.2)

ylabel('Degree of Labeling')
% set(gca,'YGrid','on')
% set(gca,'YMinorGrid','on')
ylim([0 .4])
yticks([0 0.2 0.4])
xticklabels(t.name)
set(gca,'TickLength',[0 0])
xtickangle(45)

% wt Density

figure(2)
cla
data = [t.wtDensity_HaloTag_mean t.wtDensity_SnapTag_mean];
err = [t.wtDensity_HaloTag_std t.wtDensity_SnapTag_std];
ctrs = (1:size(data,1));
hBar = bar(ctrs,data,'LineWidth', 1.3);
hBar(1).FaceColor = [0.1 0.75 0.9];
hBar(2).FaceColor = [0.9 0.3 0.6];

clear ctr ydt
for k1 = 1:size(data,2)
    ctr(:,k1) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
    ydt(:,k1) = hBar(k1).YData;
end
hold on
errorbar(ctr, ydt, err, '.k', 'LineWidth', 1.3)
ylabel('Point Density in wt [µm^-^1]')
% set(gca,'YGrid','on')
% set(gca,'YMinorGrid','on')
ylim([0 1.1])
yticks([0 0.5 1])
xticklabels(t.name)
set(gca,'TickLength',[0 0])
xtickangle(45)
legend({'HaloTag' 'SNAP-tag'})


%%
index = (strcmp(ID_load,'high') | strcmp(ID_load,'low')) & strcmp(ID_ct,'gSEP');
data = mean_DOL_SnapTag(index);
err = std_DOL_SnapTag(index);
ctrs = (1:size(data,1));

% figure('Name', 'HaloTag filtered')
hBar = bar(ctrs, data);
% for k1 = 1:size(data,1)
%     ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%     ydt(k1,:) = hBar(k1).YData;
% end
hold on
errorbar(ctrs, data, err, '.k')
hold off
ax = gca;
ylim([0 0.5]);
xticklabels(nameGroups(index))
xtickangle(90)


% %%
% data = [mean_high_gSEP mean_low_gSEP mean_no_gSEP mean_high_LynG mean_low_LynG mean_no_LynG];
% err = [std_high_gSEP std_low_gSEP std_no_gSEP std_high_LynG std_low_LynG std_no_LynG];
% ctrs = 1:4;
% figure(1,'Name', 'HaloTag filtered')
% hBar = bar(ctrs, data);
% for k1 = 1:size(data,2)
%     ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%     ydt(k1,:) = hBar(k1).YData;
% end
% hold on
% errorbar(ctr', ydt', err, '.k')
% hold off
% ax = gca;
% ylim([0 0.5]);
% ax.XTickLabel = dyes_HA;
% legend('gSEP high', 'gSEP low', 'gSEP no', 'LynG high', 'LynG low', 'LynG no')


%%

for i = 1:length(dyes)
    for j = 1:length(loads)
        for k = 1:length(Cells)
            if contains(dyes{i}, {'JF646', 'SiR'})
                clr_channel = 'Red';
            elseif contains(dyes{i}, {'JF549', 'TMR'})
                clr_channel = 'Green';
            end
            
            switch clr_channel
                case 'Red'
                    DOL{i,j,k} = pRed(...
                        strcmp(dye_combination, combination{i}) & ...
                        strcmp(CellType, Cells{k}) & ...
                        strcmp(dye_load, loads{j}), distance_threshold);
                case 'Green'
                    DOL{i,j,k} = pGreen(...
                        strcmp(dye_combination, combination{i}) & ...
                        strcmp(CellType, Cells{k}) & ...
                        strcmp(dye_load, loads{j}), distance_threshold);
            end
            
            MeanDOL(i,j,k) = mean(DOL{i,j,k});
            StdDOL(i,j,k) = std(DOL{i,j,k});
            annotation{i,j,k} = [dyes{i} '_' loads{j}, '_' Cells{k}];
            S(l).DOL = DOL{i,j,k};
            S(l).MeanDOL = mean(DOL{i,j,k});
            S(l).StdDOL = std(DOL{i,j,k});
            S(l).annotation = annotation{i,j,k};
            S(l).Dye = dyes{i};
            S(l).load = loads{j};
            S(l).combination = combination{i};
            S(l).CellType = Cells{k};
            l = l+1;
        end
    end
end

%%
DOL_high = [S(strcmp({S.load}, 'high') & strcmp({S.CellType}, 'gSEP')).MeanDOL];
DOL_low = [S(strcmp({S.load}, 'low') & strcmp({S.CellType}, 'gSEP')).MeanDOL];
DOL_no = [S(strcmp({S.load}, 'no') & strcmp({S.CellType}, 'gSEP')).MeanDOL];


%% DOL HaloTag

dyes_HA = {'TMR-HA', 'SiR-HA', 'JF549-HA', 'JF646-HA'};
mean_high_gSEP = zeros(4,1);
std_high_gSEP = zeros(4,1);

% gSEP
ct = 'gSEP';
load = 'high';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_high_gSEP(i) = S(index).MeanDOL;
    std_high_gSEP(i) = S(index).StdDOL;
end

mean_low_gSEP = zeros(4,1);
std_low_gSEP = zeros(4,1);
load = 'low';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_low_gSEP(i) = S(index).MeanDOL;
    std_low_gSEP(i) = S(index).StdDOL;
end

mean_no_gSEP = zeros(4,1);
std_no_gSEP = zeros(4,1);
load = 'no';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_no_gSEP(i) = S(index).MeanDOL;
    std_no_gSEP(i) = S(index).StdDOL;
end

% LynG
mean_high_LynG = zeros(4,1);
std_high_LynG = zeros(4,1);
ct = 'LynG';
load = 'high';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_high_LynG(i) = S(index).MeanDOL;
    std_high_LynG(i) = S(index).StdDOL;
end

mean_low_LynG = zeros(4,1);
std_low_LynG = zeros(4,1);
load = 'low';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_low_LynG(i) = S(index).MeanDOL;
    std_low_LynG(i) = S(index).StdDOL;
end

mean_no_LynG = zeros(4,1);
std_no_LynG = zeros(4,1);
load = 'no';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_no_LynG(i) = S(index).MeanDOL;
    std_no_LynG(i) = S(index).StdDOL;
end

data = [mean_high_gSEP mean_low_gSEP mean_no_gSEP mean_high_LynG mean_low_LynG mean_no_LynG];
err = [std_high_gSEP std_low_gSEP std_no_gSEP std_high_LynG std_low_LynG std_no_LynG];
ctrs = 1:4;

figure('Name', 'HaloTag filtered')
hBar = bar(ctrs, data);
for k1 = 1:size(data,2)
    ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
    ydt(k1,:) = hBar(k1).YData;
end
hold on
errorbar(ctr', ydt', err, '.k')
hold off
ax = gca;
ylim([0 0.5]);
ax.XTickLabel = dyes_HA;
legend('gSEP high', 'gSEP low', 'gSEP no', 'LynG high', 'LynG low', 'LynG no')

%% DOL Snap-tag

dyes_BG = {'TMR-BG', 'SiR-BG', 'JF549-BG', 'JF646-BG'};
mean_high_gSEP = zeros(4,1);
std_high_gSEP = zeros(4,1);
load = 'high';
ct = 'gSEP';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_BG{i});
    mean_high_gSEP(i) = S(index).MeanDOL;
    std_high_gSEP(i) = S(index).StdDOL;
end
mean_low_gSEP = zeros(4,1);
std_low_gSEP = zeros(4,1);
load = 'low';
ct = 'gSEP';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_BG{i});
    mean_low_gSEP(i) = S(index).MeanDOL;
    std_low_gSEP(i) = S(index).StdDOL;
end

mean_no_gSEP = zeros(4,1);
std_no_gSEP = zeros(4,1);
load = 'no';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_no_gSEP(i) = S(index).MeanDOL;
    std_no_gSEP(i) = S(index).StdDOL;
end

mean_high_LynG = zeros(4,1);
std_high_LynG = zeros(4,1);
load = 'high';
ct = 'LynG';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_BG{i});
    mean_high_LynG(i) = S(index).MeanDOL;
    std_high_LynG(i) = S(index).StdDOL;
end
mean_low_LynG = zeros(4,1);
std_low_LynG = zeros(4,1);
load = 'low';
ct = 'LynG';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_BG{i});
    mean_low_LynG(i) = S(index).MeanDOL;
    std_low_LynG(i) = S(index).StdDOL;
end

mean_no_LynG = zeros(4,1);
std_no_LynG = zeros(4,1);
load = 'no';
for i =1:4
    index = strcmp({S.load}, load) & strcmp({S.CellType}, ct) & strcmp({S.Dye}, dyes_HA{i});
    mean_no_LynG(i) = S(index).MeanDOL;
    std_no_LynG(i) = S(index).StdDOL;
end

data = [mean_high_gSEP mean_low_gSEP mean_no_gSEP mean_high_LynG mean_low_LynG mean_no_LynG];
err = [std_high_gSEP std_low_gSEP std_no_LynG std_high_LynG std_low_LynG std_no_LynG];
ctrs = 1:4;

figure('name', 'SNAP-tag filtered')
hBar = bar(ctrs, data);
for k1 = 1:size(data,2)
    ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
    ydt(k1,:) = hBar(k1).YData;
end
hold on
errorbar(ctr', ydt', err, '.k')
hold off
ax = gca;
ax.XTickLabel = dyes_BG;
ylim([0 0.5]);
legend('gSEP high', 'gSEP low', 'gSEP no', 'LynG high', 'LynG low', 'LynG no')


%% DOL no dye

DOL_no = [S(strcmp({S.load}, 'no')).DOL];
names = {S(strcmp({S.load}, 'no')).annotation};
figure(3);
boxplot(DOL_no, 'labels', names, 'plotstyle', 'compact')
ylim([0 0.5]);
ax = gca;

%% Normalisation

for i = 1:length(CellType)
    grouper{i} = [CellType{i} dye_combination{i}];
end

Density_Green_rel = relativeBadabum(Density_Green, grouper, dye_load, 'no');
Density_Red_rel = relativeBadabum(Density_Red, grouper, dye_load, 'no');
Density_Blue_rel = relativeBadabum(Density_Blue, grouper, dye_load, 'no');
pGreen_rel = relativeBadabum(pGreen, grouper, dye_load, 'no');
pRed_rel = relativeBadabum(pRed, grouper, dye_load, 'no');

%% normalized point densities

[ggg ct dl dc] = findgroups(CellType, dye_load, dye_combination);
groupnames = strcat(ct, {' '}, dc, {' '}, dl);
% figure('name', 'density_blue');
% boxplot(Density_Blue, {CellType, dye_combination, dye_load});
% figure('name', 'density_blue normalized to median of no dye condition');
% boxplot(Density_Blue_rel, {CellType, dye_combination, dye_load});
% hold on
% plot(xlim, [1 1])


figure('name', 'density_green');
boxplot(Density_Green, {CellType, dye_combination, dye_load});
figure('name', 'density_green normalized to median of no dye condition');
boxplot(Density_Green_rel, {dye_combination, CellType, dye_load});
hold on
plot(xlim, [1 1])

figure('name', 'density_red');
boxplot(Density_Red, {CellType, dye_combination, dye_load});
figure('name', 'density_red normalized to median of no dye condition');
boxplot(Density_Red_rel, {dye_combination, CellType, dye_load});
hold on
plot(xlim, [1 1])

%%
figure
boxplot(pRed(:,17), {dye_combination, CellType, dye_load})


%% Point amplitude

% abc = strcmp(CellType, 'LynG') & strcmp(dye_combination, 'C');
% xhigh = strcmp(dye_load, 'high');
% xlow = strcmp(dye_load, 'low');
% xno = strcmp(dye_load, 'no');
% Ahigh = [Points_Green_A{abc&xhigh}];
% Alow = [Points_Green_A{abc&xlow}];
% Ano = [Points_Green_A{abc&xno}];
% myCell = {Ahigh Alow Ano};
% maxsize = max([length(Ahigh) length(Alow) length(Ano)]);
% myArray = NaN(3, maxsize);
% for x = 1:3
%     for y = 1:length(myCell{x})
%         myArray(x,y) = myCell{x}(y);
%     end
% end
% Points_Green_A(abc);
% figure
% boxplot(myArray',...
%     {'high' 'low' 'no'})