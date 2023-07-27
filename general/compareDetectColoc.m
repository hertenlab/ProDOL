% compare detectColocalisation

idx = [1:300];

for j = 1:length(idx)

    i = idx(j);
    XCoordinates_Channel_1 = Points_Blue_x{i};
    YCoordinates_Channel_1 = Points_Blue_y{i};
    XCoordinates_Channel_2 = Points_Green_x{i};
    YCoordinates_Channel_2 = Points_Green_y{i};
    
    tic
    [~, ~, netColocNew(j), netMultiNew(j), totalColocNew(j)] = ...
        detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2, YCoordinates_Channel_2, 2, 2);
    timeNew(j) = toc;
    
    tic
    [~, ~, netColocOld(j), netMultiOld(j), totalColocOld(j)] = ...
        detectColocalisation_backup(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2, YCoordinates_Channel_2, 2, 2);
    timeOld(j) = toc;
    
end

mean(timeOld) / mean(timeNew)