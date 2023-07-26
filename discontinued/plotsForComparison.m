root = 'y:\DOL Calibration\Data\sigi\analysis\filterScreen';

filelist = dir(root);
data = cell(4,4);
paths = cell(4,4);
percent = [75 85 90 95];
blueA = [500; 600; 700; 800];
j=1;
for i=1:length(filelist)
    if ~filelist(i).isdir && ~contains(filelist(i).name, 'mean') &&...
            endsWith(filelist(i).name, 'ConditionData.mat')
        fprintf('%s\n',fullfile(filelist(i).folder, filelist(i).name))
        paths{j} = fullfile(filelist(i).folder, filelist(i).name);
        data{j} = load(fullfile(filelist(i).folder, filelist(i).name));
        j=j+1;
%         ConditionPath = extractConditionData(fullfile(filelist(i).folder, filelist(i).name))
%         ConditionDataPlots(ConditionPath)
    end
end

%% function dolSurf()
% 
datastem = 'data{x,y}.MeanDOLRed(2,:,:)';
xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time
figure('Name', 'DOL Surface Plot', 'Position', [200 200 1024 720]);

n = 1;
for x=1:length(percent)
    
    for y=1:length(blueA)
        
        ax = subplot(4,4,n);
        plotdata = squeeze(eval(datastem));
        
        surf(xlinear,ylinear,plotdata, 'FaceColor', 'interp');
%         xlabel('concentration [nM]')
%         ylabel('incubation time [h]')
%         zlabel('degree of labeling')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
        zlim([0 0.4])
        ylim([0.25 16])
        xlim([0 250])
        text(0.02,0.25,'//')
        caxis([0 0.4])
        view(ax,[-19.5 34]);
        
        n = n+1;
        
        title([num2str(percent(y)) ' % - blue A ' num2str(blueA(x))]);
        
    end

end
% end

%% stddolSurf()
% 
datastem = 'data{x,y}.StdDOLRed(1,:,:)';
xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time
figure('Name', 'DOL Surface Plot', 'Position', [200 200 1024 720]);

n = 1;
for x=1:length(percent)
    
    for y=1:length(blueA)
        
        ax = subplot(4,4,n);
        plotdata = squeeze(eval(datastem));
        
        surf(xlinear,ylinear,plotdata, 'FaceColor', 'interp');
        plotdata(3,3)
%         xlabel('concentration [nM]')
%         ylabel('incubation time [h]')
%         zlabel('degree of labeling')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
        zlim([0 0.1])
        ylim([0.25 16])
        xlim([0 250])
        text(0.02,0.25,'//')
        caxis([0 0.1])
        view(ax,[0 0]);
        
        n = n+1;
        
        title([num2str(percent(y)) ' % - blue A ' num2str(blueA(x))]);
        
    end

end
% end

%% densitySurf

datastem = 'data{x,y}.MeanParticlesBlue(1,:,:)';
xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time
figure('Name', 'Point Density Blue', 'Position', [200 200 1024 720]);

n = 1;
for x=1:length(blueA)
    
    for y=1:length(percent)
        
        ax = subplot(4,4,n);
        plotdata = squeeze(eval(datastem));
        
        surf(xlinear,ylinear,plotdata, 'FaceColor', 'interp');
        plotdata(3,3)
%         xlabel('concentration [nM]')
%         ylabel('incubation time [h]')
%         zlabel('degree of labeling')
%         ax = gca;
        % 
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        ax.XTick=xlinear;%[1:8];
        ax.YTick=ylinear;%[1:5];
        ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
        ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
        zlim([0 0.8])
        ylim([0.25 16])
        xlim([0 250])
        text(0.02,0.25,'//')
        caxis([0 0.8])
        view(ax,[-19.5 34]);
        
        title([num2str(percent(y)) ' % - blue A ' num2str(blueA(x))]);
        n = n+1;
        
        
    end

end
% end