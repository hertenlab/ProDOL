function CellDataPlots

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


end