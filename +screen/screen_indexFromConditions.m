function index = indexFromConditions(StringList, CellType, incubation_time, concentration, replicate)
tic
[l, t, c, r] = deal(cell(length(StringList),1));

for i=1:length(StringList)
    String = StringList{i};
    [l{i}, t{i}, c{i}, r{i}] = conditionsFromString(String);
end

matches = find(...
    strcmp(l', CellType) &...
    [t{:}] == incubation_time &...
    [c{:}] == concentration &...
    [r{:}] == replicate);

if length(matches) > 1
    warning('multiple entries from input StringList match input conditions');
    index = [];
elseif isempty(matches)
    warning('no entry from input StringList matches input conditions');
    index = [];
else
    index = matches;
    
end

toc

end
    