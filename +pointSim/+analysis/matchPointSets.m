function matches = matchPointSets(ptSetNames, filterStrings)
    
    if ischar(filterStrings)
        filterStrings = {filterStrings};
    end
    testArray = false(length(filterStrings), length(ptSetNames));
    for i = 1:length(filterStrings)
        testArray(i,:) = ~cellfun(@isempty, strfind(ptSetNames, filterStrings{i}));
    end
    matches = ptSetNames(all(testArray,1));
    
end