% calculate mapping of two sets of coordinates by finding global
% translation values in x and y to align coordinates
%
% details in Thesis of Siegfried Haenselman

function [TranslationX, TranslationY, Flag, SignalStrengthX, SignalStrengthY, peakWidthX, peakWidthY]=SigiRegistrationCells(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2, YCoordinates_Channel_2, ScaleFactorX, ScaleFactorY)

XCoordinates_Channel_2_reg=(XCoordinates_Channel_2-(XCoordinates_Channel_2-256)./256.*ScaleFactorX);
YCoordinates_Channel_2_reg=(YCoordinates_Channel_2-(YCoordinates_Channel_2-256)./256.*ScaleFactorY);

[NearestNeighboursX, NearestNeighboursY]=NearestNeighbourDistance(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2_reg, YCoordinates_Channel_2_reg);

[countx,centerx]=histcounts(NearestNeighboursX,[-4:0.1:4]);
[county,centery]=histcounts(NearestNeighboursY,[-4:0.1:4]);

if ~any(county > 0) || ~any(countx > 0)
    TranslationX = 0;
    TranslationY = 0;
    Flag = 'Registration might not be reliable';
    [SignalStrengthX, SignalStrengthY, peakWidthX, peakWidthY] = deal([]);
    return
end

windowSize = 9; %Averages over a distance of 0.9 pixel
b = (1/windowSize)*ones(1,windowSize);
a=1;
yX = filter(b,a,countx);
yY = filter(b,a,county);

yX = filter(b,a,yX);
yY = filter(b,a,yY);

TranslationX=mean(centerx(find(yX==max(yX))-8));
TranslationY=mean(centery(find(yY==max(yY))-8));

%The sliding avergage calculates the average value from 9 data points on the
%left side (avrg(10)=mean(y(2:10)). This introduces a shift to the right. Going 4 positions to the
%left corrects for that. Going 8 position to the left corrects for two
%consecutive filter steps.

SignalStrengthX=max(yX)/mean(yX(18:end));
SignalStrengthY=max(yY)/mean(yY(18:end));

if max(yX)<6 || max(yY)<6 || SignalStrengthX<1.4 || SignalStrengthY<1.4
%     warning('Registration might not be reliable!');
    Flag='Registration might not be reliable';

else
    Flag='Registration successfull';
end

peakHeightX = (max(yX) + mean(yX(18:end))) / 2;
schnitt = yX - peakHeightX;
[~, indexX] = getNElements(schnitt, 4);
peakWidthX = 0.1 * max(abs(diff(indexX)));

peakHeightY = (max(yY) + mean(yY(18:end))) / 2;
schnitt = yY - peakHeightY;
[~, indexY] = getNElements(schnitt, 4);
peakWidthY = 0.1 * max(abs(diff(indexY)));

end

function [smallestNElements, smallestNIdx] = getNElements(A, n)
     [ASorted, AIdx] = sort(abs(A));
     smallestNElements = ASorted(1:n);
     smallestNIdx = AIdx(1:n);
end
