% optional: output of index of input coordinates of colocalizing particles
% additional to number of colocalizing particles. can be useful to
% highlight colocalizing points on merged images

function [particles1, particles2, netColoc, netMulti, totalColoc] = detectColocalisation(X1, Y1, X2, Y2, ToleranceX, ToleranceY)

particles1 = length(X1);
particles2 = length(X2);

% Check input coordinates.
if any(cellfun(@isempty,{X1, Y1, ...
        X2, Y2, ToleranceX, ToleranceY}))
    [netColoc, netMulti, totalColoc] = ...
        deal(zeros(1));
    return
end

% ensure correct orientation
X1 = reshape(X1,length(X1),1);
Y1 = reshape(Y1,length(Y1),1);
X2 = reshape(X2,length(X2),1);
Y2 = reshape(Y2,length(Y2),1);

% calculate distances between points
TotalDistance = pdist2([X2, Y2],[X1, Y1]);

% find distances below threshold
Winners = TotalDistance <= ToleranceX;

% number of colocalisations for points in channel 1 and 2
sumCh1 = sum(Winners,1);
sumCh2 = sum(Winners,2);

% total number of colocalisations
totalColoc = sum(sumCh1);

% colocalising points in channel 1
colocCh1 = nnz(sumCh1);
% colocCh2 = nnz(sumCh2);

% overassignment
overCh1 = sum(sumCh1 - (sumCh1 > 0));
overCh2 = sum(sumCh2 - (sumCh2 > 0));

% multiple assignment correction
% colocalising points in channel 1 reduced by overhead of multiple 
% assignments in channel 2
netColoc = colocCh1 - (overCh1 < overCh2) * (overCh2 - overCh1);
% same result if calculated from channel 2.
% netColocCh2 = colocCh2 - (overCh2 < overCh1) * (overCh1 - overCh2);
netMulti = totalColoc - netColoc;
   
end