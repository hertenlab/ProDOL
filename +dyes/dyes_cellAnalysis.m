% Colocalisation tolerance    
tolerance = (0.1:0.1:4);
filterPercentile = 90;  % set to [] to skip filtering
filterThreshold = [];  % set to [] to skip filtering


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Filter Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% blue channel
if ~isempty(filterThreshold)
    
    [Points_Blue_A, Points_Blue_x, Points_Blue_y, Points_Blue_s, Points_Blue_c] = ...
        filterPointsByThreshold(filterThreshold, Points_Blue_A, ...
        Points_Blue_x, Points_Blue_y, Points_Blue_s, Points_Blue_c);
    
end

% red and green channel
if ~isempty(filterPercentile)

    combis = {'A' 'B' 'C' 'D'};
    Cells = {'gSEP', 'LynG'};
    
    length([Points_Green_A{:}])

    for l = 1:length(Cells)

        for c = 1:length(combis)

            dispProgress(l, length(Cells), c, length(combis))
            
            experiment = strcmp(CellType, Cells{l}) & strcmp(dye_combination, combis(c));
            reference = experiment & strcmp(dye_load, 'no');

            [filterThreshold_Green(l,c), Points_Green_A, Points_Green_x, Points_Green_y, Points_Green_s, Points_Green_c] = ...
                filterPointsByPercentile (filterPercentile, reference, experiment, Points_Green_A, ...
                Points_Green_x, Points_Green_y, Points_Green_s, Points_Green_c);

            [filterThreshold_Red(l,c), Points_Red_A, Points_Red_x, Points_Red_y, Points_Red_s, Points_Red_c] = ...
                filterPointsByPercentile (filterPercentile, reference, experiment, Points_Red_A, ...
                Points_Red_x, Points_Red_y, Points_Red_s, Points_Red_c);

        end

    end

end


% Registration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


MeanScaleFactorXBlueGreen = 0.5523;
MeanScaleFactorYBlueGreen = 0.4909;
MeanScaleFactorXBlueRed = 0.6773;
MeanScaleFactorYBlueRed = 0.5682;

% Calculate Translation for all cells
[TranslationXBlueGreen, TranslationYBlueGreen, FlagGreen] = ...
    channelRegistration(Points_Blue_x, Points_Blue_y, Points_Green_x, Points_Green_y,...
    MeanScaleFactorXBlueGreen, MeanScaleFactorYBlueGreen);

[TranslationXBlueRed, TranslationYBlueRed, FlagRed] = ...
    channelRegistration(Points_Blue_x, Points_Blue_y, Points_Red_x, Points_Red_y,...
    MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);

% Correlate Translation between Red and Green
[TranslationXBlueGreen, TranslationYBlueGreen, TranslationXBlueRed,...
    TranslationYBlueRed, FlagGreen, FlagRed] = correlatedRegistration(...
    TranslationXBlueGreen, TranslationYBlueGreen, TranslationXBlueRed,...
    TranslationYBlueRed, FlagGreen, FlagRed);

% Calculate mean Translation from successful registration
[MeanTranslationXBlueGreen, MeanTranslationYBlueGreen, TranslationXBlueGreen, ...
    TranslationYBlueGreen, FlagGreen] = meanTranslation(...
    TranslationXBlueGreen, TranslationYBlueGreen, FlagGreen);
[MeanTranslationXBlueRed, MeanTranslationYBlueRed, TranslationXBlueRed, ...
    TranslationYBlueRed, FlagRed] = meanTranslation(...
    TranslationXBlueRed, TranslationYBlueRed, FlagRed);

% Apply translation
[Points_GreenReg_x, Points_GreenReg_y] = ...
    applyTranslation(Points_Green_x, Points_Green_y, ...
    TranslationXBlueGreen, TranslationYBlueGreen,...
    MeanScaleFactorXBlueGreen, MeanScaleFactorYBlueGreen);
[Points_RedReg_x, Points_RedReg_y] = ...
    applyTranslation(Points_Red_x, Points_Red_y, ...
    TranslationXBlueRed, TranslationYBlueRed,...
    MeanScaleFactorXBlueRed, MeanScaleFactorYBlueRed);


% Rotate Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Preallocate Variables
[Points_BlueRot_x, Points_BlueRot_y, Points_GreenRot_x, Points_GreenRot_y,...
    Points_RedRot_x, Points_RedRot_y] = deal(cell(size(Points_Blue_x)));

for i = 1:length(Points_Blue_x)
    Points_BlueRot_x{i} = Points_Blue_y{i};
    Points_BlueRot_y{i} = 512 - Points_Blue_x{i};
    Points_GreenRot_x{i} = Points_Green_y{i};
    Points_GreenRot_y{i} = 512 - Points_Green_x{i};
    Points_RedRot_x{i} = Points_Red_y{i};
    Points_RedRot_y{i} = 512 - Points_Red_x{i};
end


% Colocalisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Preallocate Variables
[BlueParticles, GreenParticles, RedParticles, BleachedParticles]...
    = deal(zeros(length(Points_Blue_x),1));

[ColocalizationBlueGreen, ColocalizationBlueRed, pGreen, pRed, pBlue,...
    pBlue2, pGreenRandom, pRedRandom, multipleassigned_particlesGreen,...
    multipleassigned_particlesRed, ColocalizationRedRandom, ...
    ColocalizationGreenRandom, multipleassigned_particlesGreenRandom,...
    multipleassigned_particlesRedRandom]...
    = deal(zeros(length(Points_Blue_x),length(tolerance)));

for t = 1:length(tolerance)
    dispProgress(t, length(tolerance))
    
    % parallelized detection of colocalisation, temporal assignment to xxxT
    % variables
    [ColocalizationBlueRedT, multipleassigned_particlesRedT, ColocalizationRedRandomT, ...
        multipleassigned_particlesRedRandomT, ColocalizationBlueGreenT, ...
        multipleassigned_particlesGreenT, ColocalizationGreenRandomT, ...
        multipleassigned_particlesGreenRandomT] = deal(zeros(length(Points_Blue_x),1));
    toleranceT = tolerance(t);
    
    parfor i = 1:length(Points_Blue_x)
        [BlueParticles(i), RedParticles(i), ColocalizationBlueRedT(i), multipleassigned_particlesRedT(i)] = ...
            detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
            Points_RedReg_x{i}, Points_RedReg_y{i}, ...
            toleranceT, toleranceT);

        [~, ~, ColocalizationRedRandomT(i),multipleassigned_particlesRedRandomT(i)] = ...
            detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i},...
            Points_RedRot_x{i}, Points_RedRot_y{i}, ...
            toleranceT, toleranceT);


        [~, GreenParticles(i), ColocalizationBlueGreenT(i),multipleassigned_particlesGreenT(i)] = ...
            detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
            Points_GreenReg_x{i}, Points_GreenReg_y{i}, ...
            toleranceT, toleranceT);

        [~, ~, ColocalizationGreenRandomT(i),multipleassigned_particlesGreenRandomT(i)] = ...
            detectColocalisation(Points_Blue_x{i}, Points_Blue_y{i}, ...
            Points_GreenRot_x{i}, Points_GreenRot_y{i}, ...
            toleranceT, toleranceT);
    end
    
    ColocalizationBlueRed(:,t) = ColocalizationBlueRedT;
    multipleassigned_particlesRed(:,t) = multipleassigned_particlesRedT;
    ColocalizationRedRandom(:,t) = ColocalizationRedRandomT;
    multipleassigned_particlesRedRandom(:,t) = multipleassigned_particlesRedRandomT;
    pBlue2(:,t) = ColocalizationBlueRedT ./ RedParticles;
    pRed(:,t) = ColocalizationBlueRedT ./ BlueParticles;
    pRedRandom(:,t) = ColocalizationRedRandomT ./ BlueParticles;
    
    ColocalizationBlueGreen(:,t) = ColocalizationBlueGreenT;
    multipleassigned_particlesGreen(:,t) = multipleassigned_particlesGreenT;
    ColocalizationGreenRandom(:,t) = ColocalizationGreenRandomT;
    multipleassigned_particlesGreenRandom(:,t) = multipleassigned_particlesGreenRandomT;
    pBlue(:,t) = ColocalizationBlueGreenT ./ GreenParticles;
    pGreen(:,t) = ColocalizationBlueGreenT ./ BlueParticles;
    pGreenRandom(:,t) = ColocalizationGreenRandomT ./ BlueParticles;
end
