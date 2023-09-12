%% Pipeline for analyzing DOL data from a single experimental condition, i.e. a given cell type, dye concentration, incubation time.
% The pipeline can deal with one or two dye channels. Dye channels still have to be named green or red.
% Input data
% - 3ChannelsMask directory: Averaged images for each cell in each spectral channel
% - multichannel images are constructed based on 'cellXX_' nomenclature:
% 'cell' is used as identifier, 'XX' is unique ID for each cell, '_' serves to indicate end of ID
% - thunderSTORM results file obtained from processing of images in
% 3ChannelsMask dir with ImageJ script 'processAverageIJwiththunderSTORM.ijm'

InterfaceProDOL = singlecondition.ProDOL_Interface;

if isvalid(InterfaceProDOL)
    waitfor(InterfaceProDOL)
end

%% Define experiment parameters 
% Define processing parameters
pixelsize = pixelsize/1000;
%pixelsize = 0.1056; % pixelsize in images (identical value to be used for thunderSTORM point detection!)
fittype = 'multi'; % thunderSTORM point detection parameters
threshold = '2.0'; % thunderSTORM point detection parameters

% Define paths
%dolP = 'E:\software\DOL'; % DOL software directory

%rootfolder = ("Z:\Stan\ST103_230302_DOL_NUP_CoPS_PBS\gSEP\");
files = dir(rootfolder);
dirFlags = [files.isdir];
Folders = files(dirFlags);
subFolders = Folders(3:end);

for m=1:length(subFolders)
    filesTemp=dir(append(subFolders(m).folder,'\',subFolders(m).name));
    % Get a logical vector that tells which is a directory.
    dirFlags2 = [filesTemp.isdir];
    % Extract only those that are directories.
    subFolders2 = filesTemp(dirFlags2); % A structure with extra info.
    % Get only the folder names into a cell array.
    subFolderNames2 = {subFolders2(3:end).name}; % Start at 3 to skip . and ..
    %expressionCh = '3Channels[_]?Mask';
    %expressionTS = 'TS_results';
    %expressionTS2= 'thunderSTORM';
    for n=1:length(subFolderNames2)
        matchStrCh = regexp(subFolderNames2(n),expressionCh,'match');
        matchStrTS = regexp(subFolderNames2(n),expressionTS,'match');
 
        if(strlength(matchStrCh{1,1})>1)
            imgDir = append(subFolders(m).folder,'\',subFolders(m).name,'\',string(matchStrCh)); % 
        elseif(strlength(matchStrTS{1,1})>1)
            tsDir = append(subFolders(m).folder,'\',subFolders(m).name,'\',string(matchStrTS));
        end
    end

    if ~exist('imgDir','var')
        disp(append("no imgDir folder found in : ",subFolders(m).folder,'\',subFolders(m).name));
        continue;
    elseif ~exist('tsDir','var')
        disp(append("no tsDir folder found in : ",subFolders(m).folder,'\',subFolders(m).name));
        continue;
    end

    saveDir = append(subFolders(m).folder,'\',subFolders(m).name,'\ProDOL_results\'); % output directory for results data and plots
    
    switch AnalysisOption
        case "Both Channels"
            channels = {'eGFP','Halo','SNAP','mask'};
            isProperties = struct('exp','Experiment','dye_Halo',dye_Halo,'dye_SNAP',dye_SNAP);
        case "HaloTag"
            channels = {'eGFP','Halo','mask'};
            isProperties = struct('exp','Experiment','dye_Halo',dye_Halo);
        case "SNAPtag"
            channels = {'eGFP','SNAP','mask'};
            isProperties = struct('exp','Experiment','dye_SNAP',dye_SNAP);
    end

    mkdir(saveDir);
    %%%%%%%%%%%%%%%%%%%%%
    % Pipeline
    %%%%%%%%%%%%%%%%%%%%%
    
    % add DOL repository to paths
    if isdeployed()==0
        addpath(genpath(dolP));
    end
    
    % Create imagesets
    imSet = [];
    imSet = singlecondition.createImageSet(imSet,imgDir,pixelsize,channels,isProperties);
    
    % Import thunderSTORM results
    [~] = singlecondition.importThunderSTORM(imSet,tsDir,struct('rep','','chan',''));
    
    % sigma filtering
    disp('Filtering points by sigma')
    setNames = {'ts_multi eGFP'; 'ts_multi Halo';'ts_multi SNAP'};
    sigmaFilterNames = strcat(setNames, ' fltr sigma');
    
    for i = 1:length(setNames)
        sigmaRange = modeFilter(imSet,setNames{i},'sigma',0.5,showIntermediate);
        imSet.filterPointsByValue(setNames{i}, sigmaFilterNames{i}, 'sigma', sigmaRange, 'append');
    end
    
    
    %% transform spectral channels
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"HaloTag")
        imSet.fullTransformation('ts_multi eGFP fltr sigma', 'ts_multi Halo fltr sigma');
    end
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"SNAPtag")
        imSet.fullTransformation('ts_multi eGFP fltr sigma', 'ts_multi SNAP fltr sigma');
    end

    %% calculate mean densities
    imSet.calculateAllMeanDensities();
    
    %% Colocalization analysis & Density correction
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"HaloTag")
        imSet.colocalisation('ts_multi eGFP fltr sigma' , 'ts_multi Halo fltr sigma', saveDir, showIntermediate)
        imSet.densityCorrection('ts_multi eGFP fltr sigma', 'ts_multi Halo fltr sigma', 0.8618, -0.2359) % used low background correction functions!
    end
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"SNAPtag")
        imSet.colocalisation('ts_multi eGFP fltr sigma' , 'ts_multi SNAP fltr sigma', saveDir, showIntermediate)
        imSet.densityCorrection('ts_multi eGFP fltr sigma', 'ts_multi SNAP fltr sigma', 0.8618, -0.2359) % used low background correction functions!
    end
    
    %% plots
    % scatter DOLs per cell
    allMCI = [imSet.childImages];
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"HaloTag")
        dols_Halo = [allMCI.resultByName('DOL corrected','ts_multi eGFP fltr sigma','ts_multi Halo fltr sigma')];
        writematrix(dols_Halo, strcat(saveDir,'DOL_Halo.txt'));
    end
    if strcmp(AnalysisOption,"Both Channels") | strcmp(AnalysisOption,"SNAPtag")
        dols_SNAP = [allMCI.resultByName('DOL corrected','ts_multi eGFP fltr sigma','ts_multi SNAP fltr sigma')];
        writematrix(dols_SNAP, strcat(saveDir,'DOL_SNAP.txt'));
    end

    f_dol=figure()
    hold on
    switch AnalysisOption
        case "Both Channels"
            errorbar(0.5,median(dols_Halo),std(dols_Halo),std(dols_Halo),'o','MarkerFaceColor','#30AC30','Color','#30AC30')
            scatter(repmat(0.5,numel(dols_Halo),1),dols_Halo,'Jitter','On','JitterAmount',0.1,'MarkerEdgeColor','#30AC30')
            errorbar(1,median(dols_SNAP),std(dols_SNAP),std(dols_SNAP),'o','MarkerFaceColor','red','Color','red')
            scatter(repmat(1,numel(dols_SNAP),1),dols_SNAP,'Jitter','On','JitterAmount',0.1,'MarkerEdgeColor','red')
            xlim([0 1.5])
        case "HaloTag"
            errorbar(0.5,median(dols_Halo),std(dols_Halo),std(dols_Halo),'o','MarkerFaceColor','#30AC30','Color','#30AC30')
            scatter(repmat(0.5,numel(dols_Halo),1),dols_Halo,'Jitter','On','JitterAmount',0.1,'MarkerEdgeColor','#30AC30')
            xlim([0 1])
            xticks([0 0.5])
        case "SNAPtag"
            errorbar(0.5,median(dols_SNAP),std(dols_SNAP),std(dols_SNAP),'o','MarkerFaceColor','red','Color','red')
            scatter(repmat(0.5,numel(dols_SNAP),1),dols_SNAP,'Jitter','On','JitterAmount',0.1,'MarkerEdgeColor','red')
            xlim([0 1])
            xticks([0 0.5])
    end
    ylim([0 1])
    ylabel('DOL corrected')
    title(subFolders(m).name,'Interpreter','none')

    switch AnalysisOption
        case "Both Channels"
            xticklabels({'',imSet.descriptors.dye_Halo,imSet.descriptors.dye_SNAP,''})
        case "HaloTag"
            xticklabels({'',imSet.descriptors.dye_Halo,''})
        case "SNAPtag"
            xticklabels({'',imSet.descriptors.dye_SNAP,''})
    end
    savefig(strcat(saveDir,'DOL.fig'));
    if showDOL==0
        close(f_dol);
    end


    % amplitude histogram before and after sigma filtering
    ps_nofilter = [allMCI.pointSetByName('ts_multi eGFP')];
    locs_nofilter = vertcat(ps_nofilter.points);
    ps_filtered = [allMCI.pointSetByName('ts_multi eGFP fltr sigma')];
    locs_filtered = vertcat(ps_filtered.points);
    f_histo=figure();
    histogram(log(locs_nofilter(:,7)),[3:0.1:15],'Normalization','probability')
    hold on
    histogram(log(locs_filtered(:,7)),[3:0.1:15],'Normalization','probability')
    legend({'unfiltered','sigma filter mu+-50%'})
    xlabel('log(Amplitude) [a.u.]')
    ylabel('Probability')
    title('Localization amplitude before/after sigma filtering')
    savefig(strcat(saveDir,'LocAmplitude.fig'));
    if showIntermediate==0
        close(f_histo);
    end
    
    clearvars -except pixelsize fittype threshold dolP showIntermediate showDOL rootfolder subFolders expressionCh expressionTS dye_Halo dye_SNAP AnalysisOption
end