function fullpath = pathFromConditionsTS(stem, time, celltype, concentration, replicate)

% os dependent file separator
f = filesep;

% incubation time
if time==16
    incubation_time='overnight';
elseif time==0.25
    incubation_time='15min';
elseif time==0.5
    incubation_time='30min';
elseif time==1.0
    incubation_time='60min';
elseif time==3.0
    incubation_time='3h';
else
    incubation_time='';
end

% concentration
concentration = strrep(num2str(concentration), '.', ',');


% construct  subfolder name
%stem,incubation_time,subfolder

maskfolder = [stem,incubation_time,f,celltype,' ',concentration,'nM'];

%subfolder = sprintf('%s %snM',celltype,concentration);

% construct mask file name
file = strcat(celltype,'_',concentration,'nM_',num2str(replicate,'%02.f'),'_mask.tif');

% construct full path to mask
fullpath = fullfile(maskfolder,file);


end