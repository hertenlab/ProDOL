function [filter, filterrules, targets_filtered] = filterPointsTS(filterVariable, filterValue, varargin)
%%%%%%%%%%%%
% inputs
%   - filterVariable: char/cell array, can be 1-x variables
%   - filterValue: char/cell array, 1-x strings 
%   - filterValue format: >x, <x, x-y
%   - varargin: targets
% output
%   - 
%%%%%%%%%%%%

% parse input
if ischar(filterValue)
    filterValue = {filterValue};
end

if ischar(filterVariable)
    filterVariable = {filterVariable};
end

if ischar(varargin)
    targets = {varargin};
else
    targets = varargin{1};
end

% compare length of filterVariable contents and length of target contents
if range(cellfun(@length, filterVariable)) == 0
    fvar_length = length(filterVariable{1});
    iosizes = zeros(fvar_length,size(filterVariable,2)+length(targets));
    for l=1:length(filterVariable)
        iosizes(:,l) = cellfun(@length, filterVariable{l});
    end
    for m=1:length(targets)
        iosizes(:,l+m) = cellfun(@length, targets{m});
    end
    if sum(range(iosizes,2))==0
    else
        error('stop!')
    end
else
    error('stop!')
end

% construct filter rules from filter values
filterrules = {};

for i=1:length(filterVariable)
    if strfind(filterValue{i},'>')
        filterrules = [filterrules; {filterVariable{i}, 'lt', str2num(strrep(filterValue{i},'>',''))}];
    elseif strfind(filterValue{i},'<')
        filterrules = [filterrules; {filterVariable{i}, 'st', str2num(strrep(filterValue{i},'<',''))}];    
    % create 2 filterrule entries if value range is provided
    elseif strfind(filterValue{i},'-')
        vals = strsplit(filterValue{i},'-');
        filterrules = [filterrules; {filterVariable{i}, 'lt', str2num(vals{1})}];
        filterrules = [filterrules; {filterVariable{i}, 'st', str2num(vals{2})}];
    end
end

% Construct filtering vector
filter = cell(fvar_length,1);
for j=1:fvar_length
    fr_tmp = zeros(length(filterVariable{1}{j}),1);
    for k=1:size(filterrules,1)
        switch filterrules{k,2}
            case 'st'
                fr_current = (filterrules{k,1}{j}<filterrules{k,3})';
            case 'lt'
                fr_current = (filterrules{k,1}{j}>filterrules{k,3})';
        end
        if k==1
            fr_aggregate = fr_current;
        else
            fr_aggregate = logical(fr_current | fr_tmp==1);
        end
        
    end
    filter{j} = fr_aggregate;
end
filter = filter';

% Apply filtering vector to targets
targets_filtered = cell(length(targets),1);
for k=1:length(filter)
    for n=1:length(targets)
        targets_filtered{n}{k,1} = targets{n}{k}(filter{k});        
    end
end

end