function updateImgDirectory(obj,oldStem,newStem)
    for i = 1:numel(obj)
        for j=1:numel(obj(i).childImages)
            for k=1:numel(obj(i).childImages(j).channels)
                imPath = obj(i).childImages(j).channels(k).path;
                obj(i).childImages(j).channels(k).path = strrep(imPath,oldStem,newStem);
            end
        end
    end
end