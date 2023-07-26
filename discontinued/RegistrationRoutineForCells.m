tic

clear all

movielist=load('x:\Felix\Microscopy\00_Calibration\Huh7.5_TMR-Star_SiR-Halo (Felix)\data\uTrack\movieList all.mat');


%movielist=load('D:\Experimental Data\TIRF\20160628 gSEP LynG uN\AllCells_uN_movieList.mat');
% movielist=load('D:\Experimental Data\TIRF\20160630 gSEP LynG 15min\AllCells_15min_movieList.mat');
%movielist=load('D:\Experimental Data\TIRF\20160705 gSEP LynG 3h\AllCells_3h_movieList.mat');
%movielist=load('D:\Experimental Data\TIRF\20160719 gSEP LynG 1h\AllCells_1h_movieList.mat');
%movielist=load('D:\Experimental Data\TIRF\20160721 gSEP LynG 30min\AllCells_30min_movieList.mat');

%% Mean transformation values for registration
    
MeanTranslationXBlueGreen = 0.0668;
MeanTranslationYBlueGreen = -0.8464;
MeanScaleFactorXBlueGreen = 0.5523;
MeanScaleFactorYBlueGreen = 0.4909;
MeanTranslationXBlueRed = 0.7730;
MeanTranslationYBlueRed = -1.4691;
MeanScaleFactorXBlueRed = 0.6773;
MeanScaleFactorYBlueRed = 0.5682;

%% initialize variables
incubation_time=zeros(length(movielist.ML.movieDataFile_),1);
concentration=zeros(length(movielist.ML.movieDataFile_),1);
replicate=zeros(length(movielist.ML.movieDataFile_),1);
CellType=cell(length(movielist.ML.movieDataFile_),1);

TranslationsXBlueGreen=zeros(length(movielist.ML.movieDataFile_),1);
TranslationsYBlueGreen=zeros(length(movielist.ML.movieDataFile_),1);
TranslationsXBlueRed=zeros(length(movielist.ML.movieDataFile_),1);
TranslationsYBlueRed=zeros(length(movielist.ML.movieDataFile_),1);
FlagGreen=cell(length(movielist.ML.movieDataFile_),1);
FlagRed=cell(length(movielist.ML.movieDataFile_),1);

BlueParticles=zeros(length(movielist.ML.movieDataFile_),1);
GreenParticles=zeros(length(movielist.ML.movieDataFile_),1);
RedParticles=zeros(length(movielist.ML.movieDataFile_),1);
BleachedParticles=zeros(length(movielist.ML.movieDataFile_),1);
ColocalizationBlueGreen=zeros(length(movielist.ML.movieDataFile_),30);
ColocalizationBlueRed=zeros(length(movielist.ML.movieDataFile_),30);
pGreen=zeros(length(movielist.ML.movieDataFile_),30);
pRed=zeros(length(movielist.ML.movieDataFile_),30);
pBlue=zeros(length(movielist.ML.movieDataFile_),30);
pBlue2=zeros(length(movielist.ML.movieDataFile_),30);
pGreenRandom=zeros(length(movielist.ML.movieDataFile_),30);
pRedRandom=zeros(length(movielist.ML.movieDataFile_),30);
multipleassigned_particlesGreen=zeros(length(movielist.ML.movieDataFile_),30);
multipleassigned_particlesRed=zeros(length(movielist.ML.movieDataFile_),30);
ColocalizationRedRandom=zeros(length(movielist.ML.movieDataFile_),30);
ColocalizationGreenRandom=zeros(length(movielist.ML.movieDataFile_),30);
multipleassigned_particlesGreenRandom=zeros(length(movielist.ML.movieDataFile_),30);
multipleassigned_particlesRedRandom=zeros(length(movielist.ML.movieDataFile_),30);


wb = waitbar(0, 'Processing');

result = zeros(length(movielist.ML.movieDataFile_),5);
 

for i=1:length(movielist.ML.movieDataFile_)

time = toc;
remaining = (length(movielist.ML.movieDataFile_) - i) * time / (i * 60);

waitbar(i/length(movielist.ML.movieDataFile_),wb,...
    [num2str(round(100 * i / length(movielist.ML.movieDataFile_),0)) '% ('...
    num2str(i) ' / ' num2str(length(movielist.ML.movieDataFile_)) '). '...
    'Time remaining: ' num2str(round(remaining,0)) ' min']);
    
%% Load data
path = movielist.ML.movieDataFile_{i};

path_channel_1= strrep(path, 'movieData.mat', 'TrackingPackage\point_sources\channel_2.mat'); % blue
path_channel_2= strrep(path, 'movieData.mat', 'TrackingPackage\point_sources\channel_5.mat'); % red
path_channel_3= strrep(path, 'movieData.mat', 'TrackingPackage\point_sources\channel_3.mat'); % green
path_channel_4= strrep(path, 'movieData.mat', 'TrackingPackage\point_sources\channel_1.mat'); % bleached

Channel_1=load(path_channel_1);
Channel_2=load(path_channel_2);
Channel_3=load(path_channel_3);
Channel_4=load(path_channel_4);


%% Get conditions

% CellType
if strfind(movielist.ML.movieDataFile_{i}, 'LynG')
    CellType{i} = 'LynG';
elseif strfind(movielist.ML.movieDataFile_{i}, 'gSEP')
    CellType{i} = 'gSEP';
else
    CellType{i} = '?';
end

% incubation time
incubation_time_temp=movielist.ML.movieDataFile_{i};
if strfind(incubation_time_temp, 'overnight')
    incubation_time_temp=16;
elseif strfind(incubation_time_temp, '15min')
        incubation_time_temp=0.25;
elseif strfind(incubation_time_temp, '30min')
        incubation_time_temp=0.5;
elseif strfind(incubation_time_temp, '60min')
        incubation_time_temp=1;
elseif strfind(incubation_time_temp, '3h')
        incubation_time_temp=3;
end
incubation_time(i)=incubation_time_temp;

% concentration
nMIndex = strfind(movielist.ML.movieDataFile_{i}, 'nM');
underscoreIndex = strfind(movielist.ML.movieDataFile_{i}, '_');
Cstart = max(underscoreIndex(underscoreIndex<nMIndex)) + 1;
Cend = nMIndex - 1;
conc = movielist.ML.movieDataFile_{i}(Cstart:Cend);
if strfind(conc, ',')
    conc = strrep(conc, ',', '.');
end
concentration(i) = str2double(conc);

% replicate number
replicate(i) = str2double(movielist.ML.movieDataFile_{i}(nMIndex+3:nMIndex+4));

%% Check if more than 10 points are detected in every channel

boolX = [isfield(Channel_1.movieInfo, 'x'), isfield(Channel_2.movieInfo, 'x'),...
    isfield(Channel_3.movieInfo, 'x')];

if not(all(boolX))
    warning([num2str(i), ': no points detected in Channel ', num2str([find(not(boolX))])]);
else
    numX = [length(Channel_1.movieInfo.x), length(Channel_2.movieInfo.x),...
        length(Channel_3.movieInfo.x)];
    result(i,1:3) = numX;
    if not(all(numX>10))
        warning([num2str(i), ': less than 10 points detected in Channel ', num2str([find(not(numX>10))])]);
    else
%% Rotate Localisations

BleachedParticles(i)=size(Channel_4.movieInfo.xCoord,1);%number of detected particles after bleaching

XCoordinates_Channel_1=Channel_1.movieInfo.x'; % blue
YCoordinates_Channel_1=Channel_1.movieInfo.y';
XCoordinates_Channel_2=Channel_2.movieInfo.x'; % red
YCoordinates_Channel_2=Channel_2.movieInfo.y';
XCoordinates_Channel_3=Channel_3.movieInfo.x'; % green
YCoordinates_Channel_3=Channel_3.movieInfo.y';

XCoordinates_BlueRotated=YCoordinates_Channel_1; %This is a random colocalization control for eGFP, rotated 90 degrees
YCoordinates_BlueRotated=512-XCoordinates_Channel_1;

XCoordinates_RedRotated=YCoordinates_Channel_2;%This is a random colocalization control for SiR, rotated 90 degrees
YCoordinates_RedRotated=512-XCoordinates_Channel_2;

XCoordinates_GreenRotated=YCoordinates_Channel_3; %This is a random colocalization control for TMR, rotated 90 degrees
YCoordinates_GreenRotated=512-XCoordinates_Channel_3;


%% Registration Red to blue

ScaleFactorXBlueRed = MeanScaleFactorXBlueRed;
ScaleFactorYBlueRed = MeanScaleFactorYBlueRed;

[TranslationX, TranslationY, Flag] = SigiRegistrationCells(...
    XCoordinates_Channel_1, YCoordinates_Channel_1, ...
    XCoordinates_Channel_2, YCoordinates_Channel_2, ...
    ScaleFactorXBlueRed, ScaleFactorYBlueRed);

if strcmp(Flag,'Registration might not be reliable')
        
    TranslationXBlueRed = MeanTranslationXBlueRed;
    TranslationYBlueRed = MeanTranslationYBlueRed;
    FlagRed{i}='Warning: mean Values used';
    
    TranslationXBlueGreen = MeanTranslationXBlueGreen;
    TranslationYBlueGreen = MeanTranslationYBlueGreen;
    ScaleFactorXBlueGreen = MeanScaleFactorXBlueGreen;
    ScaleFactorYBlueGreen = MeanScaleFactorYBlueGreen;
    FlagGreen{i}='Warning: mean Values used';

elseif strcmp(Flag,'Registration successfull')
    
    result(i,4) = 1;

    TranslationXBlueRed = TranslationX;
    TranslationYBlueRed = TranslationY;
    FlagRed{i}='successfull registration';

%% Registration Green to blue
    clear TranslationX TranslationY Flag
    ScaleFactorXBlueGreen = MeanScaleFactorXBlueGreen;
    ScaleFactorYBlueGreen = MeanScaleFactorYBlueGreen;
    
    % Registration Green to blue
    [TranslationX, TranslationY, Flag] = SigiRegistrationCells(...
        XCoordinates_Channel_1, YCoordinates_Channel_1, ...
        XCoordinates_Channel_3, YCoordinates_Channel_3, ...
        ScaleFactorXBlueGreen, ScaleFactorYBlueGreen);

    if strcmp(Flag,'Registration might not be reliable')
        
        % derive the red->blue registration from known correlation with green->blue registration   
%         TranslationXBlueRed = 1.41*TranslationXBlueGreen-0.18;
%         TranslationYBlueRed = 1.09*TranslationYBlueGreen-0.26; 
        TranslationXBlueGreen = (TranslationXBlueRed + 0.18) / 1.41;
        TranslationYBlueGreen = (TranslationYBlueRed + 0.26 ) / 1.09;
        FlagGreen{i} = 'derived from correlation';
            
    elseif strcmp(Flag,'Registration successfull')
            
        result(i,5) = 1;
        
        TranslationXBlueGreen = TranslationX;
        TranslationYBlueGreen = TranslationY;
        FlagGreen{i}='successfull registration';
            
    else
        error('no valid flag for registration of red channel')
    end      
else
    error('no valid flag for registration of green channel')
end
        
clear TranslationX TranslationY Flag        



%% Apply parameters
XCoordinates_Channel_2_reg=(XCoordinates_Channel_3-(XCoordinates_Channel_3-256)./256.*ScaleFactorXBlueRed)+TranslationXBlueRed; %red
YCoordinates_Channel_2_reg=(YCoordinates_Channel_3-(YCoordinates_Channel_3-256)./256.*ScaleFactorYBlueRed)+TranslationYBlueRed;
XCoordinates_Channel_3_reg=(XCoordinates_Channel_2-(XCoordinates_Channel_2-256)./256.*ScaleFactorXBlueGreen)+TranslationXBlueGreen; %green
YCoordinates_Channel_3_reg=(YCoordinates_Channel_2-(YCoordinates_Channel_2-256)./256.*ScaleFactorYBlueGreen)+TranslationYBlueGreen;

TranslationsXBlueGreen(i)=TranslationXBlueGreen;
TranslationsYBlueGreen(i)=TranslationYBlueGreen;
TranslationsXBlueRed(i)=TranslationXBlueRed;
TranslationsYBlueRed(i)=TranslationYBlueRed;
%% Calculate degree of colocalization for registered channels with defined tolerance


% ToleranceBlueGreenX=1;
% ToleranceBlueGreenY=1;
% 
% ToleranceBlueRedX=1.5;
% ToleranceBlueRedY=1.5;
% 
% 
% [BlueParticles(i), GreenParticles(i), ColocalizationBlueGreen(i),multipleassigned_particlesGreen(i)]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2_reg, YCoordinates_Channel_2_reg, ToleranceBlueGreenX, ToleranceBlueGreenY);
% %[BlueParticles, GreenParticles, ColocalizationBlueGreen]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2rnd, YCoordinates_Channel_2rnd, ToleranceX, ToleranceY)
% 
% [~, RedParticles(i), ColocalizationBlueRed(i),multipleassigned_particlesRed(i)]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3_reg, YCoordinates_Channel_3_reg, ToleranceBlueRedX, ToleranceBlueRedY);
% %[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)
% 
% [~, ~, ColocalizationGreenRandom(i),multipleassigned_particlesGreenRandom(i)]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_GreenRotated, YCoordinates_GreenRotated, ToleranceBlueGreenX, ToleranceBlueGreenY);
% %[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)
% 
% [~, ~, ColocalizationRedRandom(i),multipleassigned_particlesRedRandom(i)]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_RedRotated, YCoordinates_RedRotated, ToleranceBlueRedX, ToleranceBlueRedY);
% %[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)
% 
% 
% 
% 
% pGreen(i)=ColocalizationBlueGreen(i)/BlueParticles(i);
% pRed(i)=ColocalizationBlueRed(i)/BlueParticles(i);
% 
% pGreenRandom(i)=ColocalizationGreenRandom(i)/BlueParticles(i);
% pRedRandom(i)=ColocalizationRedRandom(i)/BlueParticles(i);
% end


%% Calculate degree of colocalization for registered channels with varying tolerance

j=0;
for k=0.1:0.1:4
ToleranceBlueGreenX=k;
ToleranceBlueGreenY=k;

ToleranceBlueRedX=k;
ToleranceBlueRedY=k;

j=j+1;
tic
[BlueParticles(i), RedParticles(i), ColocalizationBlueRed(i,j), multipleassigned_particlesRed(i,j)] = ...
    detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, ...
    XCoordinates_Channel_2_reg, YCoordinates_Channel_2_reg, ...
    ToleranceBlueGreenX, ToleranceBlueGreenY);
%[BlueParticles, GreenParticles, ColocalizationBlueGreen]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_2rnd, YCoordinates_Channel_2rnd, ToleranceX, ToleranceY)
toc
[~, GreenParticles(i), ColocalizationBlueGreen(i,j),multipleassigned_particlesGreen(i,j)] = ...
    detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1,...
    XCoordinates_Channel_3_reg, YCoordinates_Channel_3_reg, ...
    ToleranceBlueRedX, ToleranceBlueRedY);
%[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)
toc
[~, ~, ColocalizationGreenRandom(i,j),multipleassigned_particlesGreenRandom(i,j)] = ...
    detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, ...
    XCoordinates_GreenRotated, YCoordinates_GreenRotated, ...
    ToleranceBlueGreenX, ToleranceBlueGreenY);
%[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)
toc
[~, ~, ColocalizationRedRandom(i,j),multipleassigned_particlesRedRandom(i,j)] = ...
    detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1,...
    XCoordinates_RedRotated, YCoordinates_RedRotated,...
    ToleranceBlueRedX, ToleranceBlueRedY);
%[BlueParticles, RedParticles, ColocalizationBlueRed]=detectColocalisation(XCoordinates_Channel_1, YCoordinates_Channel_1, XCoordinates_Channel_3rnd, YCoordinates_Channel_3rnd, ToleranceX, ToleranceY)



pBlue(i,j)=ColocalizationBlueGreen(i,j)/GreenParticles(i);
pGreen(i,j)=ColocalizationBlueGreen(i,j)/BlueParticles(i);
pRed(i,j)=ColocalizationBlueRed(i,j)/BlueParticles(i);
pBlue2(i,j)=ColocalizationBlueRed(i,j)/RedParticles(i);


pGreenRandom(i,j)=ColocalizationGreenRandom(i,j)/BlueParticles(i);
pRedRandom(i,j)=ColocalizationRedRandom(i,j)/BlueParticles(i);
toc
end

    end
end
end
summary = struct('CellType',CellType,'incubation_time',num2cell(incubation_time),...
    'concentration',num2cell(concentration),'replicate',num2cell(replicate),...
    'points_Ch1',num2cell(result(:,1)),'points_Ch2',num2cell(result(:,2)),...
    'points_Ch3',num2cell(result(:,3)),'Reg_Red2Blue',num2cell(result(:,4)),...
    'Reg_Green2Blue',num2cell(result(:,5)));
toc
close(wb);

uisave;
