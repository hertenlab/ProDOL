% function to calculate mean and std values by grouping variables
% 
% input
% - groups
%   grouping variable generated with findgroups command
% - varargin
%   for all elements mean and std are calculated in the groups
% 
% output
% - outStruc
%   structure array containing fields for mean and std values for all input
%   elements in varargin

function outStruct = meanAndStd(valid, groups, varargin)
    
    for i = 1:length(varargin)
        varname = inputname(i+2);
        if isempty(varname)
            msg = sprintf(['Input error at input argument %d.\n'...
                'Do not use calculations for input arguments. Only use variables.'],i+2);
            error(msg);
        end
        [meanValues, stdValues] = meanAndStd_groups(groups(valid), varargin{i}(valid));
        outStruct.(['Mean_' varname]) = meanValues;
        outStruct.(['Std_' varname]) = stdValues;
    end

end

function [meanValues, stdValues] = meanAndStd_groups(groups, Values)

    meanValues = splitapply(@mean, Values, groups);
    stdValues = splitapply(@std, Values, groups);

end