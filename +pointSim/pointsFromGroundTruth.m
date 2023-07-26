function [x,y,txtFileName] = pointsFromGroundTruth(density, replicate, coords_root, movieDataPath)


    if iscellstr(movieDataPath)
        [x, y] = deal(cell(size(movieDataPath)));
        for i = 1:length(movieDataPath)
            dispProgress(i, length(movieDataPath))
            [x{i},y{i},txtFileName{i}] = getCoords(density(i), replicate(i), coords_root, movieDataPath{i});
        end
    elseif ischar(movieDataPath)
        [x,y,txtFileName] = getCoords(density, replicate, coords_root, movieDataPath);
    else
        error('Input Error. Must be string or cell array of strings')
    end
    
end

function [x,y,txtFileName] = getCoords(density, replicate, coords_root, movieDataPath)
    
    if density > 0
        dirlist = dir(coords_root);
        density_str = strrep(num2str(density,'%.1f'),'.','-');
        index = ~cellfun(@isempty,strfind({dirlist.name}, density_str));

        subdir = fullfile(coords_root,dirlist(index).name);

        replicate_str = num2str(replicate, '%02d');
        subdirlist = dir(subdir);
        index2 = ~cellfun(@isempty,strfind({subdirlist.name}, replicate_str));
        px_index = ~cellfun(@isempty,strfind({subdirlist.name}, 'pos_px'));

        txtFileName = fullfile(subdir, subdirlist(index2 & px_index).name);
        coords = dlmread(txtFileName);

        if ~isempty(strfind(movieDataPath, 'movieData.mat'))
            maskPath = strrep(movieDataPath, 'movieData.mat', ...
                ['mask\fullImage_density_' strrep(num2str(density,'%.1f'),'.','-') '_'...
                num2str(replicate,'%02d'), '_mask.tif']);
            mask = imread(maskPath);
        elseif ~isempty(strfind(movieDataPath, '_mask.tif'))
            maskPath = movieDataPath;
            mask = imread(maskPath);
        else
            % if no mask file is found points are not filtered. Note:
            % this implementation assumes an image size of 512 x 512 px
            mask = ones(512,512);
        end
        

        ind1 = max(1,min(512,floor(coords(:,2))+1));
        ind2 = max(1,min(512,floor(coords(:,1))+1));
        filterIndex = logical(diag(mask(ind1,ind2)));

        x = coords(filterIndex,1);
        y = coords(filterIndex,2);
    else
        x = [];
        y = [];
        txtFileName = '';
    end


end