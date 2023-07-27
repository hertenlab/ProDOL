function descriptors = importCherrypicking(cherryData,imgSet)
numel(cherryData{1})
numel(cherryData{2})
numel([imgSet.childImages])
if ~numel(cherryData{1})==numel(cherryData{2}) && numel(cherryData{1})==numel([imgSet.childImages])
    error('check input data')
end


tmp = [imgSet.childImages];
tmp2 = tmp.description;

for i=1:numel(cherryData{2})
    i
    tmp3 = arrayfun(@(x) isequal(cherryData{2}(i),x),tmp2);
    tmp(tmp3).include = cherryData{1}(tmp3);
end

end