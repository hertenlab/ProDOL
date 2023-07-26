function [CellType, dye_combination, dye_load, replicate] = conditionsFromStringJF(input)
    input
    % CellType
    if strfind(input, 'LynG')
        CellType = 'LynG';
    elseif strfind(input, 'gSEP')
        CellType = 'gSEP';
    elseif strfind(input, 'wt')
        CellType = 'wt';
    else
        CellType = '';
    end
    
    % Dye combination
    if strfind(input, 'JF549-HA')
        dye_combination = 'A';
    elseif strfind(input, 'JF646-HA')
        dye_combination = 'B';
    elseif strfind(input, 'TMR-HA')
        dye_combination = 'C';
    elseif strfind(input, 'SiR-HA')
        dye_combination = 'D';
    else
        dye_combination = '';
    end
    
    % Dye Load
    if strfind(input, 'high')
        dye_load = 'high';
    elseif strfind(input, 'low')
        dye_load = 'low';
    elseif strfind(input, 'no')
        dye_load = 'no';
    else
        dye_load = '';
    end

    % replicate number
    underscoreIndex = strfind(input, '_');
    Rend = max(underscoreIndex)-1;
    Rstart = underscoreIndex(end-1) +1;
    replicate = str2double(input(Rstart:Rend));
    
end