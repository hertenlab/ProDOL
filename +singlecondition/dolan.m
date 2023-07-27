classdef dolan < handle
    %   This is a class to hold results from DOL analysis. It refers to the
    %   two involved channels and the points, images or image sets used for
    %   calculation. This is a generic class and can be used for a
    %   multitude of quantities (e.g. nearest neighbor of a point,
    %   significant colocalization distance threshold for two channels of
    %   an image, DOL of a cell, average of DOLs of replicates in an image
    %   set, ...)
    %
    %   Detailed explanation goes here
    
    properties
        basePointSet = [];
        targetPointSet = [];
        varName = '';
        value = [];
        uncertainty = [];
        parameter = [];
        comment = '';
%         includedPoints = [];
        includedImages = [];
        includedImageSets = [];
    end
    
    methods
        function obj = dolan(basePointSet, targetPointSet, varName, value, uncertainty, comment)
            obj.basePointSet = basePointSet;
            obj.targetPointSet = targetPointSet;
            obj.varName = varName;
            obj.value = value;
            obj.uncertainty = uncertainty;
            obj.comment = comment;
        end
        
        % Check if this dolan matches various combination of properties and
        % values. Example: check if dolan has value 17 and varName
        % 'intensity':
        % isDolanByVars('value', 17, 'varName', 'intensity')
        %   result: true
        function out = isDolanByVars(obj, varargin)
            out = true(size(obj));
            for i = 1:length(obj)
                for j = 1:2:length(varargin)
                    if ~isequal(obj(i).(varargin{j}), varargin{j+1})
                        out(i) = false;
                        break
                    end
                end
            end
        end
        
        function matchingDolans = dolanByVars(obj, varargin)
            matchingDolans = obj(obj.isDolanByVars(varargin{:}));
        end
        
    end
    
end

