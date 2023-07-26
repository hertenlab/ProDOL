function [CellType, dye_combination, dye_load, replicate] = dyes_conditionsFromString(input)
	
    if iscellstr(input)
        for i = 1:length(input)
            myString = input{i};
            [CellType{i}, dye_combination{i}, dye_load{i}, replicate(i)]...
                = stringSearch(myString);
        end
    elseif ischar(input)
        [CellType, dye_combination, dye_load, replicate]...
            = stringSearch(input);
    else
        error('Input Error. Must be string or cell array of strings')
    end
    
end

function [CellType, dye_combination, dye_load, replicate] = stringSearch(input)
    
    % CellType
    if strfind(input, 'LynG')
        CellType = 'LynG';
    elseif strfind(input, 'gSEP')
        CellType = 'gSEP';
    elseif strfind(input, 'wt')
        CellType = 'wt';
    else
        error(sprintf('Couldnt find cell type in string:\n%s\n',input))
    end
    
    % Dye combination
    if strfind(input, 'JF549-HA')
        dye_combination = 'A';
    elseif strfind(input, 'JF549-BG') % typo in foldername for u-track analysis: shold be "JF646-HA", but is "JF646-BG". Searching for JF-549-BG instead.
        dye_combination = 'B';
    elseif strfind(input, 'TMR-HA')
        dye_combination = 'C';
    elseif strfind(input, 'SiR-HA')
        dye_combination = 'D';
    else
        error(sprintf('Couldnt find dye combination string:\n%s\n',input))
    end
    
    % Dye Load
    if strfind(input, 'high')
        dye_load = 'high';
    elseif strfind(input, 'low')
        dye_load = 'low';
    elseif strfind(input, 'no')
        dye_load = 'no';
    else
        error(sprintf('Couldnt find dye load string:\n%s\n',input))
    end

    % replicate number
    underscoreIndex = strfind(input, '_');
    Rend = max(underscoreIndex)-1;
    Rstart = underscoreIndex(end-1) +1;
    replicate = str2double(input(Rstart:Rend));
    
end