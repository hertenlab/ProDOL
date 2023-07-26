clear all
load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\a\Registration_all_a.mat')
load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllAreas.mat')
load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\analysis\AllIntensities.mat')


%load('D:\ANALYSE DOL\Analyzed Data\WorkspaceAfterRegistrationRoutineForCells20170202_ToleranceScreen_CellParameters_used.mat');
%load('D:\ANALYSE DOL\Analyzed Data\20170216_improvedParticleDetection_ToleranceScreen.mat');
% load('D:\ANALYSE DOL\Analyzed Data\20170222_improvedParticleDetection_ToleranceScreen_pBlue_updatedMeanValues.mat');


% load('D:\ANALYSE DOL\AllAreas.mat');
% load('D:\ANALYSE DOL\AllIntensities.mat');

%%Detect optimal threshold
Selection=strcmp(CellType,'gSEP'); %Select all replicates hwre the registration worked in both channels
SelectionMatrix=Selection;
for i=1:39
    SelectionMatrix=[SelectionMatrix Selection];
end
ColGreen=ColocalizationBlueGreen(SelectionMatrix);
ColGreen = reshape(ColGreen,[length(ColGreen)/40,40]);
ColGreenRandom=ColocalizationGreenRandom(SelectionMatrix);
ColGreenRandom = reshape(ColGreenRandom,[length(ColGreenRandom)/40,40]);
ColRed=ColocalizationBlueRed(SelectionMatrix);
ColRed = reshape(ColRed,[length(ColRed)/40,40]);
ColRedRandom=ColocalizationRedRandom(SelectionMatrix);
ColRedRandom = reshape(ColRedRandom,[length(ColRedRandom)/40,40]);


%% Find Tolerance Threshold as mean value
meanGreen=mean(ColGreen,1);
meanGreenRandom=mean(ColGreenRandom,1);
meanRed=mean(ColRed,1);
meanRedRandom=mean(ColRedRandom,1);

figure()
hold on
plot(0.1:0.1:4,meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom),'linewidth',3,'Color', [0 0.5 0])
plot(0.1:0.1:4,meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom),'linewidth',3,'Color', [0.8 0 0])
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;
ylim([0 0.4])

hold off
[~,indexGreen]=max(meanGreen/max(meanGreen)-meanGreenRandom/max(meanGreenRandom));
ToleranceGreen=round(indexGreen)/10;
FinalThresholdGreen=ToleranceGreen

[~,indexRed]=max(meanRed/max(meanRed)-meanRedRandom/max(meanRedRandom));
ToleranceRed=round(indexRed)/10;
FinalThresholdRed=ToleranceRed %1.4;

i;


%% Find Tolerance Threshold for each replicate 
% for replicate=[1:301 303:size(ColGreen,1)]
%     ColDiffGreen=ColGreen(replicate,:)/max(ColGreen(replicate,:))-ColGreenRandom(replicate,:)/max(ColGreenRandom(replicate,:));
%     ColDiffRed=ColRed(replicate,:)/max(ColRed(replicate,:))-ColRedRandom(replicate,:)/max(ColRedRandom(replicate,:));
%     
%     windowSize = 5; %Averages over a distance of 0.9 pixel
%     b = (1/windowSize)*ones(1,windowSize);
%     a=1;
%     yG = filter(b,a,ColDiffGreen);
%     yR = filter(b,a,ColDiffRed);
% 
%     Scale=0.1:0.1:4;
% %     figure();
% %     plot(Scale(1:length(yG)-2),yG(3:length(yG)))
% %     title('Nearest Neighour Distance average filter in X')
% %     
% %     figure();
% %     plot(Scale(1:length(yR)-2),yR(3:length(yR)))
% %     title('Nearest Neighour Distance after sliding average filter in Y')
% 
%     ToleranceGreen(replicate)=mean(Scale(find(yG==max(yG))-2));
%     ToleranceRed(replicate)=mean(Scale(find(yR==max(yR))-2));
%     %The sliding avergage calculates the average value from 5 data points on the
%     %left side (avrg(5)=mean(y(1:5)). This introduces a shift to the right. Going 2 positions to the
%     %left corrects for that. 
%   
% %     figure();
% %     plot(0.1:0.1:4,ColDiffGreen)
% %     figure();
% %     plot(0.1:0.1:4,ColDiffRed)
%     
%     
%     
% end
% 
% 
% [countx,centerx]=histcounts(ToleranceGreen,[0.1:0.1:4]);
% figure()
% plot(centerx(1:length(countx)),countx)
% 
% [countx,centerx]=histcounts(ToleranceRed,[0.1:0.1:4]);
% figure()
% plot(centerx(1:length(countx)),countx)
% 
% ToleranceGreen=ToleranceGreen(ToleranceGreen<=2);
% SortedGreen=sort(ToleranceGreen);
% SortedGreen=SortedGreen(find(~isnan(SortedGreen)));
% FinalThresholdGreen=SortedGreen(round(0.9*length(SortedGreen)));
% 
% ToleranceRed=ToleranceRed(ToleranceRed<=2);
% SortedRed=sort(ToleranceRed);
% SortedRed=SortedRed(find(~isnan(SortedRed)));
% FinalThresholdRed=SortedRed(round(0.9*length(SortedRed)));


%% Calculate Particle Densities
Density_Blue=BlueParticles./(AllAreas*(0.104^2));
Density_Green=GreenParticles./(AllAreas*(0.104^2));
Density_Red=RedParticles./(AllAreas*(0.104^2));


%Normalize Background to single emitter intensity
% BackgroundBlue=BackgroundBlue./mean(SingleEmitter_Blue);
% BackgroundGreen=BackgroundGreen./mean(SingleEmitter_Green);
% BackgroundRed=BackgroundRed./mean(SingleEmitter_Red);


%% Control Registration

% %Compare number of GFP molecules between LynG and gSEP cells

% 
% 
% figure()
% hold on
% GFPLynG=Density_Blue(strcmp(CellType, 'LynG'));
% GFPgSEP=Density_Blue(strcmp(CellType, 'gSEP'));
% grp = cell(length(GFPLynG)+length(GFPgSEP),1);
% for i=1:length(GFPLynG)
% grp{i}='LynG';
% end
% for i=length(GFPLynG)+1:length(grp)
% grp{i}='gSEP';
% end
% boxplot([GFPLynG' GFPgSEP'],grp);
% title('number of GFP spots per cell')
% 
% ax = gca;
% ax.Box = 'on';
% ax.LineWidth = 3;
% 
% lineWidth = 3; lineCover=3*lineWidth;
% a = [findall(gcf,'Marker','none') findall(gcf,'Marker','.')];
% set(a,'LineWidth',lineWidth,'Marker','.','MarkerSize',lineCover);
% hold off
% 
% h=kstest(GFPgSEP)
% h=kstest(GFPLynG)
% h=kstest2(GFPLynG,GFPgSEP)
% [p,h] = ranksum(GFPLynG,GFPgSEP)
% 
% mean(GFPgSEP)
% std(GFPgSEP)
% mean(GFPLynG)
% std(GFPLynG)
% 
% GFPgSEP_sorted=sort(GFPgSEP);
% GFPLynG_sorted=sort(GFPLynG);
% 
% GFPgSEP_sorted(round(0.05*421))
% GFPgSEP_sorted(round(0.95*421))
% GFPLynG_sorted(round(0.05*406))
% GFPLynG_sorted(round(0.95*406))


%% Create 5x8 DOL-Result and number of particle-matrices
%%Create matrix of mean values of labeling efficiencies(x-Axis: concentration 0 to 250nM, y-Axis:
%%incubation time 0.25 to 16 h, 5x8 matrix

pGreen=pGreen(:,round(FinalThresholdGreen*10));
pBlue=pBlue(:,round(FinalThresholdGreen*10));
pGreenRandom=pGreenRandom(:,round(FinalThresholdGreen*10));
pRed=pRed(:,round(FinalThresholdRed*10));
pRedRandom=pRedRandom(:,round(FinalThresholdRed*10));



%%Correct DOL for particle density
% pGreen=pGreen./(-0.17*Density_Green+1);
% pRed=pRed./(-0.17*Density_Red+1);
% pBlue=pBlue./(-0.17*Density_Blue+1);





Cells={'gSEP' 'LynG'};
inctime=[0.25 0.5 1 3 16];
concrange=[0 0.1 1 5 10 50 100 250];


%% This is to produce FIG_RegistrationSuccess
tt=3;
conc=250;
Green=FlagGreen(concentration== conc & incubation_time==tt & strcmp (CellType,'gSEP'));
Red=FlagRed(concentration== conc & incubation_time==tt & strcmp (CellType,'gSEP'));
length(Green);
length(Red);


meanGreenX=mean(TranslationsXBlueGreen(strcmp (FlagGreen,'successfull registration')))
meanGreenY=mean(TranslationsYBlueGreen(strcmp (FlagGreen,'successfull registration')))

meanRedX=mean(TranslationsXBlueRed(strcmp (FlagRed,'successfull registration')))
meanRedY=mean(TranslationsYBlueRed(strcmp (FlagRed,'successfull registration')))



%% Parse Data for each condition

MeanDOLGreengSEP=zeros(5,8);
StdDOLGreengSEP=zeros(5,8);
MeanDOLRedgSEP=zeros(5,8);
StdDOLRedgSEP=zeros(5,8);

MeanDOLGreengSEPRandom=zeros(5,8);
MeanDOLRedgSEPRandom=zeros(5,8);

MeanDOLGreenLynG=zeros(5,8);
StdDOLGreenLynG=zeros(5,8);
MeanDOLRedLynG=zeros(5,8);
StdDOLRedLynG=zeros(5,8);
MeanDOLBluegSEP=zeros(5,8);
StdDOLBluegSEP=zeros(5,8);
MeanDOLBlueLynG=zeros(5,8);
StdDOLBlueLynG=zeros(5,8);

MeanParticlesGreengSEP=zeros(5,8);
StdParticlesGreengSEP=zeros(5,8);
MeanParticlesRedgSEP=zeros(5,8);
StdParticlesRedgSEP=zeros(5,8);
MeanParticlesBluegSEP=zeros(5,8);
StdParticlesBluegSEP=zeros(5,8);

MeanParticlesGreenLynG=zeros(5,8);
StdParticlesGreenLynG=zeros(5,8);
MeanParticlesRedLynG=zeros(5,8);
StdParticlesRedLynG=zeros(5,8);
MeanParticlesBlueLynG=zeros(5,8);
StdParticlesBlueLynG=zeros(5,8);

BackgroundGreen_LynG=zeros(5,8);
BackgroundGreen_gSEP=zeros(5,8);
BackgroundBlue_LynG=zeros(5,8);
BackgroundBlue_gSEP=zeros(5,8);
BackgroundRed_LynG=zeros(5,8);
BackgroundRed_gSEP=zeros(5,8);

StdBackgroundGreen_LynG=zeros(5,8);
StdBackgroundGreen_gSEP=zeros(5,8);
StdBackgroundBlue_LynG=zeros(5,8);
StdBackgroundBlue_gSEP=zeros(5,8);
StdBackgroundRed_LynG=zeros(5,8);
StdBackgroundRed_gSEP=zeros(5,8);


BackgroundBlue_all=zeros(5,8);
BackgroundGreen_all=zeros(5,8);
BackgroundRed_all=zeros(5,8);

sigDOL_Halo_SNAP=zeros(5,8);

for c=1:8
    for t=1:5
        
        
        [~,sigDOL_Halo_SNAP(t,c)]=ranksum(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')),pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        
        
        %DOL
        MeanTemp=mean(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanDOLGreengSEP(t,c)=MeanTemp;
        StdDOLGreengSEP(t,c)=StdTemp;
        
        MeanTemp=mean(pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanDOLRedgSEP(t,c)=MeanTemp;
        StdDOLRedgSEP(t,c)=StdTemp;
        
        MeanTemp=mean(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(pGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanDOLGreenLynG(t,c)=MeanTemp;
        StdDOLGreenLynG(t,c)=StdTemp;
        
        MeanTemp=mean(pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(pRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanDOLRedLynG(t,c)=MeanTemp;
        StdDOLRedLynG(t,c)=StdTemp;
        
        MeanTemp=mean(pBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(pBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanDOLBluegSEP(t,c)=MeanTemp;
        StdDOLBluegSEP(t,c)=StdTemp;
        
        MeanTemp=mean(pBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(pBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanDOLBlueLynG(t,c)=MeanTemp;
        StdDOLBlueLynG(t,c)=StdTemp;
        
        
        MeanTemp=mean(pGreenRandom(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        %StdTemp=std(pGreenRandom(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanDOLGreengSEPRandom(t,c)=MeanTemp;
        %StdDOLGreengSEP(t,c)=StdTemp;
        
        MeanTemp=mean(pRedRandom(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        %StdTemp=std(pRedRandom(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanDOLRedgSEPRandom(t,c)=MeanTemp;
        %StdDOLRedgSEP(t,c)=StdTemp;
        
        
        %particle densities
        
        MeanTemp=mean(Density_Green(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(Density_Green(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanParticlesGreengSEP(t,c)=MeanTemp;
        StdParticlesGreengSEP(t,c)=StdTemp;
        
        MeanTemp=mean(Density_Red(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(Density_Red(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanParticlesRedgSEP(t,c)=MeanTemp;
        StdParticlesRedgSEP(t,c)=StdTemp;
        
        MeanTemp=mean(Density_Blue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        StdTemp=std(Density_Blue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        MeanParticlesBluegSEP(t,c)=MeanTemp;
        StdParticlesBluegSEP(t,c)=StdTemp;
        
        MeanTemp=mean(Density_Green(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(Density_Green(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanParticlesGreenLynG(t,c)=MeanTemp;
        StdParticlesGreenLynG(t,c)=StdTemp;
        
        MeanTemp=mean(Density_Red(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(Density_Red(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanParticlesRedLynG(t,c)=MeanTemp;
        StdParticlesRedLynG(t,c)=StdTemp;
        
        MeanTemp=mean(Density_Blue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdTemp=std(Density_Blue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        MeanParticlesBlueLynG(t,c)=MeanTemp;
        StdParticlesBlueLynG(t,c)=StdTemp;
        
        %Background
        MeanTemp=mean(BackgroundGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        BackgroundGreen_LynG(t,c)=MeanTemp;
        StdTemp=std(BackgroundGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdBackgroundGreen_LynG(t,c)=StdTemp;
        
        
        MeanTemp=mean(BackgroundRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        BackgroundRed_LynG(t,c)=MeanTemp;
        StdTemp=std(BackgroundRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdBackgroundRed_LynG(t,c)=StdTemp;
        
        MeanTemp=mean(BackgroundBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        BackgroundBlue_LynG(t,c)=MeanTemp;
        StdTemp=std(BackgroundBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'LynG')));
        StdBackgroundBlue_LynG(t,c)=StdTemp;
        
        
        MeanTemp=mean(BackgroundGreen(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        BackgroundGreen_gSEP(t,c)=MeanTemp;
        
        MeanTemp=mean(BackgroundRed(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        BackgroundRed_gSEP(t,c)=MeanTemp;
        
        MeanTemp=mean(BackgroundBlue(concentration== concrange(c) & incubation_time==inctime(t) & strcmp (CellType,'gSEP')));
        BackgroundBlue_gSEP(t,c)=MeanTemp;
        
        
        MeanTemp=mean(BackgroundGreen(concentration== concrange(c) & incubation_time==inctime(t)));
        BackgroundGreen_all(t,c)=MeanTemp;
        
        MeanTemp=mean(BackgroundRed(concentration== concrange(c) & incubation_time==inctime(t)));
        BackgroundRed_all(t,c)=MeanTemp;
        
        MeanTemp=mean(BackgroundBlue(concentration== concrange(c) & incubation_time==inctime(t)));
        BackgroundBlue_all(t,c)=MeanTemp;
           
    end
      
end


%% Plot particle DENSITIES

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure
%  surf(xlinear,ylinear,MeanParticlesBluegSEP)
% surf(xlinear,ylinear,MeanParticlesGreengSEP)
% surf(xlinear,ylinear,MeanParticlesRedgSEP)
% 
% surf(xlinear,ylinear,MeanParticlesBlueLynG)
surf(xlinear,ylinear,MeanParticlesGreenLynG)
%  surf(xlinear,ylinear,MeanParticlesRedLynG)
% 
% Background corrected numbers
% surf(xlinear,ylinear,MeanParticlesGreengSEP-MeanParticlesGreenLynG)
% surf(xlinear,ylinear,MeanParticlesRedgSEP-(MeanParticlesRedLynG-min(min(MeanParticlesRedLynG))))
xlabel('Concentration [nM]')
ylabel('incubation time [h]')
ax = gca;
% 
set(gca,'xscale','log')
set(gca,'yscale','log')
ax.XTick=xlinear;%[1:8];
ax.YTick=ylinear;%[1:5];
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
ylim([0.25 16])
zlim([0 2])
view(ax,[-19.5 34]);
text(0.02,0.25,'//')
caxis([0 1.3])




 %% Plot Background

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

figure

% surf(xlinear,ylinear,BackgroundBlue_all)
% surf(xlinear,ylinear,BackgroundGreen_all)
% surf(xlinear,ylinear,BackgroundRed_all)

% surf(xlinear,ylinear,BackgroundBlue_gSEP)
% surf(xlinear,ylinear,BackgroundGreen_gSEP)
% surf(xlinear,ylinear,BackgroundRed_gSEP)
% 
% surf(xlinear,ylinear,BackgroundBlue_LynG)
% surf(xlinear,ylinear,BackgroundGreen_LynG)
 surf(xlinear,ylinear,BackgroundRed_LynG)



xlabel('Concentration [nM]')
ylabel('incubation time [h]')
ax = gca;
% 
set(gca,'xscale','log')
set(gca,'yscale','log')
ax.XTick=xlinear;%[1:8];
ax.YTick=ylinear;%[1:5];
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
ylim([0.25 16])
zlim([0 3])
view(ax,[-19.5 34]);
text(0.02,0.25,'//')
caxis([0.2 1])


 %% PLOT DOL
figure

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

%surf(xlinear,ylinear,MeanDOLGreengSEP)
surf(xlinear,ylinear,MeanDOLRedgSEP)
%  surf(xlinear,ylinear,MeanDOLBluegSEP)
% surf(xlinear,ylinear,MeanDOLGreenLynG)
% surf(xlinear,ylinear,MeanDOLRedLynG)
% surf(xlinear,ylinear,StdDOLRedgSEP)

% surf(xlinear,ylinear,MeanDOLGreenLynG)


xlabel('concentration [nM]')
ylabel('incubation time [h]')
zlabel('degree of labeling')
ax = gca;
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

title('DOL of Halo-tag')




figure

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

 surf(xlinear,ylinear,MeanDOLGreengSEP)
% surf(xlinear,ylinear,MeanDOLGreenLynG)
% surf(xlinear,ylinear,MeanDOLRedgSEP)
% surf(xlinear,ylinear,StdDOLRedgSEP)

% surf(xlinear,ylinear,MeanDOLGreenLynG)
% surf(xlinear,ylinear,MeanDOLRedLynG)

xlabel('concentration [nM]')
ylabel('incubation time [h]')
zlabel('degree of labeling')
ax = gca;
% 
set(gca,'xscale','log')
set(gca,'yscale','log')
ax.XTick=xlinear;%[1:8];
ax.YTick=ylinear;%[1:5];
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
zlim([0 0.5])
ylim([0.25 16])
text(0.02,0.25,'//')

caxis([0 0.35])
view(ax,[-19.5 34]);

title('DOL of SNAP-tag')



%% Plot DOL of random control
 
figure

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

% surf(xlinear,ylinear,MeanDOLGreengSEPRandom)
surf(xlinear,ylinear,MeanDOLRedgSEPRandom)

xlabel('concentration [nM]')
ylabel('incubation time [h]')
zlabel('degree of labeling')
ax = gca;
% 
set(gca,'xscale','log')
set(gca,'yscale','log')
ax.XTick=xlinear;%[1:8];
ax.YTick=ylinear;%[1:5];
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
zlim([0 0.5])
ylim([0.25 16])
text(0.02,0.25,'//')

caxis([0 0.35])
view(ax,[-19.5 34]);

%title('Random DOL between GFP and TMR')
title('Random DOL between GFP and SiR')


%% Plot line plot for any series
incubationtime1=1; %1=15min,2=30min,3=1h,4=3h,5=16h
incubationtime2=2;
incubationtime3=3;
incubationtime4=4;
incubationtime5=5;
xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!

% SNAP-Tag
data1=MeanDOLRedgSEP(incubationtime1,:);
error1=StdDOLRedgSEP(incubationtime1,:);
data2=MeanDOLRedgSEP(incubationtime2,:);
error2=StdDOLRedgSEP(incubationtime2,:);
data3=MeanDOLRedgSEP(incubationtime3,:);
error3=StdDOLRedgSEP(incubationtime3,:);
data4=MeanDOLRedgSEP(incubationtime4,:);
error4=StdDOLRedgSEP(incubationtime4,:);
data5=MeanDOLRedgSEP(incubationtime5,:);
error5=StdDOLRedgSEP(incubationtime5,:);

data1=MeanParticlesRedLynG(incubationtime1,:);
error1=StdParticlesRedLynG(incubationtime1,:);
data2=MeanParticlesRedLynG(incubationtime2,:);
error2=StdParticlesRedLynG(incubationtime2,:);
data3=MeanParticlesRedLynG(incubationtime3,:);
error3=StdParticlesRedLynG(incubationtime3,:);
data4=MeanParticlesRedLynG(incubationtime4,:);
error4=StdParticlesRedLynG(incubationtime4,:);
data5=MeanParticlesRedLynG(incubationtime5,:);
error5=StdParticlesRedLynG(incubationtime5,:);


% HaloTag
data1=MeanDOLGreengSEP(incubationtime1,:);
error1=StdDOLGreengSEP(incubationtime1,:);
data2=MeanDOLGreengSEP(incubationtime2,:);
error2=StdDOLGreengSEP(incubationtime2,:);
data3=MeanDOLGreengSEP(incubationtime3,:);
error3=StdDOLGreengSEP(incubationtime3,:);
data4=MeanDOLGreengSEP(incubationtime4,:);
error4=StdDOLGreengSEP(incubationtime4,:);
data5=MeanDOLGreengSEP(incubationtime5,:);
error5=StdDOLGreengSEP(incubationtime5,:);

data1=MeanDOLBluegSEP(incubationtime1,:);
error1=StdDOLBluegSEP(incubationtime1,:);
data2=MeanDOLBluegSEP(incubationtime2,:);
error2=StdDOLBluegSEP(incubationtime2,:);
data3=MeanDOLBluegSEP(incubationtime3,:);
error3=StdDOLBluegSEP(incubationtime3,:);
data4=MeanDOLBluegSEP(incubationtime4,:);
error4=StdDOLBluegSEP(incubationtime4,:);
data5=MeanDOLBluegSEP(incubationtime5,:);
error5=StdDOLBluegSEP(incubationtime5,:);

% data1=MeanParticlesGreenLynG(incubationtime1,:);
% error1=StdParticlesGreenLynG(incubationtime1,:);
% data2=MeanParticlesGreenLynG(incubationtime2,:);
% error2=StdParticlesGreenLynG(incubationtime2,:);
% data3=MeanParticlesGreenLynG(incubationtime3,:);
% error3=StdParticlesGreenLynG(incubationtime3,:);
% data4=MeanParticlesGreenLynG(incubationtime4,:);
% error4=StdParticlesGreenLynG(incubationtime4,:);
% data5=MeanParticlesGreenLynG(incubationtime5,:);
% error5=StdParticlesGreenLynG(incubationtime5,:);

figure()
hold on
errorbar(xlinear,data1,error1,'Linewidth',3,'Color',[0.4,0.4,1])%[1,0.4,0.4])
errorbar(xlinear,data2,error2,'Linewidth',3,'Color',[0.3,0.3,0.8])%[0.8,0.3,0.3])
errorbar(xlinear,data3,error3,'Linewidth',3,'Color',[0.2,0.2,0.6])%[0.6,0.2,0.2])
errorbar(xlinear,data4,error4,'Linewidth',3,'Color',[0.1,0.1,0.4])%[0.4,0.1,0.1])
errorbar(xlinear,data5,error5,'Linewidth',3,'Color',[0,0,0.2])%[0.2,0,0])
ax = gca;
set(gca,'xscale','log')
xlabel('concentration [nM]')
ylabel('density of unspecific particles')
ax.XTick=xlinear;
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ylim([0 2])
xlim([0.01 250])
text(0.015,0,'//')
legend('15min', '30min','1 h','3h', 'overnight')
ax.LineWidth = 3;






fig=figure()
hold on


[AX,H1,H2] = plotyy(xlinear,data1,xlinear,data2);

text(0.015,0,'//')
xlabel('concentration [nM]')

set(fig, 'CurrentAxes', AX(1));
hold on;
errorbar(xlinear,data1, error1);
ylabel('degree of labeling')
AX(1).YLim=[0 0.5];

set(fig, 'CurrentAxes', AX(2));
hold on;
errorbar(xlinear,data2, error2);
ylabel('density')
AX(2).YLim=[0 2];

set(AX,'xscale','log')
AX(1).XTick=xlinear;
AX(1).XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};

title('Halotag, incubation time 16 h')
hold off


% data=MeanParticlesGreenLynG(incubationtime,:);
% error=StdParticlesGreenLynG(incubationtime,:);


%% 2D surface Plot

figure

xlinear=[0.01 0.1 1 5 10 50 100 250]; %concentrations 0.01 is actiually 0!
ylinear=[0.25 0.5 1 3 16]; %incubation time

% contourf(xlinear,ylinear,MeanDOLGreengSEP)
contourf(xlinear,ylinear,MeanDOLRedgSEP)
% contourf(xlinear,ylinear,StdDOLRedgSEP)

% contourf(xlinear,ylinear,MeanDOLGreenLynG)
% contourf(xlinear,ylinear,MeanDOLRedLynG)

%  contourf(xlinear,ylinear,MeanParticlesGreenLynG,'LevelList',[0 200 400 600 800 1000 1200 1400])
% contourf(xlinear,ylinear,MeanParticlesRedgSEP)

xlabel('Concentration [nM]')
ylabel('incubation time [h]')
ax = gca;
set(gca,'xscale','log')
set(gca,'yscale','log')
ax.XTick=xlinear;%[1:8];
ax.YTick=ylinear;%[1:5];
ax.XTickLabel = {'0', '0.1', '1', '5', '10', '50', '100', '250'};
ax.YTickLabel = {'0.25', '0.5', '1', '3', '16'};
zlim([0 0.4])
text(0.02,0.25,'//')
%colormap(cool)
colorbar
caxis([0 1400])


%% DOL vs. Density


zz_pRedgSEP_stained=pRed(strcmp (CellType,'gSEP') & concentration~=0);
zz_DensitygSEP_Red_stained=Density_Red(strcmp (CellType,'gSEP') & concentration~=0);
zz_Background_red_stained=BackgroundRed(strcmp (CellType,'gSEP') & concentration~=0);

figure()
scatter(zz_DensitygSEP_Red_stained,zz_pRedgSEP_stained,'linewidth',3)
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;

figure()
scatter(zz_Background_red_stained,zz_pRedgSEP_stained,'linewidth',3)
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;

yyDOL=reshape(MeanDOLRedgSEP(:,3:8),[1,30]);
yyBackground=reshape(BackgroundRed_LynG(:,3:8),[1,30]);
yyBackground=reshape(MeanParticlesRedLynG(:,3:8),[1,30]);

scatter(yyBackground,yyDOL,'linewidth',3)
ax = gca;
ax.Box = 'off';
ax.LineWidth = 3;


%% Data for DOL table
aa=round(MeanDOLGreengSEP'*100);
aa=round(StdDOLGreengSEP'*100);
aa=round(MeanDOLRedgSEP'*100);
aa=round(StdDOLRedgSEP'*100);

%% Expression levels
% 
% %%Calculate expression levels
% Expression_Blue=Density_Blue./pBlue;
% Expression_Green=Density_Green./pGreen;
% Expression_Red=Density_Red./pRed;
% 
% 
% Selection_Expression=strcmp(CellType,'gSEP') & concentration>0.1 & concentration<100 & BackgroundRed<0.8;
% 
% figure()
% scatter(Density_Green(strcmp(CellType,'gSEP')&concentration>0),pBlue(strcmp(CellType,'gSEP')&concentration>0))
% 
% figure()
% hold on
% scatter(Expression_Green(Selection_Expression),Expression_Red(Selection_Expression),'linewidth',3)
% title('Green vs Red');
% xlim([0 16])
% ylim([0 16])
% 
% linFitX = fitlm(Expression_Green(Selection_Expression),Expression_Red(Selection_Expression),'linear') %This has all the info
% yfit=table2array(linFitX.Coefficients(2,1))*Expression_Green(Selection_Expression)+table2array(linFitX.Coefficients(1,1));
% %plot(Expression_Green(Selection_Expression),yfit,'red', 'linewidth', 2,'color',[0.5 0.5 0.5]);
% plot([1.5 15],[1.5 15], 'linewidth', 2,'color',[0.5 0.5 0.5])
% 
% ax = gca;
% ax.Box = 'off';
% ax.LineWidth = 3;
% hold off
% 
% [R_XCorr,P_XCorr] = corrcoef(Expression_Green(Selection_Expression),Expression_Red(Selection_Expression))
% [p h]=ranksum(Expression_Green(Selection_Expression),Expression_Red(Selection_Expression))
% 
% 
% figure()
% hold on
% Expr_Green=Expression_Green(Selection_Expression);
% Expr_Red=Expression_Red(Selection_Expression);
% grp = cell(length(Expr_Green)+length(Expr_Red),1);
% for i=1:length(Expr_Red)
% grp{i}='Estimated from SNAPf-tag';
% end
% for i=length(Expr_Red)+1:length(grp)
% grp{i}='Estimated from HaloTag';
% end
% boxplot([Expr_Red' Expr_Green'],grp);
% title('Concentration of gSEP constructs')
% 
% ax = gca;
% ax.Box = 'on';
% ax.LineWidth = 3;
% 
% lineWidth = 3; lineCover=3*lineWidth;
% a = [findall(gcf,'Marker','none') findall(gcf,'Marker','.')];
% set(a,'LineWidth',lineWidth,'Marker','.','MarkerSize',lineCover);
% hold off
% 
% % h=kstest(Expr_Red)
% % h=kstest(Expr_Green)
% % h=kstest2(Expr_Red,Expr_Green)
% [p,h] = ranksum(Expr_Red,Expr_Green)
% 
% mean(Expr_Red)
% std(Expr_Red)
% mean(Expr_Green)
% std(Expr_Green)
% 
% GFPgSEP_sorted=sort(Expr_Red);
% GFPLynG_sorted=sort(Expr_Green);
% 
% GFPgSEP_sorted(round(0.05*421))
% GFPgSEP_sorted(round(0.95*421))
% GFPLynG_sorted(round(0.05*406))
% GFPLynG_sorted(round(0.95*406))
% 
% 
% 
% 
% 
% 
% 
% 
% figure()
% Colorcode=[Expression_Red(Selection_Expression),Expression_Green(Selection_Expression),Expression_Blue(Selection_Expression)];
% for sample=1:size(Colorcode,1)
%     ref=mean(Colorcode(sample,2:3));
%     dist=Colorcode(sample,:)-ref;
%     Colorcode(sample,:)=abs(dist);
% end
% scatter3(Expression_Blue(Selection_Expression),Expression_Green(Selection_Expression),Expression_Red(Selection_Expression),30,Colorcode,'filled')
% xlim([0 16])
% ylim([0 16])
% zlim([0 16])
% 
% figure()
% scatter(Expression_Blue(Selection_Expression),Expression_Green(Selection_Expression),'filled')
% title('Blue vs Green');
% xlim([0 16])
% ylim([0 16])
% 
% figure()
% scatter(Expression_Blue(Selection_Expression),Expression_Red(Selection_Expression),'filled')
% title('Blue vs Red');
% xlim([0 20])
% ylim([0 20])
% 
% 
