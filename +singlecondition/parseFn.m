function descriptors = parseFn(fn,sep,ids)

% verify inputs
if contains(fn,sep) & isstruct(ids) & numel(fieldnames(ids))==numel(strfind(fn,sep))+1
    
else
        error('check inputs')
end
  
sepIdx = [1 strfind(fn,sep)+1 size(fn,2)+2];
fields = fieldnames(ids);
descriptors=ids;

% parse filename according to order in ids
for i=1:numel(fieldnames(ids))
    if ~strcmp(fields{i},'skip')   
        if isnumeric(ids.(fields{i})) & ~isempty(str2num(fn(sepIdx(i):sepIdx(i+1)-2)))
            descriptors.(fields{i}) = str2num(fn(sepIdx(i):sepIdx(i+1)-2));
        else
            descriptors.(fields{i}) = fn(sepIdx(i):sepIdx(i+1)-2);
        end
    else
        descriptors = rmfield(descriptors,'skip');
    end
end
    