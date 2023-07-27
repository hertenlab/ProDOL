% Script searches for subfolders of input directory rootDir containing only
% one file ending with 'ome.tif'. Tif file is moved to parent folder and
% renamed according to subfolder name
function processMMData(rootdir)

if nargin
    folder_name = rootdir;
else
    folder_name = uigetdir();
end

processMMData(folder_name);

function processMMData(rootDir)

rootdirlist = dir(rootDir);

for i=3:length(rootdirlist)
    path = fullfile(rootDir, rootdirlist(i).name);
    if isdir(path)
        folderList(path);
    end
end

    
function folderList(path)

    dirlist = dir(path);
    
    for j=3:length(dirlist)
        filename = dirlist(j).name;
        newpath = fullfile(path, filename);
        if isdir(newpath)
            folderList(newpath);
        elseif not(isempty(strfind(dirlist(j).name, 'ome.tif')))
            extractTifFromFolder(newpath)
        end
    end

end

function extractTifFromFolder(filepath)

    pathFileSep = strfind(filepath, filesep);
    folderpath = filepath(1:pathFileSep(end));
    
    dirlist = dir(folderpath);
    
    if length(dirlist) < 5
            oldTifPath = filepath;
            newTifPath = [folderpath(1:end-1) '.tif'];
            movefile(oldTifPath,newTifPath);
            if length(dirlist) == 4
                oldMetaPath = [oldTifPath(1:end-8), '_metadata.txt'];
                newMetaPath = replace(newTifPath, '.tif', '_metadata.txt');
                movefile(oldMetaPath,newMetaPath);
                fprintf('old:\n%s\n%s\nnew:\n%s\n%s\n\n', oldTifPath, oldMetaPath, newTifPath, newMetaPath);
            else
                fprintf('old:\n%s\nnew:\n %s\n', oldTifPath, newTifPath);
            end
            rmdir(folderpath, 's');
    else
        warning(sprintf('unkown extra files in this folder:\n%s\n', folderpath))
    end

end

end
end