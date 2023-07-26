%% Load Workspace variables from file or import from u-track movielist and Intensities.txt

clear all

% load('y:\DOL Calibration\Data\felix\analysis\15-30-60auto-3h-overnight.mat');

if isempty(who)
movielistpath = 'Y:\DOL Calibration\Data\klaus\u-track\movieList_all.mat';

while exist(movielistpath, 'file') ~= 2
    userinput = inputdlg('file not found. correct path:',...
        'Movielist path not found', [1 100], {movielistpath});
    if not(isempty(userinput))
        movielistpath = userinput{:};
    else
        errordlg('Aborted or empty movie list path');
        return
    end
end

% Registration routine
RegistrationRoutine(movielistpath);

Intensity_path = {...
    'y:\DOL Calibration\Data\klaus\Intensities\Intensities_15min.txt'
    'y:\DOL Calibration\Data\klaus\Intensities\Intensities_30min.txt'
    'y:\DOL Calibration\Data\klaus\Intensities\Intensities_60min.txt'
    'y:\DOL Calibration\Data\klaus\Intensities\Intensities_3h.txt'
    'y:\DOL Calibration\Data\klaus\Intensities\Intensities_overnight.txt'
};

for i=1:length(Intensity_path)
    while exist(Intensity_path{i}, 'file') ~= 2
        userinput = inputdlg('file not found. correct path:',...
            'Intensities path not found', [1 100], {Intensity_path{i}});
        if not(isempty(userinput))
            Intensity_path{i} = userinput{:};
        else
            errordlg('Aborted or empty Intensities path');
            return
        end
    end
end
    
% Segmentation areas and background intensities
% with identical indexing to cells
[AllAreas, BackgroundBlue, BackgroundGreen, BackgroundRed] = ...
    Intensities2mat(Intensity_path, CellType, incubation_time, concentration, replicate);

% Single emitter Intensities
[SingleEmitter_Blue, SingleEmitter_Green, SingleEmitter_Red] = deal([]);

clear('userinput');
variables = who;
uisave(variables, 'y:\DOL Calibration\Data\klaus\analysis\klaus_base.mat');

end

return


%% Global Parameters

Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];
colors = {'Red', 'Green', 'Blue'};
proteins = {'HaloTag', 'SNAP-tag', 'GFP'};        % Order according to colors

for l=1:2
for t=1:5
for c=1:8
sampleName{l,t,c} = [Cells{l} ' ' num2str(inctime(t)) 'h ' num2str(concrange(c)) 'nM'];
end
end
end

for i=1:length(CellType)
conditions{i} = [CellType{i} ' ' num2str(incubation_time(i)) 'h ' num2str(concentration(i)) 'nM'];
conditions{i} = strrep(conditions{i},'16h','overnight');
end

clr_c = parula(8);
clr_t = lines(5);

%% Colocalisation Threshold

%Select all replicates where the registration worked in both channels
Selection = (strcmp(FlagRed,'Registration successfull') |...
    strcmp(FlagRed,'successfull registration')) &...
    (strcmp(FlagGreen,'Registration successfull') |...
    strcmp(FlagGreen,'successfull registration'));

SelectionMatrix = Selection;
for i=1:39
    SelectionMatrix=[SelectionMatrix Selection];
end

ColGreen = ColocalizationBlueGreen(SelectionMatrix);
ColGreen = reshape(ColGreen,[length(ColGreen)/40,40]);
ColGreenRandom = ColocalizationGreenRandom(SelectionMatrix);
ColGreenRandom = reshape(ColGreenRandom,[length(ColGreenRandom)/40,40]);
ColRed = ColocalizationBlueRed(SelectionMatrix);
ColRed = reshape(ColRed,[length(ColRed)/40,40]);
ColRedRandom = ColocalizationRedRandom(SelectionMatrix);
ColRedRandom = reshape(ColRedRandom,[length(ColRedRandom)/40,40]);

% Find Tolerance Threshold as mean value
meanGreen = mean(ColGreen,1);
meanGreenRandom = mean(ColGreenRandom,1);
meanRed = mean(ColRed,1);
meanRedRandom = mean(ColRedRandom,1);

fig_colocThreshold = figure('Name', 'Colocalisation Threshold');
hold on
plot(0.1:0.1:4,meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom),'linewidth',3,'Color', [0 0.5 0])
plot(0.1:0.1:4,meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom),'linewidth',3,'Color', [0.8 0 0])
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;
ax.XAxis.Label.String = 'spatial tolerance [px]';
ax.YAxis.Label.String = {'normalized number of' 'specific colocalisations Z'};
ylim([0 0.4])

hold off

[~,indexGreen] = max(meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom));
ToleranceGreen = round(indexGreen)/10;
FinalThresholdGreen = ToleranceGreen;

[~,indexRed] = max(meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom));
ToleranceRed = round(indexRed)/10;
FinalThresholdRed = ToleranceRed; %1.4;

%% Create 5x8 DOL-Result and number of particle-matrices
%%Create matrix of mean values of labeling efficiencies(x-Axis: concentration 0 to 250nM, y-Axis:
%%incubation time 0.25 to 16 h, 5x8 matrix

pGreen = pGreen(:,round(FinalThresholdGreen*10));
pBlue = pBlue(:,round(FinalThresholdGreen*10));
pGreenRandom = pGreenRandom(:,round(FinalThresholdGreen*10));
pRed = pRed(:,round(FinalThresholdRed*10));
pRedRandom = pRedRandom(:,round(FinalThresholdRed*10));

%% Calculate Particle Densities
% Pixel size in µm
pixelSize = 0.104;

Density_Blue = BlueParticles./(AllAreas*(pixelSize^2));
Density_Green = GreenParticles./(AllAreas*(pixelSize^2));
Density_Red = RedParticles./(AllAreas*(pixelSize^2));

%%Correct DOL for particle density
pGreen = pGreen./(-0.17*Density_Green+1);
pRed = pRed./(-0.17*Density_Red+1);
pBlue = pBlue./(-0.17*Density_Blue+1);

%Normalize Background to single emitter intensity
if exist(SingleEmitter_Blue)
    BackgroundBlue = BackgroundBlue./mean(SingleEmitter_Blue);
    BackgroundGreen = BackgroundGreen./mean(SingleEmitter_Green);
    BackgroundRed = BackgroundRed./mean(SingleEmitter_Red);
end

%% Parse Data for each condition

[MeanDOLGreen,...
StdDOLGreen,...
MeanDOLRed,...
StdDOLRed,...
MeanDOLBlue,...
StdDOLBlue,...
MeanDOLGreenRandom,...
MeanDOLRedRandom,...
MeanParticlesGreen,...
StdParticlesGreen,...
MeanParticlesRed,...
StdParticlesRed,...
MeanParticlesBlue,...
StdParticlesBlue,...
BackgroundGreen_all,...
StdBackgroundGreen_all,...
BackgroundBlue_all,...
StdBackgroundBlue_all,...
BackgroundRed_all,...
StdBackgroundRed_all]...
    = deal(zeros(2,5,8));

% BackgroundGreenall (and others) are obsolete with all backgrounds in
% BackgroundBlue

sigDOL_Halo_SNAP=zeros(5,8);

for l=1:2
    for c=1:8
        for t=1:5
            [~,sigDOL_Halo_SNAP(t,c)]=ranksum(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')),pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));


            %DOL
            MeanDOLGreen(l,t,c) = mean(pGreen...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdDOLGreen(l,t,c) = std(pGreen...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            MeanDOLRed(l,t,c) = mean(pRed...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdDOLRed(l,t,c) = std(pRed...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            MeanDOLBlue(l,t,c) = mean(pBlue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdDOLBlue(l,t,c) = std(pBlue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            MeanDOLGreenRandom(l,t,c) = mean(pGreenRandom...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp(CellType,Cells{l})) );
            MeanDOLRedRandom(l,t,c) = mean(pRedRandom...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp(CellType,Cells{l})) );

            %particle densities
            MeanParticlesGreen(l,t,c) = mean(Density_Green...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdParticlesGreen(l,t,c) = std(Density_Green...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            MeanParticlesRed(l,t,c) = mean(Density_Red...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdParticlesRed(l,t,c) = std(Density_Red...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            MeanParticlesBlue(l,t,c) = mean(Density_Blue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdParticlesBlue(l,t,c) = std(Density_Blue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            
            %Background
            BackgroundGreen_all(l,t,c) = mean(BackgroundGreen...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdBackgroundGreen_all(l,t,c) = std(BackgroundGreen...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            BackgroundRed_all(l,t,c) = mean(BackgroundRed...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdBackgroundRed_all(l,t,c) = std(BackgroundRed...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

            BackgroundBlue_all(l,t,c) = mean(BackgroundBlue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );
            StdBackgroundBlue_all(l,t,c) = std(BackgroundBlue...
                (concentration == concrange(c) & incubation_time == inctime(t) & strcmp (CellType,Cells{l})) );

        end

    end

end

%% PLOT DOL surface plots
datastem = 'MeanDOL';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', 'DOL Surface Plot');

n = 1;

for l=1:length(Cells)
    
    for p=1:2
        
        ax = subplot(2,2,n);
        dataVar = [datastem colors{p}];
        dataRange = ['(' num2str(l) ',:,:)'];
        dataName = [dataVar dataRange];
        data = squeeze(eval(dataName));
        
        surf(xlinear,ylinear,data, 'FaceColor', 'interp');
        
        xlabel('concentration [nM]')
        ylabel('incubation time [h]')
        zlabel('degree of labeling')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
        zlim([0 0.6])
        ylim([0.25 16])
        text(0.02,0.25,'//')
        caxis([0 0.4])
        view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
    end

end

%% PLOT GFP density box plot

experiments = strcat(strtrim(cellstr(num2str(incubation_time))), 'h_', CellType);
labels = unique(experiments);
figure();
boxplot(Density_Blue,experiments, 'PlotStyle', 'compact', 'GroupOrder', labels);


labels = sort(unique(conditions));
figure();
boxplot(Density_Blue,conditions, 'PlotStyle', 'compact', 'GroupOrder', labels);

%% Area vs. GFP density

figure('Name', 'Area vs. GFP Density');
for l=1:length(Cells)
    ax = subplot(1,2,l);
    for t=1:5
        index = (strcmp(CellType,Cells{l}) & incubation_time == inctime(t));
        xdata = Density_Blue(index);
        ydata = AllAreas(index);
        scatter(xdata,ydata,50,clr_t(t,:),'MarkerFaceColor','flat','MarkerFaceAlpha', 0.7, 'MarkerEdgeColor', 'none');
        hold on
    end
    title(Cells{l});
    legend(strcat(strtrim(cellstr(num2str(inctime'))), 'h'));
%     ax = gca;
    ax.XAxis.Label.String = 'GFP density [points / µm^2]';
    ax.XLim = [0 2];
    ax.YAxis.Label.String = 'Cell Area [px]';
    ax.YLim = [0 512^2];
end

%% Registration Nearest Neighbor

datastemX = 'SignalStrength';
datastemY = 'peakWidth';

for p=1:2
    figure('Name', ['Nearest Neighbor Distribution ', colors{p}, ' to Blue']);
%     title(['Nearest Neighbor Distribution' colors{p} ' to Blue']);
    n = 1;
    for t=1:5
        ax = subplot(2,3,n);
        % NN distance along x-axis
        for c=1:8
            index = (strcmp(CellType,'gSEP') & incubation_time == inctime(t) &...
                concentration == concrange(c));
            xdataname = [datastemX 'XBlue' colors{p} '(index)'];
            xdata = eval(xdataname);
            ydataname = [datastemY 'XBlue' colors{p} '(index)'];
            ydata = eval(ydataname);
            scatter(xdata,ydata,40,clr_c(c,:),'o','filled','MarkerFaceAlpha', 0.7);
            hold on
        end
        % NN distance along y-axis
        for c=1:8
            index = (strcmp(CellType,'gSEP') & incubation_time == inctime(t) &...
                concentration == concrange(c));
            xdataname = [datastemX 'YBlue' colors{p} '(index)'];
            xdata = eval(xdataname);
            ydataname = [datastemY 'YBlue' colors{p} '(index)'];
            ydata = eval(ydataname);
            scatter(xdata,ydata,40,clr_c(c,:),'^','filled','MarkerFaceAlpha', 0.7);
        end
%         ax = gca;
        ax.XAxis.Label.String = 'Signal Strength';
        ax.XLim = [1 2];
        ax.YAxis.Label.String = 'NN Peak Width [px]';
        ax.YLim = [0 6];
        plot([1.4 1.4],ax.YLim,'Color','r');
        legend(strcat(strtrim(cellstr(num2str(concrange'))), ' nM'));
        title([num2str(inctime(t)) 'h']);
        
        n = n+1;
    end
end

%% Registration Translation

figure('Name', 'Registration Translation')
for p=1:2
    ax = subplot(1,2,p);
    for t=1:5
        index = strcmp(eval(['Flag' colors{p}]), 'Registration successfull') & ...
            incubation_time == inctime(t);
        xdata = TranslationXBlueRed(index);
        ydata = TranslationYBlueRed(index);
        scatter(xdata, ydata,40,clr_t(t,:), '*');
        hold on
    end
    legend(strcat(strtrim(cellstr(num2str(inctime'))), 'h'));
    title({'Registration Translation' [colors{p} ' to Blue']});
    ax = gca;
    ax.XLim = [-4,4];
    ax.XAxis.Label.String = 'Translation along X-Axis [px]';
    ax.YLim = [-4,4];
    ax.YAxis.Label.String = 'Translation along Y-Axis [px]';
    plot([0 0], ax.YLim, 'Color', 'k', 'LineStyle', ':');
    plot(ax.XLim, [0 0], 'Color', 'k', 'LineStyle', ':');
end

%% Point Detection Gauss Fit

for p=1:3
    for l=1:2
        figure('Name', ['Point Detection Gauss Fit ', Cells{l}, ', ', colors{p}]);
        n=1;
        for t=1:5
            ax = subplot(2,3,n);
            for c=1:8
                index = strcmp(CellType,Cells{l}) & incubation_time == inctime(t) &...
                    concentration == concrange(c);
                xdatavar = ['Points_' colors{p} '_s'];
                xdatarange = '{index}';
                xdataname = ['[' xdatavar xdatarange ']'];
                xdata = eval(xdataname);
                ydatavar = ['Points_' colors{p} '_A'];
                ydatarange = '{index}';
                ydataname = ['[' ydatavar ydatarange ']'];
                ydata = eval(ydataname);
                scatter(xdata, ydata, 20,clr_c(c,:), '*')
                hold on
            end
            legend(strcat(strtrim(cellstr(num2str(concrange'))), ' nM'));
            title([num2str(inctime(t)) 'h']);
            ax = gca;
            ax.XLim = [0.8 3.2];
            ax.XAxis.Label.String = 'PSF Sigma [px]';
            ax.YLim = [0 20000];
            ax.YAxis.Label.String = 'Amplitude [a.u.]';
            
            n=n+1;
        end
    end
end