% Normalise Values for each cell to a certain mean value
% e.g. normalise point density for all cells to mean value in unstained
% cells grouped by cell type (gSEP/LynG) and incubation time (grouper)

for i = 1:length(CellType)
    grouper{i} = [CellType{i} dye_combination{i}];
end

Density_Green_rel = relativeBadabum(Density_Green, grouper, concentration, 0);
Density_Red_rel = relativeBadabum(Density_Red, grouper, concentration, 0);
Density_Blue_rel = relativeBadabum(Density_Blue, grouper, concentration, 0);
pGreen_rel = relativeBadabum(pGreen, grouper, concentration, 0);
pRed_rel = relativeBadabum(pRed, grouper, concentration, 0);

function relDens = relativeBadabum(meanDensity, groupingVariable, referenceVariable, referenceProperty)

group = findgroups(groupingVariable);
groups = unique(group);

for i = 1:length(groups)
    
    index = group == groups(i);
    
    referenceValue = mean(meanDensity(index' & referenceVariable == referenceProperty));
        
    relDens(index) = meanDensity(index) ./ referenceValue;
    
end

end