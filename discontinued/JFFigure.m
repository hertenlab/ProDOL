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
    abc = dyes(strcmp(ID_combi{i},combination));
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
all_dye = [dye1; dye2];

mytable2 = table(all_dye, all_combi, all_load, all_ct, all_DOL, all_DOLstd, ...
    all_Density, all_Densitystd);

%%
index = strcmp(all_load,'high') & strcmp(all_ct,'gSEP');
subtable = mytable2(index, [1:2 5:end]);
clm1 = {'TMR' 'JF549' 'SiR' 'JF646'};
for i = 1:8
    for j = 1:4
        if contains(subtable.all_dye(i), clm1{j}) && contains(subtable.all_dye(i), 'HA')
            clm2(j) = subtable.all_DOL(i);
            clm3(j) = subtable.all_DOLstd(i);
        elseif contains(subtable.all_dye(i), clm1{j}) && contains(subtable.all_dye(i), 'BG')
            clm4(j) = subtable.all_DOL(i);
            clm5(j) = subtable.all_DOLstd(i);
        end
    end
end

index = strcmp(all_load,'high') & strcmp(all_ct,'LynG');
subtable = mytable2(index, [1:2 5:end]);
for i = 1:8
    for j = 1:4
        if contains(subtable.all_dye(i), clm1{j}) && contains(subtable.all_dye(i), 'HA')
            clm6(j) = subtable.all_Density(i);
            clm7(j) = subtable.all_Densitystd(i);
        elseif contains(subtable.all_dye(i), clm1{j}) && contains(subtable.all_dye(i), 'BG')
            clm8(j) = subtable.all_Density(i);
            clm9(j) = subtable.all_Densitystd(i);
        end
    end
end
t = table(clm1', clm2', clm3', clm4', clm5', clm6', clm7', clm8', clm9');
t.Properties.VariableNames = {'name'...
    'DOL_HaloTag_mean' 'DOL_HaloTag_std'...
    'DOL_SnapTag_mean' 'DOL_SnapTag_std'...
    'wtDensity_HaloTag_mean' 'wtDensity_HaloTag_std'...
    'wtDensity_SnapTag_mean' 'wtDensity_SnapTag_std'};


%%

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
% set(gca,'TickLength',[0 0])
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
% set(gca,'TickLength',[0 0])
xtickangle(45)
legend({'HaloTag' 'SNAP-tag'})