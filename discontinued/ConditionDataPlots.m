% function ConditionDataPlots(ConditionDataPath)

load(ConditionDataPath)

exp_system = matname;

saveData = 1;
Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];
clr_c = 0.9*hsv(8);
clr_t = lines(5);

[pathstr, name, ~] = fileparts(ConditionDataPath);
if saveData
    mkdir(pathstr,name);
    savefolder = fullfile(pathstr,name);
end

%% Colocalization threshold

[~,indexGreen] = max(meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom));
[~,indexRed] = max(meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom));

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
        dataname = [datastem colors{p} '(l,:,:)'];
        errname = [errstem colors{p} '(l,:,:)'];
        data = squeeze(eval(dataname));
        err = squeeze(eval(errname));

        formatSpec = cell(5,8);
        formatSpec(:) = {'%.2f'};
        datastr = cellfun(@num2str, num2cell(data), formatSpec, 'UniformOutput', false);
        errstr = cellfun(@num2str, num2cell(err), formatSpec, 'UniformOutput', false);

        strtable = strcat(datastr,{' ± '}, errstr);

        columnhead = [cstr; strtable];
        sample = [Cells{l} ' ' proteins{p}];
        rowhead = [sample tstr];
        full = [rowhead' columnhead];
        all = [all; full];
            
    end
    
end

if saveData
    savenamestem = 'dol-table';
    savename = [exp_system '_' savenamestem '.txt'];
    savepath = fullfile(savefolder, savename);
    
    fileID = fopen(savepath,'w');
    formatSpec = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';
    [nrows,ncols] = size(all);
    for row = 1:nrows
        fprintf(fileID,formatSpec,all{row,:});
    end
    fclose(fileID);
end
    
%% DOL surface plots

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
        zlim([0 0.6])
        ylim([0.25 16])
        xlim([0 500])
        text(0.02,0.25,'//')
        caxis([0 0.4])
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

%% Rolling Ball Background

datastem = 'Background';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['Background Surface Plot - ' exp_system], 'Position', [200 200 1024 720]);

n = 1;

for l=1:length(Cells)
    
    for p=1:2
        
        ax = subplot(2,2,n);
        dataVar = [datastem colors{p} '_all'];
        dataRange = ['(' num2str(l) ',:,:)'];
        dataName = [dataVar dataRange];
        data = squeeze(eval(dataName));
        
        surf(xlinear,ylinear,data, 'FaceColor', 'interp');
        
        xlabel('concentration [nM]')
        ylabel('incubation time [h]')
        zlabel('Background Intensity')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
%         zlim([0 0.6])
        ylim([0.25 16])
        xlim([0 500])
        text(0.02,0.25,'//')
%         caxis([0 0.4])
        view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
        
        
    end

end

% if saveData
%     savenamestem = 'dol-surf';
%     savename = [exp_system '_' savenamestem '.fig'];
%     saveas(gcf, fullfile(savefolder, savename), 'fig');
% end

%% DOL random surface plots
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

%% DOL with errors

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
        ax.YLim = [0 0.6];
        set(gca,'xscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        
        legend({'gSEP' 'LynG'});
        title([num2str(inctime(t)) 'h']);
        
        n = n+1;
    end
    
    if saveData
        savenamestem = 'dol-errorbars-c';
        savename = [exp_system '_' savenamestem '_' proteins{p} '.fig'];
        saveas(gcf, fullfile(savefolder, savename), 'fig');
    end
    
end

%% DOL with errors, x = time

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

%% Mean Point Density surface plot
datastem = 'MeanParticles';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['Particle Density Surface Plot - ' exp_system], 'Position', [200 200 1200 720]);

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
        zlim([0 1.2])
        ylim([0.25 16])
        xlim([0 250])
        text(0.02,0.25,'//')
        caxis([0 1.2])
%         view(ax,[-19.5 34]);
        view(ax,[0 90]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
        
        
    end

end

colorbar
if saveData
    savenamestem = 'density-surf';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%% Total Points surface plot
datastem = 'totalParticles';

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure('Name', ['Total Number of Points Surface Plot - ' exp_system], 'Position', [200 200 1200 720]);

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
        zlabel('number of particles')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
        zlim([0 20000])
        ylim([0.25 16])
        xlim([0 500])
        text(0.02,0.25,'//')
        caxis([0 20000])
        view(ax,[0 90]);
%         view(ax,[-19.5 34]);
        
        title({[datastem ' ' Cells{l}] [colors{p} ' (' proteins{p} ')']});
        n = n+1;
        
        
    end

end
colorbar
if saveData
    savenamestem = 'totalpoints-surf';
    savename = [exp_system '_' savenamestem '.fig'];
    saveas(gcf, fullfile(savefolder, savename), 'fig');
end

%%
if saveData
    close all
end
% end