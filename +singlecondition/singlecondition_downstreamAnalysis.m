
valid = true(length(replicate),1);

% Calculate Densities
%pixelSize = 0.096; % in �m
DensityRed = RedParticles ./ (AllAreas * pixelSize^2);
DensityBlue = BlueParticles ./ (AllAreas * pixelSize^2);

% Define Recall and false positives
finalThreshold = colocalisationThreshold(ColocalizationBlueRed, ColocalizationRedRandom, tolerance,'plot');
%{
Recall = pBlue(:,tolerance == finalThreshold);

ColocParticles = ColocalizationBlueGreen(:,tolerance == finalThreshold);
FalsePos = BlueParticles - ColocParticles;
Points_Blue_A_unfiltered = Points_Blue_A;
FalsePosUnfiltered = (cellfun(@length,Points_Blue_A_unfiltered)) - ColocParticles;
DensityFalsePos = FalsePos ./ (AllAreas * pixelSize^2);
DensityFalsePosUnfiltered = FalsePosUnfiltered ./ (AllAreas * pixelSize^2);

% Mean values and stddev
[groups, densityID] = findgroups(GroundTruthDensity);

data = meanAndStd(valid, groups, ...
        Recall, FalsePos, FalsePosUnfiltered,...
        DensityBlue, DensityGreen, DensityFalsePos, DensityFalsePosUnfiltered);
data.numCells = splitapply(@length,groups,groups);
data.ID = struct('GroundTruthDensity', densityID);

%}