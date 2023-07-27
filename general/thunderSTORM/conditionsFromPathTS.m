function [time, celltype, concentration, replicate, channel, fittype, threshold] = conditionsFromPathTS(file)

% make sure fileparst works with / or \ as filesep independent of OS
if isempty(strfind(file,filesep))
    if strfind(file,'/')>0
        file = strrep(file,'/','\');
    elseif strfind(file,'\')>0
        file = strrep(file,'\','/');
    end
end

[filepath, name, ~] = fileparts(file);

% identify cell type
if strfind(name,'gSEP')
    celltype = 'gSEP';
elseif strfind(name,'LynG')
    celltype = 'LynG';
elseif strfind(name, 'fullImage')
    celltype = 'Sims';
elseif strfind(name, 'beads')
    celltype = 'Beads';
elseif strfind(name,'wt_')
    celltype = 'wt';
else
    celltype = '';
end

switch celltype
    % cell screen experiments
    case {'gSEP', 'LynG','wt'}
        % incubation time
        if strfind(filepath, 'overnight')
            time = 16;
        elseif strfind(filepath, '15min')
            time = 0.25;
        elseif strfind(filepath, '30min')
            time = 0.5;
        elseif strfind(filepath, '60min')
            time = 1;
        elseif strfind(filepath, '3h')
            time = 3;
        else
            time = [];
        end
        % concentration and replicate
        usidx = strfind(name, '_');
      
        concentration = [];
        replicate = [];
        concIndex = [];
        
        if contains(name,'unstained')
            concentration = 0;
            replicate = str2num(name(usidx(end-1)+1:usidx(end)-1));
        else
            if contains(name, 'nM_')
                concIndex = strfind(name,'nM_');
            elseif contains(name,'uM_')
                concIndex = strfind(name, 'uM_');
            end
        end
        
        if ~isempty(concIndex)
            Cstart = max(usidx(usidx<concIndex)) + 1;
            Cend = concIndex - 1;
            concentration = str2double(strrep(name(Cstart:Cend), ',', '.'));
            
            % replicate number for gSEP/LynG data
            replicate = str2double(name(concIndex+3:concIndex+4));
        end
    
    % Simulations: property 'simulated density' in 'concentration' output
    % variable
    case 'Sims'
        dashindex = strfind(name, '-');
        % for simulations with varying density, use concentration property
        % to store density
        if length(dashindex)==1
            concentration = str2double(strrep(name(dashindex-1:dashindex+1),'-','.'));
            % replicate number for gSEP/LynG data
            replicate = str2double(name(dashindex+3:dashindex+4));
            time = [];
        % for simulations with varying density + DOL, use concentration to
        % store density and incubation_time to story nominal DOL
        elseif length(dashindex)==2
            concentration = str2double(strrep(name(dashindex(1)-1:dashindex(1)+1),'-','.'));
            time = str2double(strrep(name(dashindex(2)-1:dashindex(2)+2),'-','.'));
            replicate = str2double(strrep(name(dashindex(2)+4:dashindex(2)+5),'-','.'));
            %
        else
            concentration = [];
            replicate = [];
            time = [];
        end
    % Beads: property 'nd filter' in 'time' output and 'laser intensity' in
    % 'concentration output variable
    case 'Beads'
        usidx = strfind(name, '_');
        nd = str2num(name(usidx(1)+3:usidx(2)-1));
        laserStartIdx = usidx(2) + 1;
        laserEndIdx = usidx(3) - 1;
        laserIntensity = str2num(strrep(name(laserStartIdx:laserEndIdx), '-', '.'));
        replicate = str2num(name(usidx(3)+1:usidx(3)+2));
        time = nd;
        concentration = laserIntensity;
    otherwise
        [time, concentration, replicate] = deal([]);
end
        
% fittype
if strfind(filepath,'multiemitter')
    fittype = 'multi';
elseif strfind(filepath,'singleemitter')
    fittype = 'single';
else
    if strfind(name,'multiemitter')
        fittype = 'multi';
    elseif strfind(name,'singleemitter')
        fittype = 'single';
    else
        fittype = [];
    end
end

% channel
if strfind(name,'blue')
    channel = 'blue';
elseif strfind(name,'greenBleach')
    channel = 'greenbleach';
elseif strfind(name,'green')
    channel = 'green';
elseif strfind(name,'red')
    channel = 'red';
else
    channel = [];
end

% threshold
thresIndex = strfind(name,'thres');
if isempty(thresIndex)
    threshold = [];
else
    threshold = name(thresIndex+6:end);
end

end