function [x, y, txtFileName] = pointsFromGroundTruth(density, dol, replicate, coords_root, movieDataPath)


    if iscellstr(movieDataPath)
        [x, y, txtFileName] = deal(cell(size(movieDataPath)));
        for i = 1:length(movieDataPath)
            dispProgress(i, length(movieDataPath))
            [x{i}, y{i}, txtFileName{i}] = getCoords(density(i), dol(i), replicate(i), coords_root, movieDataPath{i});
        end
    elseif ischar(movieDataPath)
        [x,y,txtFileName] = getCoords(density, dol, replicate, coords_root, movieDataPath);
    else
        error('Input Error. Must be string or cell array of strings')
    end
    
end

function [x, y, txtFileName] = getCoords(density, dol, replicate, coords_root, movieDataPath)
    
    densitydir = strrep(num2str(density, 'density_%.1f'), '.', '-');
    doldir = strrep(num2str(dol, 'DOL_%.2f'), '.', '-');
    filename = [strrep(sprintf('density_%.1f_DOL_%.2f_%02.0f', density, dol, replicate), '.', '-'), '_pos_px.txt'];
    txtFileName = fullfile(coords_root, densitydir, doldir, filename);
    
    coords = dlmread(txtFileName);

    if ~isempty(strfind(movieDataPath, 'movieData.mat'))
        maskPath = strrep(movieDataPath, 'movieData.mat', ...
            ['mask\fullImage_density_' strrep(num2str(density,'%.1f'),'.','-') '_'...
            num2str(replicate,'%02d'), '_mask.tif']);
    elseif ~isempty(strfind(movieDataPath, '_mask.tif'))
        maskPath = movieDataPath;
    end

    mask = imread(maskPath);

    ind1 = max(1,min(512,floor(coords(:,2))+1));
    ind2 = max(1,min(512,floor(coords(:,1))+1));
    filterIndex = logical(diag(mask(ind1,ind2)));

    x = coords(filterIndex,1);
    y = coords(filterIndex,2);

end