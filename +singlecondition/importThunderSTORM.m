function datasets = importThunderSTORM(imageSet,dataP,fileNameStruct)


%% load or import thunderSTORM results
switch exist(dataP)
    %% load from .mat file
    case 2
        fprintf('loading datasets .mat file.\n')
        load(dataP);
        datasets_path = dataP;
        %% import from thunderSTORM .csv files and corresponding image_list
    case 7
        fprintf('importing thunderSTORM data from .csv files.\n')
        ilPath = fullfile(dataP, 'image_list.txt');
        
        % create movie objects based on image_list.txt
        % read image_list.txt
        [~,fileID] = importImageList(ilPath,2);
        datasets = [];
        
        for i=1:length(fileID)
            [~,t1{i},~] = fileparts(fileID{i});
            descriptor = singlecondition.parseFn(t1{i},'_',fileNameStruct);
            
            % trim replicate ID
            descriptor.rep = descriptor.rep(5:end);
            
            if isfield(descriptor,'chan')
                descriptor = rmfield(descriptor,'chan');
            end
            if numel(datasets)==0
                currentmovie = movie(descriptor);
            elseif numel(datasets.moviesWithProperty(descriptor))==0
                currentmovie = movie(descriptor);
            else
                currentmovie = [];
            end
            datasets = [datasets currentmovie];
        end
        
        % import thunderSTORM .csv files as analysis objects and add to corresponding movie object
        if strcmp(dataP(end),'\')
            tsFiles = ls(strcat(dataP,'tsoutput*.csv'));
        else
            tsFiles = ls(strcat(dataP,'\tsoutput*.csv'));
        end
        for i=1:size(tsFiles,1)
            [~, ~, ~, ~, ~, fittype, threshold] = conditionsFromPathTS(tsFiles(i,:));
            % import TS output file
            [id,frame,x,y,sigma,intensity,offset,bkgstd,uncertainty] = pointsFromTS(fullfile(dataP,tsFiles(i,:)));
            
            % import
            for j=1:max(frame)
                dispProgress(i,size(tsFiles,1),j, max(frame))
                descriptor = singlecondition.parseFn(t1{j},'_',fileNameStruct);
                % trim replicate ID
                descriptor.rep = descriptor.rep(5:end);
                
                if isfield(descriptor,'chan')
                    chan = descriptor.chan;
                    descriptor = rmfield(descriptor,'chan');
                else
                    error('Channel information missing')
                end
                idx = frame(:)==j;
                if sum(idx)>0
                    % identify correct movie object to add analysis to
                    currentmovie = datasets.moviesWithProperty(descriptor);
                    
                    % create analysis object
                    currentanalysis = analysis(id(idx),frame(idx),x(idx),y(idx),sigma(idx),intensity(idx),offset(idx),bkgstd(idx),uncertainty(idx),fittype,threshold,chan);
                    currentmovie.analysis = [currentmovie.analysis currentanalysis];
                end
            end
        end
end


%% convert movie objects to DOL objects

tsChannels = {'eGFP' 'Halo' 'SNAP'};
descriptors = [datasets.descriptors]';
tsReplicate = cell2mat({descriptors.rep}');

fittype = 'multi';
threshold = '2.0';

for setIndex = 1:size(imageSet,2)
        x = struct();
        y = struct();
        thisSet = imageSet(setIndex);
        childImages = thisSet.childImages;
    
        for repIndex = 1:size(imageSet(setIndex).childImages,2)
            % match datasets index
            thisImage = childImages(repIndex);
            replicate = thisImage.replicate;

            tsIndex = str2num(tsReplicate(repIndex,:));
            
            % filter points by mask
            maskFile = thisImage.channelPath('mask');
            pxSize = thisImage.pixelSize;
            
            datasets(tsIndex).filteranalysisbymask(maskFile, pxSize * 1000);
            
            % extract points
            [x.eGFP, y.eGFP, A.eGFP, c.eGFP, s.eGFP,...
                x.Halo, y.Halo, A.Halo, c.Halo, s.Halo,...
                x.SNAP, y.SNAP, A.SNAP, c.SNAP, s.SNAP] = ...
                convertTStoDOL(datasets(tsIndex), fittype, threshold);
            
            for ch = 1:length(tsChannels)
                setName = ['ts_multi ' tsChannels{ch}];
                ptSet = singlecondition.pointset(setName, thisImage, dataP);
                ptSet.pointDetectionParameters = struct('threshold', threshold, 'fittype', fittype, 'channel', tsChannels{ch});
                ptSet.parentImage.addPointSet(ptSet);

                % add points to pointset
                ptSet.addPoints(x.(tsChannels{ch}){:}, y.(tsChannels{ch}){:},...
                    A.(tsChannels{ch}){:}, s.(tsChannels{ch}){:}, c.(tsChannels{ch}){:});

                % calculate density
                ptSet.calculateDensity();
            end
            dispProgress(setIndex, size(imageSet,2), repIndex, size(imageSet(setIndex).childImages,2))
        end
end

            
