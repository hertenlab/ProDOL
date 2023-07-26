function [CellType, incubation_time, concentration, replicate] = conditionsFromString(input)
    
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

    % incubation time
    incubation_time_temp=input;
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
    else
            incubation_time_temp=[];
    end
    incubation_time=incubation_time_temp;

    % concentration
    nMIndex = strfind(input, 'nM');
    if isempty(nMIndex)
        concentration = [];
        replicate = [];
    else
        underscoreIndex = strfind(input, '_');
        Cstart = max(underscoreIndex(underscoreIndex<nMIndex)) + 1;
        Cend = nMIndex - 1;
        conc = input(Cstart:Cend);
        if strfind(conc, ',')
            conc = strrep(conc, ',', '.');
        end
        concentration = str2double(conc);

        % replicate number
        replicate = str2double(input(nMIndex+3:nMIndex+4));
    end
    
end