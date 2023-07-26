% function for filtering points based on the aplitude.
% input:
% - threshold
% - filterVariable
%   Variable on which the thresholding is performed (typically amplitude or
%   sigma (Points_Blue_A or Points_Green_s))
% - varargin
%   additional variables that are filtered by the same scheme as
%   filterVariable (typically Points_Blue_x etc.)

function [filtered, varargout] = filterPointsByThreshold(threshold, filterVariable, varargin)

    % Check input
    if nargin>2
        for i = 1:length(varargin)
            sizeCheck(i) = isequal(size(filterVariable), size(varargin{i}));
        end
    else
        sizeCheck = 1;
    end
    if ~all(sizeCheck)
        error('Additional inputs must have the same size as filterVariable')
    end
    
    fprintf('filtering %s by threshold of %g\n', inputname(2), threshold);
    
    filtered = filterVariable;
    varargout = varargin;
    % If input filterVariabl and varargin are cell arrays of vectors it
    % loops through them
    if iscell(filterVariable)
        
        for i = 1:length(filterVariable)
            
            subVar = filterVariable{i};
            for j = 1:length(varargin)
                extraVars{j} = varargin{j}{i};
            end
            
            [filtered{i}, extraVars_filtered] = filtering(threshold, subVar, extraVars);
            
            for j = 1:length(varargin)
                varargout{j}{i} = extraVars_filtered{j};
            end
        end
    else
        [filtered, varargout] = filtering(threshold, filterVariable, varargin);
    end
    
    fprintf('kept %.0f %% (%d / %d) of input data\n', 100*length([filtered{:}])/length([filterVariable{:}]), length([filtered{:}]), length([filterVariable{:}]))

end

function [filtered, extraVars_filtered] = filtering(threshold, filterVariable, extraVars)
    
    filtered = filterVariable(filterVariable > threshold);
    for i = 1:length(extraVars)
        extraVars_filtered{i} = extraVars{i}(filterVariable > threshold);
    end

end