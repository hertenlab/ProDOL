function datasets =importTS(root_dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TODO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Check if all conditions are complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% object array containing all movie objects
datasets = [];

% List all files in data directory
allFiles = getAllFiles(root_dir);

%datasets = cell(length(allFiles),1);
datasets = {};

% Find .csv files
for i = 1:length(allFiles)
    [fpath, fname, fext] = fileparts(allFiles{i});
    
    % Identify conditions from .csv file names
    if strcmp(fext,'.csv')
        fprintf('Found .csv file: %s \n', allFiles{i})
        progress = round((i/length(allFiles))*100,2);
        fprintf('Import is %.2f %% complete.\n', progress)
        
        [incubation_time, CellType, concentration, replicate, channel, fittype, threshold] = conditionsFromPathTS(allFiles{i});  
        
        % check if entry in dataset already exists. If so, provide id
        movieid = findobj(datasets,'incubation_time',incubation_time,'CellType',CellType,'concentration',concentration,'replicate',replicate);
        
        % if no dataset exists, create one and append to datasets
        if isempty(movieid)
            currentmovie = movie(incubation_time,CellType,concentration,replicate);
            datasets = [datasets currentmovie];
            movieid = currentmovie;
        end
        
        % Create analysis object from .csv file and concatenate to analysis array within movie object
        [id,frame,x,y,sigma,intensity,offset,bkgstd,uncertainty] = pointsFromTS(fullfile(fpath,strcat(fname,fext)), 2);
        currentanalysis = analysis(id,frame,x,y,sigma,intensity,offset,bkgstd,uncertainty,fittype,threshold,channel,incubation_time,CellType,concentration,replicate);
        movieid.analysis = [movieid.analysis currentanalysis];

    end
end