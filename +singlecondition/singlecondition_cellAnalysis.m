% Filtering amplitud threshold
filterPercentile = [];  % set to [] to skip filtering

% Colocalisation tolerance    
tolerance = (0.1:0.1:4);

% Filter Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
% ToDo: Implement for singlecondition analysis, take a look @
% screen_cellAnalysis for filtering of u-track data!
%%%%%%%%%%%%%%%%%%%%

if ~isempty(filterPercentile)
    
    % Keep unfiltered point amplitudes
    Points_Blue_A_unfiltered = Points_Blue_A;

    % threshold from "unstained" cells (density = 0)
    reference = GroundTruthDensity == 0;
    % apply filtering on all cells
    experiment = true(length(GroundTruthDensity),1);

    [filterThreshold_Blue, Points_Blue_A, Points_Blue_x, Points_Blue_y, Points_Blue_c, Points_Blue_s] = ...
                    filterPointsByPercentile (filterPercentile, reference, experiment, ...
        Points_Blue_A, Points_Blue_x, Points_Blue_y, Points_Blue_c, Points_Blue_s);

end

% Registration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Performing Channel Registration');
MeanScaleFactorXBlueGreen = 0.5523;
MeanScaleFactorYBlueGreen = 0.4909;
MeanScaleFactorXBlueRed = 0.6773;
MeanScaleFactorYBlueRed = 0.5682;

% Calculate Translation for all cells
if chans(1,2)
    [TranslationXBlueGreen, TranslationYBlueGreen, FlagGreen] = ...
        channelRegistration(Points_Blue_x, Points_Blue_y, Points_Green_x, Points_Green_y,...
        MeanScaleFactorXBlueGreen, MeanScaleFactorYBlueGreen);
end

if chans(1,3)
    [TranslationXBlueRed, TranslationYBlueRed, FlagRed] = ...
        channelRegistration(Points_Blue_x, Points_Blue_y, Points_Red_x, Points_Red_y,...
        MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);
end

% Correlate Translation between Red and Green
if chans(1,2) && chans(1,3)
    [TranslationXBlueGreen, TranslationYBlueGreen, TranslationXBlueRed,...
        TranslationYBlueRed, FlagGreen, FlagRed] = correlatedRegistration(...
        TranslationXBlueGreen, TranslationYBlueGreen, TranslationXBlueRed,...
        TranslationYBlueRed, FlagGreen, FlagRed);
end

% Calculate mean Translation from successful registration
if chans(1,2)
    [MeanTranslationXBlueGreen, MeanTranslationYBlueGreen, TranslationXBlueGreen, ...
        TranslationYBlueGreen, FlagGreen] = meanTranslation(...
        TranslationXBlueGreen, TranslationYBlueGreen, FlagGreen);
end

if chans(1,3)
    [MeanTranslationXBlueRed, MeanTranslationYBlueRed, TranslationXBlueRed, ...
        TranslationYBlueRed, FlagRed] = meanTranslation(...
        TranslationXBlueRed, TranslationYBlueRed, FlagRed);
end

% Apply translation
if chans(1,2)
    [Points_GreenReg_x, Points_GreenReg_y] = ...
        applyTranslation(Points_Green_x, Points_Green_y, ...
        TranslationXBlueGreen, TranslationYBlueGreen,...
        MeanScaleFactorXBlueGreen, MeanScaleFactorYBlueGreen);
end
if chans(1,3)
    [Points_RedReg_x, Points_RedReg_y] = ...
        applyTranslation(Points_Red_x, Points_Red_y, ...
        TranslationXBlueRed, TranslationYBlueRed,...
        MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);
end

% Rotate Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if chans(1,1)
    [Points_BlueRot_x, Points_BlueRot_y] = deal(cell(size(Points_Blue_x)));
    for i = 1:length(Points_Blue_x)
        [Points_BlueRot_x, Points_BlueRot_y] = deal(cell(size(Points_Blue_x)));
        Points_BlueRot_x{i} = Points_Blue_y{i};
        Points_BlueRot_y{i} = 512 - Points_Blue_x{i};
    end
end
if chans(1,2)
    [Points_GreenRot_x, Points_GreenRot_y] = deal(cell(size(Points_Green_x)));
    for i = 1:length(Points_Green_x)
        Points_GreenRot_x{i} = Points_Green_y{i};
        Points_GreenRot_y{i} = 512 - Points_Green_x{i};
    end
end
if chans(1,3)
    [Points_RedRot_x, Points_RedRot_y] = deal(cell(size(Points_Red_x)));
    for i = 1:length(Points_Red_x)
        Points_RedRot_x{i} = Points_Red_y{i};
        Points_RedRot_y{i} = 512 - Points_Red_x{i};
    end
end

% Colocalisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Calculate Colocalisation');

% Preallocate Variables
[BlueParticles] = deal(zeros(length(Points_Blue_x),1));
[pBlue, pBlue2] = deal(zeros(length(Points_Blue_x),length(tolerance)));


if chans(1,2)
    [GreenParticles] = deal(zeros(length(Points_Blue_x),1));
    [ColocalizationBlueGreen, pGreen, pGreenRandom, multipleassigned_particlesGreen, ...
        ColocalizationGreenRandom, multipleassigned_particlesGreenRandom] = ...
        deal(zeros(length(Points_Blue_x),length(tolerance)));
end

if chans(1,3)
    [RedParticles] = deal(zeros(length(Points_Blue_x),1));
    [ColocalizationBlueRed, pRed, pRedRandom, multipleassigned_particlesRed, ...
        ColocalizationRedRandom, multipleassigned_particlesRedRandom] = ...
        deal(zeros(length(Points_Blue_x),length(tolerance)));
end

for i = 1:length(Points_Blue_x)
    for t = 1:length(tolerance)
            
        dispProgress(i, length(Points_Blue_x), t, length(tolerance));
        
        if chans(1,3)
            [BlueParticles(i), RedParticles(i), ColocalizationBlueRed(i,t), multipleassigned_particlesRed(i,t)] = ...
                detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
                Points_RedReg_x{i}, Points_RedReg_y{i}, ...
                tolerance(t), tolerance(t));

            [~, ~, ColocalizationRedRandom(i,t),multipleassigned_particlesRedRandom(i,t)] = ...
                detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i},...
                Points_RedRot_x{i}, Points_RedRot_y{i}, ...
                tolerance(t), tolerance(t));

            pBlue2(i,t)=ColocalizationBlueRed(i,t)/RedParticles(i);
            pRed(i,t)=ColocalizationBlueRed(i,t)/BlueParticles(i);
            pRedRandom(i,t)=ColocalizationRedRandom(i,t)/BlueParticles(i);
        end

        if chans(1,2)
            [BlueParticles(i), GreenParticles(i), ColocalizationBlueGreen(i,t),multipleassigned_particlesGreen(i,t)] = ...
                detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
                Points_GreenReg_x{i}, Points_GreenReg_y{i}, ...
                tolerance(t), tolerance(t));

            [~, ~, ColocalizationGreenRandom(i,t),multipleassigned_particlesGreenRandom(i,t)] = ...
                detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
                Points_GreenRot_x{i}, Points_GreenRot_y{i}, ...
                tolerance(t), tolerance(t));

            pBlue(i,t)=ColocalizationBlueGreen(i,t)/GreenParticles(i);
            pGreen(i,t)=ColocalizationBlueGreen(i,t)/BlueParticles(i);
            pGreenRandom(i,t)=ColocalizationGreenRandom(i,t)/BlueParticles(i);
        end
    end  
end