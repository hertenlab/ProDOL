% This function adjusts the number of detected particles in two spectral
% channels, that need to be broadly prealligned. particles with no or multiple partner
% particles in the other channel are removed.
% 
% Input: X and Y Coordinates of particles from two channels
% 
% Output: Coordinates [X Y] of partner particles in both channels.
% ValidCh1=[X Y]
% ValidCh2=[X Y]
% 


function [ValidCh1, ValidCh2] = RegPreFilter(X1, Y1, X2, Y2, DistanceThreshold)

% ensure correct orientation
X1 = reshape(X1,length(X1),1);
Y1 = reshape(Y1,length(Y1),1);
X2 = reshape(X2,length(X2),1);
Y2 = reshape(Y2,length(Y2),1);

% calculate distances between points
TotalDistance = pdist2([X2, Y2],[X1, Y1]);

Partner = TotalDistance < DistanceThreshold; %Particle pairs with a distance below threshold

[Ch1,Ch2] = find(Partner); %IDs of partners

ValidPair=[];

for pair=1:size(Ch1) %Loop all partners
    if nnz(Partner(:,Ch2(pair)))==1 && nnz(Partner(Ch1(pair),:))==1 %Store only particle pairs with ONE unique partner
        ValidPair = [ValidPair;Ch1(pair) Ch2(pair)];        
    end
end
    
% Return Coordinates of valid particle pairs
if isempty(ValidPair)
    ValidCh1 = [];
    ValidCh2 = [];
else
    ValidCh1 = [X1(ValidPair(:,2)) Y1(ValidPair(:,2))];
    ValidCh2 = [X2(ValidPair(:,1)) Y2(ValidPair(:,1))];
end
    
% figure()
% hold on
% scatter(ValidCh1(:,1),ValidCh1(:,2),'g')
% scatter(ValidCh2(:,1),ValidCh2(:,2),'r')
    
end

