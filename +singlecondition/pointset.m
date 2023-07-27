classdef pointset < matlab.mixin.Copyable
    %   This is a class to hold information about a spectral (or other
    %   type of) channel for a certain cell or field of view (i.e. a
    %   multichannelimage). It refers to points in this channel and stores
    %   information obtained from DOL analysis e.g. number of colocalized
    %   particles, particle density, ...
    %
    %   Detailed explanation goes here
    
    properties
        name = '';
        parentImage = [];
        sourceFile = '';
        pointDetectionParameters = struct();
        
        points = [];    % n-by-9 array of points with columns
        pointsColumns = {'x', 'y', 'x rotated', 'y rotated', 'x registered', 'y registered', 'amplitude', 'sigma', 'offset'};
        pointDensity = [];                      % in particles / um^2
        
        % registration
        transformation = [];
        % point filtering
        pointFilteringParameters = struct();
        % analysis results
        results = singlecondition.dolan.empty;
        
    end
    
    methods
        % constructor
        function obj = pointset(name, parentImage, sourceFile)
            obj.name = name;
            obj.parentImage = parentImage;
            obj.sourceFile = sourceFile;
        end
        
        % adds points to the pointset. existing points are replaced
        function addPoints(obj, x, y, amplitude, sigma, offset)
            numPoints = length(x);
            obj.points = nan(numPoints,9);
            obj.points(:,1) = x;
            obj.points(:,2) = y;
            obj.points(:,7) = amplitude;
            obj.points(:,8) = sigma;
            obj.points(:,9) = offset;
            obj.rotatePoints();
        end
        
        % rotate position
        function rotatePoints(obj)
            rotX = obj.points(:,2);
            rotY = obj.parentImage.imageSize(1) - obj.points(:,1);
            obj.points(:,3:4) = [rotX rotY];
        end
        
        % return positions of all points in this set. Use additional
        % argument to select rotated or registered position.
        function allPositions = getAllPositions(obj, varargin)
            if isempty(obj)
                allPositions = double.empty(0,2);
            else
                if nargin == 1 || strcmp(varargin{1}, 'original')
                    allPositions = obj.points(:,1:2);
                else
                    switch varargin{1}
                        case 'rotated'
                            allPositions = obj.points(:,3:4);
                        case 'registered'
                            allPositions = obj.points(:,5:6);
                    end
                end
            end
        end
        
        % return string describing pointset and parent objects
        function description_string = description(obj)
            pointSetName = obj.name;
            replicate = ['replicate ' num2str(obj.parentImage.replicate)];
            descriptors = '';
            fieldNames = fieldnames(obj.parentImage.parentImageSet.descriptors);
            for i = 1:length(fieldNames)
                fName = fieldNames{i};
                value = num2str(obj.parentImage.parentImageSet.descriptors.(fieldNames{i}));
                descriptors = [descriptors fName ': ' value];
                if ~(i == length(fieldNames))
                    descriptors = [descriptors  ', '];
                end
            end
            description_string = [descriptors ' / ' replicate ' / ' pointSetName];
        end
        
        % calculate density of points in this pointset using the segmented
        % area from parentImage if available. Otherwise the image size of
        % the first channel of the parentImage is used.
        function calculateDensity(obj)
            if ~isempty(obj.parentImage.segmentedArea)
                area = obj.parentImage.segmentedArea;
            elseif any(strcmp({obj.parentImage.channels.name}, 'mask'))
                obj.parentImage.areaFromMask();
                area = obj.parentImage.segmentedArea;
            else
                info = imfinfo(obj.parentImage.channels(1).path);
                area = info.Width * info.Height * (obj.parentImage.pixelSize ^ 2);
            end
            obj.pointDensity = size(obj.points,1) / area;
        end
        
        % calculate transformation matrix to base pointset
        function calculateTransformation(obj, basePointSet)
            basePos = basePointSet.getAllPositions();
            targetPos = obj.getAllPositions();
            if ~isempty(targetPos)
                % prefilter points to have only one neighbor with distance <
                % 2px in other channel
                [targetValid, baseValid] = RegPreFilter(targetPos(:,1), targetPos(:,2), basePos(:,1), basePos(:,2), 2);
                % perform registration only with more than 50 points
                if length(targetValid) > 50
                    % calculate transformation matrix
                    tform = fitgeotrans(targetValid, baseValid, 'projective');
                    
                    % reject coarse transformation
                    translation = tform.T(3,1:2);
                    rotation = asin(tform.T(2,1));
                    scaling = [tform.T(1,1) / cos(rotation), tform.T(2,2) / cos(rotation)];
                    if any(abs(translation) > 3) ||...
                            abs(rotation*360/(2*pi)) > 0.05 ||...
                            any(scaling-1 > 0.05)
                        %                     fprintf('Transformation rejected: %f px (in x) %f px (in y); rotation: %f °; scaling: %f (in x) %f (in y)\n\tfrom: %s\tto: %s    \n', translation, rotation*360/(2*pi), scaling, obj.description(), basePointSet.name);
                        obj.transformation = [];
                    else
                        % store transformation as dolan in this point set
                        obj.transformation = struct('T', tform.T, 'baseName', basePointSet.name);
                    end
                else
                    obj.transformation = [];
                    %                 fprintf('not enough points for transformation calculation:\n\tfrom: %s\tto: %s    \n)', obj.description(), basePointSet.name)
                end
            end
            
        end
        
        % Apply transformation matrix to calculate registered position for
        % all points in this set
        function applyTransformation(obj, meanT)
            for i = 1:length(obj)
                if isempty(meanT)
                    meanT=[0.998989412168349,-1.351030229210426e-04,1.759430293076820e-07;2.203694675143186e-04,0.998942525963370,3.593612545106758e-07;0.333906008185876,-0.077034427985785,1];
                end
                tform = projective2d(meanT);
                obj(i).points(:,5:6) = transformPointsForward(tform, obj(i).points(:,1:2));
            end
        end
        
        % Mark this pointset as base for transformation, store unity
        % transformation matrix with pointset and copy original position to
        % registeredPosition
        function setAsTransformationBase(obj)
            unity = [1 0 0; 0 1 0; 0 0 1];
            for i = 1:length(obj)
                obj(i).transformation.T = unity;
                obj(i).transformation.baseName = 'unity';
                obj(i).points(:,5:6) = obj(i).points(:,1:2);
            end
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
        
        % newName: name of new pointset (e.g. 'u-track green filtered')
        % pointParameter: 'sigma', 'amplitude', 'offset'
        % filterValues: 2-element vector. point parameter must be greater
        %   than the first and/or smaller than the second value
        % appendOrReplace: 'append' 
        function filterPoints(obj, newName, pointParameter, filterValues, appendOrReplace)
            % check inputs
            if ~any(strcmp({'sigma', 'amplitude', 'offset'}, pointParameter))
                fprintf('%s is not a valid filtering parameter\n', pointParameter);
                return;
            end
            % copy point set
            filteredSet = copy(obj);
            % retrieve parameters of points
            values = obj.points(:,strcmp(obj.pointsColumns, pointParameter));
            % check against filterValues and create logical vector
            if filterValues(2) >= filterValues(1)
                filterIdx = values >= filterValues(1) & values <= filterValues(2);
            else
                filterIdx = values >= filterValues(1) | values <= filterValues(2);
            end
            % remove handles for rejected points
            filteredSet.points = obj.points(filterIdx,:);
            
            % add filtering parameters to pointDetectionParameters (attach
            % if base set has been filtered on that parameter before
            if isfield(obj.pointFilteringParameters, pointParameter) 
                preFilterValues = obj.pointFilteringParameters.(pointParameter);
            else
                preFilterValues = [];
            end
            filteredSet.pointFilteringParameters.(pointParameter) = [preFilterValues; filterValues];
            filteredSet.pointFilteringParameters.origin = obj;
            filteredSet.name = newName;
            % calculate point density
            filteredSet.calculateDensity();
            % add filtered point set to parent image or replace pointset
            % with identical name
            matches = strcmp({obj.parentImage.childPointSets.name}, newName);
            switch appendOrReplace
                case 'append'
                    obj.parentImage.addPointSet(filteredSet);
                case 'replace'
                    if isempty(matches) || sum(matches) == 0
                        obj.parentImage.addPointSet(filteredSet);
                    elseif sum(matches) == 1
                        obj.parentImage.childPointSets(matches) = filteredSet;
                    else
                        % throw error
                        warning('found multiple pointsets with this name. Don''t know which one to replace. Attaching it insted')
                        % attach dolan
                        obj.parentImage.addPointSet(filteredSet);
                    end 
                otherwise
                    fprintf('%s is not a valid choice, use ''append'' or ''replace''.\n filtered point set is not attached to image', appendOrReplace);
                    return;
            end
            
        end
            
    end
end

