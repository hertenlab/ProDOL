%% load data
if (exist('beadsImageSets', 'var') ~=1) || isempty(beadsImageSets)
    loadPath = 'y:\DOL Calibration\Data\beads-control\intensity_screen2\analysis\beadsImageSets_thunderSTORM-multi.mat';
    load(loadPath);
end

%%
redName = 'thunderStorm multi red fltr sigma';
greenName = 'thunderStorm multi green fltr sigma';
blueName = 'thunderStorm multi blue fltr sigma';
mySet = beadsImageSets(7);
myImg = mySet.childImages(5);

%% show image overlays and points

ROI = [216 288; 166 238]; % starts in top left corner
width = ROI(1,2) - ROI(1,1);
height = ROI(2,2) - ROI(2,1);

figure(1)
beads.showImage(myImg, [1 0 1 0 0], [])
rectangle('Position', [ROI(1,1), ROI(2,1), width, height], 'EdgeColor', 'w');

figure(2)
beads.showImage(myImg, [0 0 1 0 0], blueName)
xlim(ROI(1,:))
ylim(ROI(2,:))

figure(3)
beads.showImage(myImg, [1 0 0 0 0], redName)
xlim(ROI(1,:))
ylim(ROI(2,:))

figure(4)
beads.showImage(myImg, [0 0 0 0 0], {[redName ' registered'], [blueName ' registered']})
xlim(ROI(1,:))
ylim(ROI(2,:))
legend('hide')

figure(5)
beads.showImage(myImg, [0 0 0 0 0], {redName, [blueName ' rotated']})
xlim(ROI(1,:))
ylim(ROI(2,:))
legend('hide')

%% nearest neighbor distance histogram

blueSet = myImg.pointSetByName(blueName);
redSet = myImg.pointSetByName(redName);

dist = pdist2(blueSet.getAllPositions('registered'), redSet.getAllPositions('registered'));
nnd = min(dist, [], 1);

distRot = pdist2(blueSet.getAllPositions('rotated'), redSet.getAllPositions('registered'));
nndRot = min(distRot, [], 1);

figure(6)
cla
histogram(nnd, 'BinWidth', 1, 'Normalization', 'probability')
hold on
histogram(nndRot, 'BinWidth', 1, 'Normalization', 'probability')
legend('original', 'rotated')
xlim([-.5 20.5])
xlabel('nearest neighbor distance / px')
ylim([0 1])
ylabel('probability')

%% plot significant distance threshold

% calculate mean DOL all input imageset
% determine significant distance threshold
allImages = [mySet.childImages];
firstDolans = [allImages(1).results];
thresholds = unique([firstDolans.parameter]);
[dolValues, randomValues, multiValues] = deal(...
    zeros(length(allImages),length(thresholds)));

for i = 1:length(allImages)
    mci = allImages(i);
    allDolans = mci.results;
    dolDolan = allDolans.dolanByVars('basePointSet', mci.pointSetByName(redName), ...
        'targetPointSet', mci.pointSetByName(blueName),...
        'varName', 'DOL over threshold');
    dolValues(i,:) = [dolDolan.value];
    randomDolan = allDolans.dolanByVars('basePointSet', mci.pointSetByName(redName), ...
        'targetPointSet', mci.pointSetByName(blueName),...
        'varName', 'DOL-Random over threshold');
    randomValues(i,:) = [randomDolan.value];
    multiDolan = allDolans.dolanByVars('basePointSet', mci.pointSetByName(redName), ...
        'targetPointSet', mci.pointSetByName(blueName),...
        'varName', 'multi-assignments over threshold');
    numPoints = length(mci.pointSetByName(redName).points);
    multiValues(i,:) = [multiDolan.value] / numPoints;
end

meanCol = nanmean(dolValues,1);
meanColRandom = nanmean(randomValues,1);
meanMulti = nanmean(multiValues,1);

figure(8)
yyaxis('left')
cla
hold on
lh(1) = plot(thresholds, meanCol/max(meanCol)-meanColRandom/max(meanColRandom));
lh(2) = plot(thresholds, meanCol);
lh(3) = plot(thresholds, meanColRandom);
legend('specific', 'original', 'rotated');
xlim([0 4])
xticks([0 1 2 3 4])
xlabel('distance threshold / px')
ylabel('normalized colocalisation')
yticks([0 .25 .5 .75 1])
yyaxis('right')
cla
lh(4) = plot(thresholds, meanMulti/numPoints);
ylim([0 5*10^-4])
% yticks(10^-3 * [0 .25 .5 .75 1])
ylabel('multi-assignments per point')
[lh.LineWidth] = deal(2);

%% barplot dol & dol random
bases = {greenName, redName, redName};
targets = {blueName, greenName, blueName};
for i = 1:3
    [coloc(i), colocErr(i), ~, ~, Ieff] = mySet.resultByName('mean DOL', bases{i}, targets{i});
    [colocRandom(i), colocRandomErr(i)] = mySet.resultByName('mean DOL Random', bases{i}, targets{i});
end

values = [coloc; colocRandom]';
errors = [colocErr; colocRandomErr]';

figure(10)
cla
centers = 1:size(values,1);
hBar = bar(centers, values, 0.9, 'FaceColor', [.7 .7 .7]);

errorX = [centers; centers]';
pause(0.1)
for i = 1:size(values,2)
    errorX(:,i) = bsxfun(@plus, hBar(1).XData, [hBar(i).XOffset]);
end
hold on
errorbar(errorX, values, errors, '.k')
xticklabels({'blue to green' 'green to red' 'blue to red'})
ylabel('degree of colocalisation')
yticks([0 .25 .5 .75 1])

table(bases', targets', coloc', colocErr', colocRandom', colocRandomErr', 'VariableNames', {'base', 'target', 'coloc', 'deltaColoc', 'colocRotated', 'deltaColocRotated'})