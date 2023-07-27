% This function calculates the distance between nearest neighbours in X and Y direction
% 
% Input: X and Y Coordinates of particles from two channels
% 
% Output: An Array of distances between nearest neighbour in X and Y direction
% 


function [NearestNeighboursX, NearestNeighboursY]=NearestNeighbourDistance(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2, YCoordinates_Channel_2)

reshape(XCoordinates_Channel_1, [length(XCoordinates_Channel_1),1]);
reshape(YCoordinates_Channel_1, [length(YCoordinates_Channel_1),1]);
reshape(XCoordinates_Channel_2, [length(XCoordinates_Channel_2),1]);
reshape(YCoordinates_Channel_2, [length(YCoordinates_Channel_2),1]);

[xch1,xch2]=meshgrid(XCoordinates_Channel_1,XCoordinates_Channel_2); 
[ych1,ych2]=meshgrid(YCoordinates_Channel_1,YCoordinates_Channel_2); 

DiffMatrixX=xch1-xch2; 
DiffMatrixY=ych1-ych2;

TotalDistance=sqrt(DiffMatrixX.^2+DiffMatrixY.^2);

% Choose the channel with fewer particles, then go particle by particle and look for the smallest
% distance to particles in the other channel. Extract Distance in X and Y for the nearest Neighbour


if size(TotalDistance,2)< size(TotalDistance,1)

    for particle=1:size(TotalDistance,2)

        [X,~]=find(TotalDistance(:,particle)==min(abs(TotalDistance(:,particle))));

        NearestNeighboursX(particle)=DiffMatrixX(X,particle);
        NearestNeighboursY(particle)=DiffMatrixY(X,particle);     
    end

else
    for particle=1:size(TotalDistance,1)

        [~,X]=find(TotalDistance(particle,:)==min(abs(TotalDistance(particle,:))));

        NearestNeighboursX(particle)=DiffMatrixX(particle,X);
        NearestNeighboursY(particle)=DiffMatrixY(particle,X);     
    end
    
end
end

