classdef imageset < matlab.mixin.Copyable
    %   This is a class to group input and output for DOL analysis. It
    %   groups images generated under identical conditions ergo replicates
    %   as well as sesults from DOL analysis averaged over these
    %   replicates.
    
    properties
        childImages = [];                   % multichannelimage object vector of cells/field of views included in this set
        descriptors = struct();             % properties of this set
        results = singlecondition.dolan.empty;              % dolan object vector of DOL analysis results
        meanTransformation = struct('T', [], 'baseName', [], 'includedPointSets', []);
        colocThreshold = [];
    end
    
    methods
        % constructor
        function obj = imageset(descriptors)
            obj.descriptors = descriptors;
        end
        
        % add multichannelimage to imageset
        function addImage(obj, mci)
            obj.childImages = [obj.childImages mci];
        end
        
        % Return pointsets matching descriptors with name-value-pairs e.g.
        % imgsets.imageSetByDescriptor('concentration', 1)
        function matchingSets = imageSetByDescriptor(obj, varargin)
            idx = true(size(obj));
            for i = 1:length(obj)
                for j = 1:2:length(varargin)
                    switch class(varargin{j+1})
                        case 'char'
                            if ~strcmp(obj(i).descriptors.(varargin{j}),varargin{j+1})
                               idx(i) = false;
                               break
                            end
                        case 'double'
                            if ~(obj(i).descriptors.(varargin{j}) == varargin{j+1})
                                idx(i) = false;
                                break
                            end
                    end
                end
            end
            matchingSets = obj(idx);
        end
        
        % Calculate point density for all pointsets in all images of this
        % imageset
        function calculateDensity(obj, setName)
            % loop over imagesets
            for i = 1:length(obj)
                % loop over images
                for j = 1:length(obj(i).childImages)
                    obj(i).childImages(j).pointSetByName(setName).calculateDensity();
                end
            end
        end
        
        function all = getAllPointSets(obj)
            all = singlecondition.pointset.empty;
            for i = 1:length(obj)
                for j = 1:length(obj(i).childImages)
                    all = [all obj(i).childImages(j).childPointSets];
                end
            end
        end
        
        function pointSetNames = getPointSetNames(obj)
            allPointSets = getAllPointSets(obj);
            pointSetNames = unique({allPointSets.name})';
        end
        
        function ptSets = getPointSetsByName(obj, pointSetName)
            all = getAllPointSets(obj);
            matches = strcmp({all.name}, pointSetName);
            ptSets = all(matches);
        end
        
        function overviewTable = getAllDescriptors(obj)
            
            columns = fieldnames([obj.descriptors]);
            numColumns = length(columns);
            numRows = length(obj);
            dataCell = cell(numRows, numColumns);
            for r = 1:numRows
                for c = 1:numColumns
                    dataCell{r,c} = obj(r).descriptors.(columns{c});
                end
            end
            
            overviewTable = cell2table([num2cell(1:numRows)', dataCell], ...
                'VariableNames', [{'index'} columns']);
                
        end
        
        % Complete transformation / registration procedure for all images
        % in this imageset
        function fullTransformation(obj, baseName, targetName)
            fprintf('## Performing transformation ##\n''%s'' --> ''%s''\n', targetName, baseName);
            
            disp('# Calculate transformation matrices #');
            obj.calculateTransformation(baseName, targetName);
            
            disp('# Calculate mean transformation matrix #');
            obj.calculateMeanTransformation(baseName, targetName);
            
            disp('# Transform points by mean transformation matrix #');
            obj.applyTransformation(baseName, targetName);
        end
        
        % calculate tranformation calculation for all images of imageset(s)
        function calculateTransformation(obj, baseName, targetName)
            allImages = [obj.childImages];
            for i = 1:length(allImages)
                dispProgress(i, length(allImages));
                baseSet = allImages(i).pointSetByName(baseName);
                targetSet = allImages(i).pointSetByName(targetName);
                targetSet.calculateTransformation(baseSet);
            end
        end
        
        
        % create mean transformation from all transformation in this
        % imageset
        function calculateMeanTransformation(obj, baseName, targetName)
            meanT = [];
            count = 0;
            success = 0;
            includedPointSets = singlecondition.pointset.empty;
            for i = 1:length(obj)
                for j = 1:length(obj(i).childImages)
                    if ~isempty([obj(i).childImages.pointSetByName(targetName)])
                        count = count + 1;
                        if ~isempty(obj(i).childImages(j).pointSetByName(targetName).transformation)
                            thisT = obj(i).childImages(j).pointSetByName(targetName).transformation.T;
                            includedPointSets = [includedPointSets, obj(i).childImages(j).pointSetByName(targetName)];
                            meanT = cat(3,meanT,thisT);
                            success = success + 1;
                        end
                    end
                end
            end
            meanT = mean(meanT,3);
            
            if success >0
                meanTransform = struct('T', meanT, 'baseName', baseName, 'includedPointSets', includedPointSets);
                [obj.meanTransformation] = deal(meanTransform);
            
                fprintf('\t%d of %d transformations successful\n', success, count)
                meanTranslationX = meanT(3,1);
                meanTranslationY = meanT(3,2);
                meanRotation = asin(meanT(2,1));
                meanScalingX = meanT(1,1) / cos(meanRotation);
                meanScalingY = meanT(2,2) / cos(meanRotation);
                disp('Mean transformation values:')
                disp(table(meanTranslationX, meanTranslationY, meanRotation, meanScalingX, meanScalingY))
            else
                fprintf('No transformation successful. Could not compute mean transformation.')
            end
        end
        
        % Use meanTransformation to calculate registeredPositions for all
        % points of this imageset. Points of pointsets with 'baseName'
        % obtain a unity transformation, registered position equals
        % original position
        function applyTransformation(obj, baseName, targetName)
            % loop over imagesets
            for i = 1:length(obj)
                dispProgress(i, length(obj));
                meanT = obj(i).meanTransformation.T;
                % loop over images
                images = obj(i).childImages;
                for j = 1:length(images)
                    images(j).pointSetByName(targetName).applyTransformation(meanT);
                    images(j).pointSetByName(baseName).setAsTransformationBase();
                end
            end
        end
        
        % Filter pointset(s) with name(s) targetName in alle images of obj
        % imageset(s) on pointParameter with filterValues. appendOrReplace
        % ('append' or 'replace') pointset with newName.
        % example: 
        % imgset.filterPointsByValue('u-track green', 'u-track green filtered', 'sigma', [0.7 2.7], 'replace')
        % (this will exclude points with sigma below 0.7 and above 2.7,
        % create a new pointset with name 'u-track green filtered' and
        % replace a pointset with this name in parent image if existing
        function filterPointsByValue(obj, targetName, newName, pointParameter, filterValues, appendOrReplace)
            if ischar(targetName)
                targetName = {targetName};
                newName = {newName};
            end
            
            for i = 1:length(obj)
                for j = 1:length(obj(i).childImages)
                    dispProgress(i, length(obj), j, length(obj(i).childImages));
                    for k = 1:length(targetName)
                        thisPointSet = obj(i).childImages(j).pointSetByName(targetName{k});
                        filterSetName = newName{k};
                        if numel(thisPointSet)>0
                            thisPointSet.filterPoints(filterSetName, pointParameter, filterValues, appendOrReplace);
                        end
                    end
                end
            end
        end
        
        % filter points by value, determine filterValue from baseSet by
        % calculating the percentile of pointParameter on all points in
        % baseSet
        % example:
        % referenceSet = imgset. imageSetByDescriptor('concentration', 0, 'celltype', 'gSEP')
        % imgset.filterPointsByPercentile('u-track green', 'u-track green filtered', 'amplitude', 90, 'replace')
        function filterPointsByPercentile(obj, baseSet, targetName, newName, pointParameter, percentile, appendOrReplace)
            % determine filter values on baseSet(s)
            allPointSets = baseSet.getPointSetsByName(targetName);
            allPoints = cat(1,allPointSets.points);
            baseData = allPoints(:,strcmp(allPointSets(1).pointsColumns, pointParameter));
            filterValues = [prctile(baseData, percentile) inf];
            % filter values
            filterPointsByValue(obj, targetName, newName, pointParameter, filterValues, appendOrReplace);
        end
        
        % Complete colocalisation procedure for all images in this imageset
        function colocalisation(obj, baseName, targetName, saveDir)
            
            fprintf('## Calculating colocalisation ##\n''%s'' <-> ''%s''\n', baseName, targetName);
            obj.calculateColocOverThresholds(baseName, targetName)
            
            disp('# Calculating significant colocalisation distance threshold #');
            obj.findSignificantThreshold(baseName, targetName,saveDir);
            disp('# Extract colocalisation at distance threshold #');
            obj.setSignificantDOL(baseName, targetName);
            
            disp('# Calculate mean colocalisation for imagesets #');
            obj.calculateMeanColocalisation('all', baseName, targetName);
            obj.calculateMeanColocalisation('all', targetName, baseName);
            obj.calculateMeanColocalisation('include', baseName, targetName);
            obj.calculateMeanColocalisation('include', targetName, baseName);
            obj.calculateMeanColocalisation('exclude', baseName, targetName);
            obj.calculateMeanColocalisation('exclude', targetName, baseName);
            
        end
        
        % Calculate degree of colocalisations on all images in this
        % imageset over a range of distance thresholds
        function calculateColocOverThresholds(obj, baseName, targetName)
            % loop over imagesets
            for i = 1:length(obj)
                dispProgress(i, length(obj));
                thisImageSet = obj(i);
                images = obj(i).childImages;
                % unlink parentImageSet from images to reduce overhead
                % inside parallel computation
                orphans = images.orphan;
                % calculate colocalisation between base and target
                % pointsets for every image
                parfor (j = 1:length(orphans), 4)            
                    thisImage = orphans(j);
                    thisImage = thisImage.colocalisation(baseName, targetName, (.1:.1:6));
                    orphans(j) = thisImage;
                end
                [orphans.parentImageSet] = deal(thisImageSet);
                
                images = orphans;
                obj(i).childImages = images;
            end
        end
        
        % Calculate significant colocalisation distance threshold by
        % comparing degree of colocalisation with random control in
        % dependence of the distance threshold
        function findSignificantThreshold(obj, baseName, targetName, saveDir)
            % calculate mean DOL all input imageset
            % determine significant distance threshold
            allImages = [obj.childImages];
            [dolValues, randomValues] = deal(nan(length(allImages), 60));
            for i = 1:length(allImages)
                dispProgress(i, length(allImages));
                mci = allImages(i);
                baseSet = mci.pointSetByName(baseName);
                targetSet = mci.pointSetByName(targetName);
                % check transformation: base and target must have been
                % transformed succesfully or be base pointset
                if ~isempty(baseSet) && ~isempty(targetSet)
                    if isempty(targetSet.transformation)
                        targetSet.transformation.T=[0.998381643909832,3.551779805517838e-04,1.645798804868010e-06;-4.567910596814422e-04,0.997753673299204,-3.148833551690423e-06;0.622251796015582,-0.124053717734156,1];
                    end
                    if ~isempty(baseSet.transformation) && ~isempty(targetSet.transformation)
                        allDolans = mci.results;
                        dolDolan = allDolans.dolanByVars('basePointSet', baseSet, ...
                            'targetPointSet', targetSet,...
                            'varName', 'DOL over threshold',...
                            'parameter', (0.1:.1:6));
                        dolValues(i,:) = dolDolan.value;
                        randomDolan = allDolans.dolanByVars('basePointSet', baseSet, ...
                            'targetPointSet', targetSet,...
                            'varName', 'DOL-Random over threshold',...
                            'parameter', (0.1:.1:6));
                        randomValues(i,:) = randomDolan.value;
                    end
                end
            end
            
            thresholds = dolDolan.parameter;
            
            distanceThreshold = colocalisationThreshold(dolValues, randomValues, thresholds,saveDir,targetName, 'plot');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %distanceThreshold = 3.0;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            % store distance threshold as dolan with imageset
            colocDolan = singlecondition.dolan(baseName, targetName, 'colocThreshold', distanceThreshold, [], '');
            obj.addColocThreshold(colocDolan);
            fprintf('\tcolocThreshold = %1.1f\n', distanceThreshold);
        end
        
        function setSignificantDOL(obj, baseName, targetName)
            %
            for i = 1:length(obj)
                colocDolans = [obj(i).colocThreshold];
                significantT = colocDolans.dolanByVars('basePointSet', baseName,...
                    'targetPointSet', targetName, 'varName', 'colocThreshold').value;
                for j = 1:length(obj(i).childImages)
                    dispProgress(i, length(obj), j, length(obj(i).childImages));
                    obj(i).childImages(j).makeSignificantDolan(baseName, targetName, significantT)
                    obj(i).childImages(j).makeSignificantDolan(targetName, baseName, significantT)
                end
            end
        end
        
        % Calculate mean degree of colocalisation for this imageset by
        % averaging over all images (includes number of multi-assignments
        % and random control)
        % 
        % selector can be 'include', 'exclude' or 'all' and determines on
        % which images mean values are calculated depending on include
        % property:
        %   'include': include == true
        %   'exclude': include == true & include = [];
        %   'all': include == true & include = [] & include = false;
        function calculateMeanColocalisation(obj, selector, baseName, targetName)
            % extract dol at significant distance threshold and calculate
            % mean value
            if ~any(strcmp({'include', 'exclude', 'all'}, selector))
                error('selector must be ''include'', ''exclude'' or ''all''');
            end
            fprintf('Calculate mean colocalisation ''%s'' to ''%s'' (%s)\n', targetName, baseName, selector);
            for i = 1:length(obj)
                dispProgress(i, length(obj))
                obj(i).makeMeanDolan(selector, baseName, targetName, 'DOL', ' DOL');
                obj(i).makeMeanDolan(selector, baseName, targetName, 'DOL-Random', ' DOL Random');
                obj(i).makeMeanDolan(selector, baseName, targetName, 'multi-assignments', ' multi-assignments');
                obj(i).makeMeanDolan(selector, baseName, targetName, 'multi-assignments-Random', ' multi-assignments Random');
            end
        end
        
        % calculate mean and median over images of this set and store as results dolan
        % in this imageset.
        function makeMeanDolan(obj, selector, baseName, targetName, varName, resultName)
            valVector = nan(length(obj.childImages),1);
            for i = 1:length(obj.childImages)
                mci = obj.childImages(i);
                if any(mci.include) || strcmp(selector, 'all') || (strcmp(selector, 'exclude') && isempty(mci.include))
                    matchingDolan = mci.results.dolanByVars('basePointSet', mci.pointSetByName(baseName), ...
                        'targetPointSet', mci.pointSetByName(targetName),...
                        'varName', varName);
                    valVector(i) = matchingDolan.value;
                end     
            end
            resValues{1} = nanmean(valVector);
            resValues{2} = nanmedian(valVector);
            stdValue = nanstd(valVector);
            % append (include) or (exclude) to resultName (if applicable)
            resTypes = {'mean','median'};
            for k = 1:numel(resTypes)
                if ~strcmp(selector, 'all')
                    resultName_full = [resTypes{k} resultName ' (' selector ')'];
                else
                    resultName_full = resultName;
                end
                resultDolan = singlecondition.dolan(baseName, targetName, resultName_full, resValues{k}, stdValue, 'uncertainty: standard deviation');
                resultDolan.includedImageSets = obj;
                obj.addResults(resultDolan);
            end
        end
        
        % Calculate mean and median density
        % 
        % selector  determines on which images mean density is calculated
        % (see calculateMeanColocalisation(..) for details)
        function calculateMeanDensity(obj, selector, setName)
            for i = 1:length(obj)
                valVector = nan(length(obj(i).childImages),1);
                for j = 1:length(obj(i).childImages)
                    mci = obj(i).childImages(j);
                    if any(mci.include) || strcmp(selector, 'all') || (strcmp(selector, 'exclude') && isempty(mci.include))
                        valVector(j) = mci.pointSetByName(setName).pointDensity;
                    end
                end
                resDensity{1} = nanmean(valVector);
                resDensity{2} = nanmedian(valVector);
                stdDensity = nanstd(valVector);
                % append (include) or (exclude) to resultName (if applicable)
                resTypes = {'mean','median'};
                for k = 1:numel(resTypes)
                    if strcmp(selector, 'all')
                        resultName = strcat(resTypes{k},' Density');
                    else
                        resultName = [resTypes{k} ' Density (' slector ')'];
                    end
                    resultDolan = dolan(setName, [], resultName, resDensity{k}, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                end
            end
        end
        
        % Calculate mean density for all pointsets and combinations of
        % selection ('all', 'include', 'exclude', see 
        % calculateMeanColocalisation(..) for details)
        function calculateAllMeanDensities(obj)
            for i = 1:length(obj)
                numPtSets = length(obj(i).childImages(1).childPointSets);
                setNames = {obj(i).childImages(1).childPointSets.name};
                valVector = nan(length(obj(i).childImages),numPtSets);
                includeVector = cell(length(obj(i).childImages),1);
                % retrieve all density values
                for j = 1:length(obj(i).childImages)
                    mci = obj(i).childImages(j);
                    includeVector{j} = mci.include;
                    for k = 1:numPtSets
                        valVector(j,k) = mci.pointSetByName(setNames{k}).pointDensity;
                    end
                end
                % calculate mean and create dolans
                for k = 1:numPtSets
                    % all
                    meanDensity = nanmean(valVector(:,k));
                    medianDensity = nanmedian(valVector(:,k));
                    stdDensity = nanstd(valVector(:,k));
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'mean Density', meanDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'median Density', medianDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                    % include
                    idx = cellfun(@any, includeVector);
                    meanDensity = nanmean(valVector(idx,k));
                    medianDensity = nanmedian(valVector(idx,k));
                    stdDensity = nanstd(valVector(idx,k));
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'mean Density (include)', meanDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'median Density (include)', medianDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                    % exclude
                    idx = ~cellfun(@any, cellfun(@not, includeVector, 'UniformOutput', false));
                    meanDensity = nanmean(valVector(idx,k));
                    medianDensity = nanmedian(valVector(idx,k));
                    stdDensity = nanstd(valVector(idx,k));
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'mean Density (exclude)', meanDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                    resultDolan = singlecondition.dolan(setNames{k}, [], 'median Density (exclude)', medianDensity, stdDensity, 'uncertainty: standard deviation');
                    obj(i).addResults(resultDolan);
                end
            end
        end
        
        
        % Add dolan to results of this imageset. If a result with
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
        
        function addColocThreshold(obj, newDolan)
            % add colocDolan to every element of obj
            for i = 1:length(obj)
                % replace datatype from previous version. TODO: remove when
                % possible
                if ~isa(obj(i).colocThreshold, 'dolan')
                    obj(i).colocThreshold = singlecondition.dolan.empty;
                end
                % compare existing colocDolans with properties of new dolan
                % (base and target pointset and variable name)
                matches = obj(i).colocThreshold.isDolanByVars('basePointSet', newDolan.basePointSet,...
                    'targetPointSet', newDolan.targetPointSet);
                if isempty(matches) || sum(matches) == 0
                    % attach dolan
                    obj(i).colocThreshold = [obj(i).colocThreshold, newDolan];
                elseif sum(matches) == 1
                    % replace dolan
                    obj(i).colocThreshold(matches) = newDolan;
                else
                    % throw error
                    warning('found multiple colocThreshold dolan with these properties. Don''t know which one to replace. Attaching it insted')
                    % attach dolan
                    obj(i).colocThreshold = [obj(i).colocThreshold, newDolan];
                end
            end
        end
        
        function [value, uncertainty, varargout] = resultByName(obj, resultName, baseName, targetName)
            for i = 1:length(obj)
                allDolans = [obj(i).results];
                matchingDolan = allDolans.dolanByVars('varName', resultName, ...
                    'basePointSet', baseName, 'targetPointSet', targetName);
                if ~isempty(matchingDolan)
                    value(i) = matchingDolan.value;
                    uncertainty(i) = matchingDolan.uncertainty;
                else
                    value(i) = nan;
                    uncertainty(i) = nan;
                end
                descriptorNames = fieldnames(obj(i).descriptors);
                for j = 1:length(descriptorNames)
                    varargout{j}{i} = obj(i).descriptors.(descriptorNames{j});
                end
            end
        end
        
        function densityCorrection(obj, baseName, targetName, offset, slope)
            
            % correct every single DOL dolan and add new dolan 'DOL
            % corrected' to multichannelimage
            for i = 1:length(obj)
                for j = 1:length(obj(i).childImages)
                    dispProgress(i, length(obj), j, length(obj(i).childImages))
                    mci = obj(i).childImages(j);
                    dolDolan = mci.results.dolanByVars(...
                        'basePointSet', mci.pointSetByName(baseName),...
                        'targetPointSet', mci.pointSetByName(targetName),...
                        'varName', 'DOL');
                    dolValue(j) = dolDolan.value;
                    density(j) = mci.pointSetByName(targetName).pointDensity;
                    dolCorr(j) = dolValue(j) / (offset + slope * density(j));
                    
                    % add 'DOL corrected' dolan to mci
                    dolDolanCorrected = singlecondition.dolan(baseName,targetName,'DOL corrected',dolCorr(j),[],sprintf('correction: DOL / (%.3f - %.3f * density)', offset, abs(slope)));
                    obj(i).childImages(j).addResults(dolDolanCorrected);                    
                end
                % Calculate mean for 'DOL corrected' and add dolan to
                % imageset
                meanDolCorr = nanmean(dolCorr);
                medianDolCorr = nanmedian(dolCorr);
                errDolCorr = nanstd(dolCorr);
                comment = {'uncertainty: standard deviation';
                            sprintf('correction: DOL / (%.3f - %.3f * density)', offset, abs(slope))};
                resultDolan = singlecondition.dolan(baseName, targetName, 'mean DOL corrected', ...
                    meanDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
                
                resultDolan = singlecondition.dolan(baseName, targetName, 'median DOL corrected', ...
                    medianDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
                
                % Calculate mean DOLs for included cherrypicking childimages
                meanDolCorr = nanmean(dolCorr([obj(i).childImages.include]));
                medianDolCorr = nanmean(dolCorr([obj(i).childImages.include]));
                errDolCorr = nanstd(dolCorr([obj(i).childImages.include]));
                comment = {'uncertainty: standard deviation';
                            sprintf('correction: DOL / (%.3f - %.3f * density)', offset, abs(slope))};
                resultDolan = singlecondition.dolan(baseName, targetName, 'mean DOL corrected (include)', ...
                    meanDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
                
                resultDolan = singlecondition.dolan(baseName, targetName, 'median DOL corrected (include)', ...
                    medianDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);

                % Calculate mean DOLs for excluded cherrypicking childimages
                meanDolCorr = nanmean(dolCorr(~[obj(i).childImages.include]));
                medianDolCorr = nanmean(dolCorr(~[obj(i).childImages.include]));
                errDolCorr = nanstd(dolCorr(~[obj(i).childImages.include]));
                comment = {'uncertainty: standard deviation';
                            sprintf('correction: DOL / (%.3f - %.3f * density)', offset, abs(slope))};
                resultDolan = singlecondition.dolan(baseName, targetName, 'mean DOL corrected (exclude)', ...
                    meanDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
                
                resultDolan = singlecondition.dolan(baseName, targetName, 'median DOL corrected (exclude)', ...
                    medianDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
            end
            
            
        end
        
        function densityCorrectionFlex(obj, baseName, targetName, densityName, offset, slope)
            
            % correct every single DOL dolan and add new dolan 'DOL
            % corrected flex' to multichannelimage
            for i = 1:length(obj)
                for j = 1:length(obj(i).childImages)
                    dispProgress(i, length(obj), j, length(obj(i).childImages))
                    mci = obj(i).childImages(j);
                    dolDolan = mci.results.dolanByVars(...
                        'basePointSet', mci.pointSetByName(baseName),...
                        'targetPointSet', mci.pointSetByName(targetName),...
                        'varName', 'DOL');
                    dolValue(j) = dolDolan.value;
                    density(j) = mci.pointSetByName(densityName).pointDensity;
                    dolCorr(j) = dolValue(j) / (offset + slope * density(j));
                    
                    % add 'DOL corrected' dolan to mci
                    dolDolanCorrected = singlecondition.dolan(baseName,targetName,'DOL corrected flex',dolCorr(j),[],sprintf('correction: DOL / (%.3f - %.3f * density. Density ref: %s)', offset, abs(slope), densityName));
                    obj(i).childImages(j).addResults(dolDolanCorrected);                    
                end
                % Calculate mean for 'DOL corrected' and add dolan to
                % imageset
                meanDolCorr = nanmean(dolCorr);
                errDolCorr = nanstd(dolCorr);
                comment = {'uncertainty: standard deviation';
                            sprintf('correction: DOL / (%.3f - %.3f * density. Density ref: %s)', offset, abs(slope), densityName)};
                resultDolan = singlecondition.dolan(baseName, targetName, 'mean DOL corrected flex', ...
                    meanDolCorr, errDolCorr, comment);
                resultDolan.includedImageSets = obj;
                obj(i).addResults(resultDolan);
            end
            
            
        end        
        
    end
    
end


