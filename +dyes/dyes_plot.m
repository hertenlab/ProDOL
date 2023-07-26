
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