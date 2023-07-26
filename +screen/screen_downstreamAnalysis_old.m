% function downstreamAnalysis(data_filepath, validpath, colors, proteins, saveData)
% 
% if nargin
%     registration_filepath = data_filepath;
% else
    registration_filepath = 'Y:\DOL Calibration\Data\sigi\analysis\filterScreen\sigi_rg-85-0nM_b-A800.mat';
    [~, matname, ~] = fileparts(registration_filepath);
    load(registration_filepath);
    data_filepath = registration_filepath;
    saveData = 0;
    colors = {'Red', 'Green', 'Blue'};
    proteins = {'SNAP-tag', 'HaloTag', 'GFP'};        % Order according to colors
    pixelSize = 0.104;         % in µm
    validpath = 'y:\DOL Calibration\Data\sigi\analysis\sigi_base_cherryPicking.mat';
% end

load(validpath);
valid = cherryPick.valid;
% valid = true(length(replicate),1);    %% uncomment to ignore cherryPick

exp_system = matname; %'sigi_rg-75-0nM_b-A800.mat';
registration_filepath = data_filepath;
[pathstr,name,~] = fileparts(registration_filepath);
if saveData
    mkdir(pathstr,name);
    savefolder = fullfile(pathstr,name);
end

%% Global Parameters

Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];

sampleName = cell(2,5,8);
for l=1:2
for t=1:5
for c=1:8
sampleName{l,t,c} = [Cells{l} ' ' num2str(inctime(t)) 'h ' num2str(concrange(c)) 'nM'];
sampleConc{l,c,t} = concrange(c);
sampleTime{l,c,t} = inctime(t);
sampleCellType{l,c,t} = Cells{l};
end
end
end

conditions = cell(length(CellType),1);
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
    
pxSize = pixelSize * ones(length(CellType),1);

if strfind(exp_system, 'felix')
    pixelSize_2 = 0.104;
    index = incubation_time == 0.25 | incubation_time == 0.5;
    pxSize(index) = pixelSize_2;
end


pRaw_Blue = pBlue;
pRaw_Green = pGreen;
pRaw_Red = pRed;

Density_Blue = BlueParticles./(AllAreas.*(pxSize.^2));
Density_Green = GreenParticles./(AllAreas.*(pxSize.^2));
Density_Red = RedParticles./(AllAreas.*(pxSize.^2));

%%Correct DOL for particle density
% pGreen = pGreen./(-0.17*Density_Green+1);
% pRed = pRed./(-0.17*Density_Red+1);
% pBlue = pBlue./(-0.17*Density_Blue+1);

% New density correction from simulated data with real background
pGreen = pGreen./(-0.365*Density_Green+0.8808);
pRed = pRed./(-0.2836*Density_Red+0.7025);
% no simulations for blue background possible (no wildtype data)

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
StdBackgroundRed_all,...
numCells]...
    = deal(zeros(2,5,8));

% BackgroundGreenall (and others) are obsolete with all backgrounds in
% BackgroundBlue

sigDOL_Halo_SNAP=zeros(5,8);

for l=1:2
    for c=1:8
        for t=1:5
            [~,sigDOL_Halo_SNAP(t,c)]=ranksum(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')),pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
            condition_index = valid & ...
                isfinite(pGreen) &...
                concentration == concrange(c) & ...
                incubation_time == inctime(t) & ...
                strcmp (CellType,Cells{l});
            %DOL
            MeanDOLGreen(l,t,c) = mean(pGreen(condition_index));
            StdDOLGreen(l,t,c) = std(pGreen(condition_index));

            MeanDOLRed(l,t,c) = mean(pRed(condition_index));
            StdDOLRed(l,t,c) = std(pRed(condition_index));

            MeanDOLBlue(l,t,c) = mean(pBlue(condition_index));
            StdDOLBlue(l,t,c) = std(pBlue(condition_index));

            MeanDOLGreenRandom(l,t,c) = mean(pGreenRandom(condition_index));
            MeanDOLRedRandom(l,t,c) = mean(pRedRandom(condition_index));

            %particle densities
            MeanParticlesGreen(l,t,c) = mean(Density_Green(condition_index));
            StdParticlesGreen(l,t,c) = std(Density_Green(condition_index));

            MeanParticlesRed(l,t,c) = mean(Density_Red(condition_index));
            StdParticlesRed(l,t,c) = std(Density_Red(condition_index));

            MeanParticlesBlue(l,t,c) = mean(Density_Blue(condition_index));
            StdParticlesBlue(l,t,c) = std(Density_Blue(condition_index));
            
            %Background
            BackgroundGreen_all(l,t,c) = mean(BackgroundGreen(condition_index));
            StdBackgroundGreen_all(l,t,c) = std(BackgroundGreen(condition_index));

            BackgroundRed_all(l,t,c) = mean(BackgroundRed(condition_index));
            StdBackgroundRed_all(l,t,c) = std(BackgroundRed(condition_index));

            BackgroundBlue_all(l,t,c) = mean(BackgroundBlue(condition_index));
            StdBackgroundBlue_all(l,t,c) = std(BackgroundBlue(condition_index));

            
            %numCells
            numCells(l,t,c) = sum(condition_index);
            
            % Number of Particles
            numPoints{l,t,c}.r = length([Points_Red_A{condition_index}]);
            numPoints{l,t,c}.g = length([Points_Green_A{condition_index}]);
            numPoints{l,t,c}.b = length([Points_Blue_A{condition_index}]);
            totalParticlesBlue(l,t,c) = sum(BlueParticles(condition_index));
            totalParticlesGreen(l,t,c) = sum(GreenParticles(condition_index));
            totalParticlesRed(l,t,c) = sum(RedParticles(condition_index));
                        
        end

    end

end

%% break before plots

beep;
return

%% Results table
variables = {...
    'sampleTime'
    'sampleConc'
    'sampleCellType'
    'MeanDOLGreen'
    'StdDOLGreen'
    'MeanDOLRed'
    'StdDOLRed'
    'MeanDOLBlue'
    'StdDOLBlue'
    'MeanDOLGreenRandom'
    'MeanDOLRedRandom'
    'MeanParticlesGreen'
    'StdParticlesGreen'
    'MeanParticlesRed'
    'StdParticlesRed'
    'MeanParticlesBlue'
    'StdParticlesBlue'
    'BackgroundGreen_all'
    'StdBackgroundGreen_all'
    'BackgroundBlue_all'
    'StdBackgroundBlue_all'
    'BackgroundRed_all'
    'StdBackgroundRed_all'
    'numCells'
    'totalParticlesBlue'
    'totalParticlesGreen'
    'totalParticlesRed'};
mytable = table(...
    sampleTime(:),...
    sampleConc(:),...
    sampleCellType(:),...
    MeanDOLGreen(:),...
    StdDOLGreen(:),...
    MeanDOLRed(:),...
    StdDOLRed(:),...
    MeanDOLBlue(:),...
    StdDOLBlue(:),...
    MeanDOLGreenRandom(:),...
    MeanDOLRedRandom(:),...
    MeanParticlesGreen(:),...
    StdParticlesGreen(:),...
    MeanParticlesRed(:),...
    StdParticlesRed(:),...
    MeanParticlesBlue(:),...
    StdParticlesBlue(:),...
    BackgroundGreen_all(:),...
    StdBackgroundGreen_all(:),...
    BackgroundBlue_all(:),...
    StdBackgroundBlue_all(:),...
    BackgroundRed_all(:),...
    StdBackgroundRed_all(:),...
    numCells(:),...
    totalParticlesBlue(:),...
    totalParticlesGreen(:),...
    totalParticlesRed(:),...
    'RowNames', sampleName(:),...
    'VariableNames', variables);

%% Plot colocalization threshold

figure('Name', ['Colocalisation Threshold - ' exp_system]);
hold on
green = plot(0.1:0.1:4,meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom),'linewidth',3,'Color', [0 0.5 0]);
red = plot(0.1:0.1:4,meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom),'linewidth',3,'Color', [0.8 0 0]);
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;
ax.XAxis.Label.String = 'spatial tolerance [px]';
ax.YAxis.Label.String = {'normalized number of' 'specific colocalisations Z'};
ylim([0 0.4])


scatter(green.XData(indexGreen), green.YData(indexGreen),100,[0 0.5 0]);
line([green.XData(indexGreen) green.XData(indexGreen)], [0 green.YData(indexGreen)],...
    'LineStyle', '--', 'Color', [0 0.5 0]);
text(green.XData(indexGreen), 0.05*ax.YLim(2),num2str(green.XData(indexGreen)),...
    'Color',[0 0.5 0],'BackgroundColor', 'white','HorizontalAlignment', 'center',...
    'FontSize',10);
scatter(red.XData(indexRed), red.YData(indexRed),100,[0.8 0 0]);
line([red.XData(indexRed) red.XData(indexRed)], [0 red.YData(indexRed)],...
    'LineStyle', '--', 'Color', [0.8 0 0]);
text(red.XData(indexRed), 0.10*ax.YLim(2),num2str(red.XData(indexRed)),...
    'Color',[0.8 0 0],'BackgroundColor', 'white','HorizontalAlignment', 'center',...
    'FontSize',10);

if saveData
    savenamestem = 'coloc-threshold';
    savename = [exp_system '_' savenamestem];
    saveas(gcf, fullfile(savefolder, [savename, '.fig']), 'fig');
end

%% Table DOL with errors

datastem = 'MeanDOL';
errstem = 'StdDOL';

cstr = {'0 nM', '0.1 nM', '1 nM', '5 nM', '10 nM', '50 nM', '100 nM', '250 nM'};
tstr = {'0.25 h', '0.5 h', '1 h', '3 h', '16 h'};

all = [];

for l=1:2
    for p=1:2
        dataname = [datastem colors{p} '(l,:,:)']
        errname = [errstem colors{p} '(l,:,:)'];
        data = squeeze(eval(dataname));
        err = squeeze(eval(errname));

        formatSpec = cell(5,8);
        formatSpec(:) = {'%.2f'};
        datastr = cellfun(@num2str, num2cell(data), formatSpec, 'UniformOutput', false);
        errstr = cellfun(@num2str, num2cell(err), formatSpec, 'UniformOutput', false);

        strtable = strcat(datastr,{' ± '}, errstr);

        columnhead = [cstr; strtable];
        sample = [Cells{l} ' ' proteins{p}]
        rowhead = [sample tstr];
        full = [rowhead' columnhead];
        all = [all; full];
            
    end
    
end

if 1 %saveData
%     savenamestem = 'dol-table';
%     savename = [exp_system '_' savenamestem '.txt'];
%     savepath = fullfile(savefolder, savename);

    savepath = 'e:\DataSync\Doktorarbeit\00_Science\Calibration\DataAnalysis\PointFiltering\felix_rg-75-0nM_b-A500_dol-table.txt'
    
    fileID = fopen(savepath,'w');
    formatSpec = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';
    [nrows,ncols] = size(all);
    for row = 1:nrows
        fprintf(fileID,formatSpec,all{row,:});
    end
    fclose(fileID);
end
    
%% PLOT DOL surface plots

datastem = 'MeanDOL';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['DOL Surface Plot - ' exp_system], 'Position', [200 200 1024 720]);

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
        zlim([0 1])
        ylim([0.25 16])
        xlim([0 500])
        text(0.02,0.25,'//')
        caxis([0 0.8])
        view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
        
        
    end

end

if saveData
    savenamestem = 'dol-surf';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%% PLOT DOL random surface plots
datastem = 'MeanDOL';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['DOL Random Surface Plot - ' exp_system], 'Position', [200 200 1024 720]);

n = 1;

for l=1:length(Cells)
    
    for p=1:2
        
        ax = subplot(2,2,n);
        dataVar = [datastem colors{p} 'Random'];
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
        xlim([0 500])
        text(0.02,0.25,'//')
        caxis([0 0.4])
        view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} 'Random (' proteins{p} ')']});
        n = n+1;
        
        
    end

end

if saveData
    savenamestem = 'dol-random-surf';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%% Plot Shaenselman Coefficient surface plot
% 
% 
% xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
% ylinear=[0.25 0.5 1 3 16]; %incubation time
% 
% DOLstem = 'MeanDOL';
% DensityStem = 'Density_';
% 
% figure('Name', 'Shaenselman Green')
% % DOL in gSEP cells
% DOL_Green = squeeze(MeanDOLGreen(1,:,:)); %  - squeeze(MeanDOLGreen(2,:,:)); % DOL gSEP - DOL LynG
% % calculate DOL relative maximum
% DOL_Green = DOL_Green ./ max(max(DOL_Green));
% % Point density in LynG cells
% Density_Green_abs = squeeze(MeanParticlesGreen(2,:,:));
% % calculate density relative to unstained cells
% Density_Green = Density_Green_abs ./ Density_Green_abs(:,1);
% % Background intensity in gSEP cells
% Background_Green_abs = squeeze(BackgroundGreen_all(1,:,:));
% % Calculated background relative to unstained cells
% Background_Green = Background_Green_abs ./ Background_Green_abs(:,1);
% 
% shaenselman_Green = DOL_Green./(Density_Green .* Background_Green);
% 
% data_Green = {'DOL_Green' 'Density_Green' 'Background_Green' 'shaenselman_Green'};
%     
% for n = 1:4
%     ax_Green = subplot(2,2,n);
%     surf(xlinear,ylinear,eval(data_Green{n}), 'FaceColor', 'interp');
% 
%     xlabel('concentration [nM]')
%     ylabel('incubation time [h]')
%     zlabel(data_Green{n})
%     
%     set(gca,'xscale','log')
%     set(gca,'yscale','log')
%     ax = gca;
%     ax.XTick=xlinear;%[1:8];
%     ax.YTick=ylinear;%[1:5];
%     ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
%     ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
% %     zlim([0 0.6])
%     ylim([0.25 16])
%     xlim([0 500])
%     text(0.02,0.25,'//')
% %     caxis([0 0.4])
%     view(ax,[-19.5 34]);
%     
% end
% 
% if saveData
%     savenamestem = 'shaenselman-green';
%     savename = [exp_system '_' savenamestem '.fig'];
%     saveas(gcf, fullfile(savefolder, savename), 'fig');
% end
% 
% figure('Name', 'Shaenselman Red')
% % DOL in gSEP cells
% DOL_Red = squeeze(MeanDOLRed(1,:,:)); %  - squeeze(MeanDOLRed(2,:,:)); % DOL gSEP - DOL LynG
% % calculate DOL relative to maximum
% DOL_Red = DOL_Red ./ max(max(DOL_Red));
% % Point density in LynG cells
% Density_Red_abs = squeeze(MeanParticlesRed(2,:,:));
% % calculate density relative to unstained cells
% Density_Red = Density_Red_abs ./ Density_Red_abs(:,1);
% % Background intensity in gSEP cells
% Background_Red_abs = squeeze(BackgroundRed_all(1,:,:));
% % subtract backgroung in unstained cells
% Background_Red = Background_Red_abs ./ Background_Red_abs(:,1);
% 
% shaenselman_Red = DOL_Red./(Density_Red .* Background_Red);
% 
% data_Red = {'DOL_Red' 'Density_Red' 'Background_Red' 'shaenselman_Red'};
%     
% for n = 1:4
%     ax_Red = subplot(2,2,n);
%     surf(xlinear,ylinear,eval(data_Red{n}), 'FaceColor', 'interp');
% 
%     xlabel('concentration [nM]')
%     ylabel('incubation time [h]')
%     zlabel(data_Red{n})
%     
%     set(gca,'xscale','log')
%     set(gca,'yscale','log')
%     ax = gca;
%     ax.XTick=xlinear;%[1:8];
%     ax.YTick=ylinear;%[1:5];
%     ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
%     ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
% %     zlim([0 0.6])
%     ylim([0.25 16])
%     xlim([0 500])
%     text(0.02,0.25,'//')
% %     caxis([0 0.4])
%     view(ax,[-19.5 34]);
%     
% end
% 
% if saveData
%     savenamestem = 'shaenselman-red';
%     savename = [exp_system '_' savenamestem '.fig'];
%     saveas(gcf, fullfile(savefolder, savename), 'fig');
% end

%% Plot DOL with errors

datastem = 'MeanDOL';
errstem = 'StdDOL';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

for p=1:2
    figure('Name', ['DOL ', proteins{p}, ' (', colors{p}, ') - ' exp_system], 'Position', [200 200 1024 720]);
    n = 1;
    for t=1:5
        ax = subplot(2,3,n);
        % NN distance along x-axis
        vert = {'top' 'bottom'};
        for l=1:2
            index = (strcmp(CellType,Cells{l}) & incubation_time == inctime(t) &...
                concentration == concrange(c));
            dataname = [datastem colors{p} '(l,t,:)'];
            errname = [errstem colors{p} '(l,t,:)'];
            data = squeeze(eval(dataname));
            err = squeeze(eval(errname));
            errorbar(xlinear,data,err,'Color',clr_t(l,:),'LineStyle', 'none', 'Marker', '+');
%             str = strcat(num2str(round(data,2)),' ± ', num2str(round(err,2)));
%             text(xlinear,data,str,'Color',clr_t(l,:), 'Rotation', 45, ...
%                 'VerticalAlignment', vert{l},'HorizontalAlignment', 'left',...
%                 'FontSize', 8);
            hold on
        end
        xlabel('concentration [nM]')
        ax.XLim = [0.005 500];
        ylabel('DOL')
        ax.YLim = [0 1];
        set(gca,'xscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        
        legend({'gSEP' 'LynG'}, 'Location', 'northwest');
        title([num2str(inctime(t)) 'h']);
        
        n = n+1;
    end
    
    if saveData
        savenamestem = 'dol-errorbars-c';
        savename = [exp_system '_' savenamestem '_' proteins{p} '.fig'];
        saveas(gcf, fullfile(savefolder, savename), 'fig');
    end
    
end

%% Plot DOL with errors, x = time

datastem = 'MeanDOL';
errstem = 'StdDOL';

xlinear=[0.25 0.5 1 3 16]; %incubation time

for p=1:2
    figure('Name', ['DOL ', proteins{p}, ' (', colors{p}, ') - ' exp_system], 'Position', [200 200 1024 720]);
    n = 1;
    for c=1:8
        ax = subplot(2,4,n);
        line_style = {'-' ':'};
        for l=1:2
            index = (strcmp(CellType,Cells{l}) & incubation_time == inctime(t) &...
                concentration == concrange(c));
            dataname = [datastem colors{p} '(l,:,c)'];
            errname = [errstem colors{p} '(l,:,c)'];
            data = squeeze(eval(dataname));
            err = squeeze(eval(errname));
            errorbar(xlinear,data,err,'Color',clr_c(c,:),'LineStyle', line_style{l}, 'Marker', '+');
            hold on
        end
        xlabel('incubation time [h]')
        ax.XLim = [0.2 20];
        ylabel('DOL')
        ax.YLim = [0 0.6];
        set(gca,'xscale','log')
        ax.XTick = xlinear;%[1:8];
        ax.XTickLabel = {'0.25', '0.5', '1', '3', '16'};
        
        legend({'gSEP' 'LynG'});
        title([num2str(concrange(c)) 'nM']);
        
        n = n+1;
    end
    
    if saveData
        savenamestem = 'dol-errorbars-t';
        savename = [exp_system '_' savenamestem '_' proteins{p} '.fig'];
        saveas(gcf, fullfile(savefolder, savename), 'fig');
    end
    
end

%% Plot Mean Point Density surface plot
datastem = 'totalParticles';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['Particle Density Surface Plot - ' exp_system], 'Position', [200 200 1024 720]);

n = 1;

for l=1:length(Cells)
    
    for p=1:3
        
        ax = subplot(2,3,n);
        dataVar = [datastem colors{p}];
        dataRange = ['(' num2str(l) ',:,:)'];
        dataName = [dataVar dataRange];
        data = squeeze(eval(dataName));
        
        surf(xlinear,ylinear,data, 'FaceColor', 'interp');
        
        xlabel('concentration [nM]')
        ylabel('incubation time [h]')
        zlabel('particle density [µm^-^1]')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
%         zlim([0 1.2])
        ylim([0.25 16])
        xlim([0 500])
        text(0.02,0.25,'//')
%         caxis([0 1.2])
        view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
        
        
    end

end

if saveData
    savenamestem = 'density-surf';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

return

%% PLOT GFP density box plot
% 
% experiments = strcat(strtrim(cellstr(num2str(incubation_time))), 'h_', CellType);
% labels = unique(experiments);
% figure('Name', ['GFP Density - ' exp_system], 'Position', [200 200 1024 720]);
% boxplot(Density_Blue,experiments, 'GroupOrder', labels, 'Whisker', 1.5, 'Notch', 'on');
% ax = gca;
% ax.XAxis.TickLabelRotation = 90;
% ylim([0 2.5])
% ylabel('GFP density [points / µm]')
% 
% if saveData
%     savenamestem = 'gfp-density';
%     savename = [exp_system '_' savenamestem '.fig'];
%     saveas(gcf, fullfile(savefolder, savename), 'fig');
% end
% 
% 
% % labels = sort(unique(conditions));
% % figure('Name', 'GFP Density', 'Position', [200 200 1024 360]);
% % boxplot(Density_Blue,conditions, 'PlotStyle', 'compact', 'GroupOrder', labels);
% % ylabel('GFP density [points / µm]')

%% Area vs. GFP density

figure('Name', ['Area vs. GFP Density - ' exp_system], 'Position', [200 200 1024 720]);
for l=1:length(Cells)
    ax = subplot(1,2,l);
    for t=1:5
        index = (strcmp(CellType,Cells{l}) & incubation_time == inctime(t));
        xdata = Density_Blue(index);
        ydata = AllAreas(index);
        scatter(xdata,ydata,30,clr_t(t,:),'*');
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

if saveData
    savenamestem = 'area-density';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

return

%% Registration Success

figure('Name', ['Registration Success - ' exp_system], 'Position', [200 200 1024 720]);
n = 1;

for l=1:length(Cells)
    for p=1:2
    ax = subplot(2,2,n);
    
    flag = eval(['Flag' colors{p}]);
    ratio = zeros(8,5);
    for t = 1:5
    for c = 1:8
        index = strcmp(CellType, Cells{l}) & incubation_time == inctime(t) & concentration == concrange(c);
        num = sum(index);
        success = sum(strcmp(flag(index), 'Registration successfull'));
        ratio(c,t) = success / num;
    end
    end
    
    cat = categorical(inctime);
    b = bar(cat,ratio');
    for c=1:8
        b(c).FaceColor = clr_c(c,:);
    end
    ax.XTickLabel = {'0.25h', '0.5h', '1h', '3h', '16h'};
    ylim([0 1])
    title({[colors{p} ' to Blue (' proteins{p} ')'] Cells{l}});
    
    n = n+1;
    end
end

if saveData
    savenamestem = 'registration-success';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%% Registration Nearest Neighbor

datastemX = 'SignalStrength';
datastemY = 'peakWidth';

for p=1:2
    figure('Name', ['Nearest Neighbor Distribution ', colors{p}, ' to Blue - ' exp_system],...
        'Position', [200 200 1024 720]);
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
    
    if saveData
        savenamestem = 'nearest-neighbor';
        savename = [exp_system '_' savenamestem '_' colors{p} '.fig'];
        saveas(gcf, fullfile(savefolder, savename), 'fig');
    end
end

%% Registration Translation

figure('Name', ['Registration Translation - ' exp_system], 'Position', [200 200 1024 720])
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

if saveData
    savenamestem = 'registration-translation';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%% Point Detection Gauss Fit

return

for p=1:3
    for l=1:2
        figure('Name', ['Point Detection Gauss Fit ' Cells{l} ', ' colors{p} ' - ' exp_system],...
             'Position', [200 200 1024 720]);
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
                scatter(xdata, ydata, 10,clr_c(c,:), '.','MarkerFaceAlpha',0.5)
                hold on
            end
            legend(strcat(strtrim(cellstr(num2str(concrange'))), ' nM'));
            title([num2str(inctime(t)) 'h']);
            ax = gca;
            ax.XLim = [0 10];
            ax.XAxis.Label.String = 'PSF Sigma [px]';
            ax.YLim = [0 20000];
            ax.YAxis.Label.String = 'Amplitude [a.u.]';
            
            n=n+1;
        end
        
        if save
            savenamestem = 'gauss-fit';
            savename = [exp_system '_' savenamestem '_' Cells{l} '_' colors{p}];
            saveas(gcf, fullfile(savefolder, savename), 'fig');
        end

    end
end

% end