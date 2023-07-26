function datasets = importTSeff(ilPath,root_dir)
%%%%%%%%%%%%%%%
% This function creates a datasets array with individual movie objects
% based on output data from "DOL_thunderSTORMlocalization_efficient.ijm".
% Currently supported parameter variations: fittype (single/multi emitter
% fitting) and point detection threshold
%%%
% INPUTS
% - ilPath: Path to image_list file returned from "DOL_thunderSTORMlocalization_efficient.ijm"
% - root_dir: Directory containing one thunderSTORM results .csv file per parameter set.
%%%%%%%%%%%%%%%

% read image_list.txt
[fileID,filePath] = importImageList(ilPath,2);

% object array containing all movie objects
datasets = [];

% List all files in data directory
allFiles = getAllFiles(root_dir);

% temp store for channel IDs from file paths
channelID = cell(length(fileID));

% Create one movie object for each entry in image list file
for i = 1:length(fileID)
    
    [incubation_time, celltype, concentration, replicate, channel, ~, ~] = conditionsFromPathTS(filePath{i});
    
    channelID{i} = channel;
    
    % check if entry in dataset already exists. If so, provide id
    movieid = findobj(datasets,'incubation_time',incubation_time,'CellType',celltype,'concentration',concentration,'replicate',replicate);
    
    % if no dataset exists, create one and append to datasets
    if isempty(movieid)
        currentmovie = movie(incubation_time,celltype,concentration,replicate);
        datasets = [datasets currentmovie];
    end
end

% loop through files in results dir and identify .csv thunderSTORM output files
for i =1:length(allFiles)
    [fpath, fname, fext] = fileparts(allFiles{i});
    
    % Identify conditions from .csv file names
    if strcmp(fext,'.csv')
        fprintf('Importing .csv file: %s \n', allFiles{i})
        progress = round((i/length(allFiles))*100,2);
        
        
        % obtain fittype & threshold parameters from TS output file name
        [~, ~, ~, ~, ~, fittype, threshold] = conditionsFromPathTS(allFiles{i});
        
        % import TS output file
        [id,frame,x,y,sigma,intensity,offset,bkgstd,uncertainty] = pointsFromTS(fullfile(fpath,strcat(fname,fext)));
        
        % split data according to point id
        for j=1:max(frame)
            [inct, ct, conc, rep, ch, ~, ~] = conditionsFromPathTS(filePath{j});
            idx = frame(:)==j;
            if sum(idx)>0 
                % identify correct movie object to add analysis to
                currentmovie = findobj(datasets,'incubation_time',inct,'CellType',ct,'concentration',conc,'replicate',rep);
    
                % create analysis object
                currentanalysis = analysis(id(idx),frame(idx),x(idx),y(idx),sigma(idx),intensity(idx),offset(idx),bkgstd(idx),uncertainty(idx),fittype,threshold,ch,inct,ct,conc,rep);
                currentmovie.analysis = [currentmovie.analysis currentanalysis];
            end
        end
        fprintf('Import is %.2f %% complete.\n', progress)
    end
end

end