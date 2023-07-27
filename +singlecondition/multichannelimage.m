classdef multichannelimage < matlab.mixin.Copyable
    %   This is a class to hold information about a part of a sample imaged
    %   for DOL analysis. It groups microscopy and other channels for a
    %   certain cell or a field of view. 
    
    properties
        channels = struct();
        imageSize = [];
        pixelSize = [];             % in um/px
        childPointSets = [];
        parentImageSet = [];
        replicate = [];
        segmentedArea = [];         % in um^2
        results = singlecondition.dolan.empty;
        include = [];
    end
    
    methods
        % constructor
        % channels input must be a 2 x n cell array containing the name of
        % the colorchannel (e.g. green, mask) and the path to the
        % respective tif-file
        function obj = multichannelimage(parentImageSet, channels, replicate)
            obj.parentImageSet = parentImageSet;
            channelName = channels(1,:);
            channelPath = channels(2,:);
            % check existence of files
            imageSizes = zeros(2,length(channelPath));
            for i = 1:length(channelPath)
                if (exist(channelPath{i},'file') ~= 2)
                    warning('File not found:\n%s\n', channelPath{i});
                end
            end
            info = imfinfo(channelPath{1});
            obj.imageSize = [info.Width info.Height];
            obj.channels = struct('name', channelName, 'path', channelPath);
            obj.replicate = replicate;
        end
        
        function obj = orphan(obj)
            for i = 1:length(obj)
                obj(i).parentImageSet = [];
            end
        end
        
        % return string describing pointset and parent objects
        function description_string = description(obj)
            description_string = cell(numel(obj), 1);
            for j = 1:length(obj)
                repString = ['replicate: ' num2str(obj(j).replicate)];
                descriptors = '';
                fieldNames = fieldnames(obj(j).parentImageSet.descriptors);
                for i = 1:length(fieldNames)
                    fName = fieldNames{i};
                    value = num2str(obj(j).parentImageSet.descriptors.(fieldNames{i}));
                    descriptors = [descriptors fName ': ' value];
                    if ~(i == length(fieldNames))
                        descriptors = [descriptors  ', '];
                    end
                end
                description_string{j} = [descriptors ', ' repString];
            end
            
            if numel(obj) == 1
                description_string = description_string{1};
            end
        end
        
        % add pointset to this image
        function addPointSet(obj, ptSet)
            if ~isempty(obj.childPointSets) && any(strcmp({obj.childPointSets.name},ptSet.name))
                warning('pointset with identical name is replaced');
                ptSetIdx = find(strcmp({obj.childPointSets.name},ptSet.name));
                obj.childPointSets(ptSetIdx) = ptSet;
            else
                obj.childPointSets = [obj.childPointSets ptSet];
            end
        end
        
        % calculate area from color channel 'mask' (must be a tif-file
        % where the outer area is set to 0
        function areaFromMask(obj)
            if any(strcmp({obj.channels.name}, 'mask'))
                mask = imread(obj.channels(strcmp({obj.channels.name}, 'mask')).path);
                obj.segmentedArea = sum(mask(:) > 0) * (obj.pixelSize^2);
            end
        end
        
        function path = channelPath(obj, channelName)
            channelIdx = strcmp({obj.channels.name}, channelName);
            if ~any(channelIdx)
                path = '';
            else
                path = obj.channels(channelIdx).path;
            end
        end
        
        % Return pointsets of this obj image(s) with a distinct name, 
        % as defined in the pointset property
        function pointSet = pointSetByName(obj, name)
            pointSet = [];
            for i = 1:length(obj)
                pointSet = [pointSet ...
                    obj(i).childPointSets(strcmp({obj(i).childPointSets.name}, name))];
            end
        end
        
        % calculate degree of colocalisation between baseName and
        % targetName pointset with a colocalisation threshold of
        % tolerance(s)
        function obj = colocalisation(obj, baseName, targetName, tolerance)
            for i = 1:length(obj)
                baseSet = obj(i).pointSetByName(baseName);
                targetSet = obj(i).pointSetByName(targetName);
                
                % use registered positions if available, else use original
                % positions
                if any(isnan(baseSet.getAllPositions('registered')))
                    disp('No registered points, using original positions instead');
                    basePos = baseSet.getAllPositions();
                else
                    basePos = baseSet.getAllPositions('registered');
                end
                if any(isnan(targetSet.getAllPositions('registered')))
                    disp('No registered points, using original positions instead');
                    targetPos = targetSet.getAllPositions();
                else
                    targetPos = targetSet.getAllPositions('registered');
                end
                targetRotated = targetSet.getAllPositions('rotated');
                
                [netColoc, netMulti, netColocRandom, netMultiRandom] = deal(...
                    nan(length(tolerance),1));
                for t = 1:length(tolerance)
                    % calculate colocalisation
                    [numBase, numTarget, netColoc(t), netMulti(t)] = detectColocalisation(basePos(:,1), basePos(:,2), targetPos(:,1), targetPos(:,2), tolerance(t), tolerance(t));
                    [~, ~, netColocRandom(t), netMultiRandom(t)] = detectColocalisation(basePos(:,1), basePos(:,2), targetRotated(:,1), targetRotated(:,2), tolerance(t), tolerance(t));
                end
                obj(i).makeDolan(baseSet, targetSet, numBase, netColoc, netMulti, netColocRandom, netMultiRandom, tolerance);
                obj(i).makeDolan(targetSet, baseSet, numTarget, netColoc, netMulti, netColocRandom, netMultiRandom, tolerance);
            end
        end
        
        % Calculate dol from colocalising particles and store as dolan with
        % both pointsets
        function makeDolan(obj, baseSet, targetSet, numPoints, netColoc, netMulti, netColocRandom, netMultiRandom, tolerance)
            DOL = netColoc ./ numPoints;
            DOLrandom = netColocRandom ./ numPoints;
            dolDolan = singlecondition.dolan(baseSet, targetSet, 'DOL over threshold', DOL, [], 'parameter: distance threshold');
            multiDolan = singlecondition.dolan(baseSet, targetSet, 'multi-assignments over threshold', netMulti, [], 'parameter: distance threshold');
            dolRandomDolan = singlecondition.dolan(baseSet, targetSet, 'DOL-Random over threshold', DOLrandom, [], 'parameter: distance threshold');
            multiRandomDolan = singlecondition.dolan(baseSet, targetSet, 'multi-assignments-Random over threshold', netMultiRandom, [], 'parameter: distance threshold');
            [dolDolan.parameter,  multiDolan.parameter, dolRandomDolan.parameter, multiRandomDolan.parameter] = deal(tolerance);
            obj.addResults([dolDolan, multiDolan, dolRandomDolan, multiRandomDolan]);
        end
        
        function makeSignificantDolan(obj, baseName, targetName, significantT)
            baseSet = obj.pointSetByName(baseName);
            targetSet = obj.pointSetByName(targetName);
            allResults = obj.results;
            % retrieve dol-values calculated over thresholds
            dolDolan = allResults.dolanByVars('basePointSet', baseSet, 'targetPointSet', targetSet, 'varName', 'DOL over threshold');
            multiDolan = allResults.dolanByVars('basePointSet', baseSet, 'targetPointSet', targetSet, 'varName', 'multi-assignments over threshold');
            dolRandomDolan = allResults.dolanByVars('basePointSet', baseSet, 'targetPointSet', targetSet, 'varName', 'DOL-Random over threshold');
            multiRandomDolan = allResults.dolanByVars('basePointSet', baseSet, 'targetPointSet', targetSet, 'varName', 'multi-assignments-Random over threshold');
            % select value at significant distance threshold and create
            % new dolan
            tol = 1e-6;
            sIndex = find(abs(dolDolan.parameter - significantT) <= tol);            
            %sIndex = dolDolan.parameter == significantT;
            sDOL = singlecondition.dolan(baseSet, targetSet, 'DOL', dolDolan.value(sIndex), [], sprintf('threshold: %1.1f px', significantT));
            sMulti = singlecondition.dolan(baseSet, targetSet, 'multi-assignments', multiDolan.value(sIndex), [], sprintf('threshold: %1.1f px', significantT));
            sDOLRand = singlecondition.dolan(baseSet, targetSet, 'DOL-Random', dolRandomDolan.value(sIndex), [], sprintf('threshold: %1.1f px', significantT));
            sMultiRand = singlecondition.dolan(baseSet, targetSet, 'multi-assignments-Random', multiRandomDolan.value(sIndex), [], sprintf('threshold: %1.1f px', significantT));
            obj.addResults([sDOL, sMulti, sDOLRand, sMultiRand]);
        end
        
        % Add dolan to results of this image. If a result with
        % identical parameters is already stored it is overwritten
        function addResults(obj, newDolan)
            for i = 1:length(newDolan)
                % compare existing DOLdolans with properties of new dolan
                % (base and target pointset, variable name and parameter)
                matches = obj.results.isDolanByVars('basePointSet', newDolan(i).basePointSet,...
                    'targetPointSet', newDolan(i).targetPointSet,...
                    'varName', newDolan(i).varName,...
                    'parameter', newDolan(i).parameter);
                if isempty(matches) || sum(matches) == 0
                    % attach dolan
                    obj.results = [obj.results, newDolan(i)];
                elseif sum(matches) == 1
                    % replace dolan
                    obj.results(matches) = newDolan(i);
                else
                    % throw error
                    warning('found multiple results dolan with these properties. Don''t know which one to replace. Attaching it insted')
                    % attach dolan
                    obj.results = [obj.results, newDolan(i)];
                end
            end
        end
        
        function [value, uncertainty] = resultByName(obj, resultName, basePointSet, targetPointSet)
            for i = 1:length(obj)
                allDolans = [obj(i).results];
                matchingDolan = allDolans.dolanByVars('varName', resultName, ...
                    'basePointSet', basePointSet, 'targetPointSet', targetPointSet);
                if isempty(matchingDolan)
                    value(i) = nan;
                    uncertainty(i) = nan;
                else
                    value(i) = matchingDolan.value;
                    if isempty(matchingDolan.uncertainty)
                        uncertainty(i) = nan;
                    else
                        uncertainty(i) = matchingDolan.uncertainty;
                    end
                end
            end
        end
        
    end
    
end

