% function for filtering points based a threshold calculated from a subset
% of the data. Usually point amplitudes of unstained cells are analyzed and
% a threshold is set at the input percentile. Points with lower amplitude
% are eliminated.
% input:
% - percentile
%   percentage value (e.g. 90)
% - reference
%   logical vector selecting entries of filterVariable that are used for
%   threshold calculation (typically unstained cells)
% - sample
%   logical vector selecting entries where filtering is performed
%   (typically a certain cell type and a incubation time)
% - filterVariable
%   Variable on which the threshold calculation is performed (typically
%   point amplitude) and where filtering is performed
% - varargin
%   additional variables that are filtered by the same scheme as
%   filterVariable (typically Points_Blue_x etc.)

function [threshold, filtered, varargout] = filterPointsByPercentile(percentile, reference, sample, filterVariable, varargin)

    % Check input
    if nargin>4
        for i = 1:length(varargin)
            sizeCheck(i) = isequal(size(filterVariable), size(varargin{i}));
        end
    else
        sizeCheck = 1;
    end
    if ~all(sizeCheck) || length(reference) ~= length(filterVariable) ||...
            length(sample) ~= length(filterVariable)
        error(['Input dimensions mismatch. reference, sample and filterVariable must have same length. '...
            'varargin must have same dimension as filterVariable'])
    end
    
    fprintf('filtering %s by %d-percentile\n', inputname(4), percentile);
    
    referenceValues  = filterVariable(reference);
    threshold = prctile([referenceValues{:}], percentile);
    
    % Preallocation of output variables
    filtered = filterVariable;
    varargout = varargin;
%     varargout = cell(size(varargin));
%     for j = 1:length(varargin)
%         varargout{j} = cell(size(filterVariable));
%     end
    
    % filtering points
    for i = 1:length(filterVariable)
        if sample(i)
            filtered{i} = filterVariable{i}(filterVariable{i} > threshold);
            if nargin > 4
                for j = 1:length(varargin)
                    varargout{j}{i} = varargin{j}{i}(filterVariable{i} > threshold);
                end
            end
        end
    end
    
    fprintf('kept %.0f %% (%d / %d) of input data\n', 100*length([filtered{:}])/length([filterVariable{:}]), length([filtered{:}]), length([filterVariable{:}]))
    
end