function move3ChannelFolders(rootDir, outDir, mode)

% rootDir = uigetdir('','choose a root directory');
% outDir = uigetdir('','choose an output directory');

folder(rootDir, outDir, mode);

function folder(path, outDir, mode)
    
    dirlist = dir(path);
    
    filelist = [{dirlist(not([dirlist.isdir])).name}]';
    
    
    for i=3:length(dirlist)
        if dirlist(i).isdir
            if strcmp(dirlist(i).name, '3Channels_Mask')
                move3Channels_Mask(fullfile(path,dirlist(i).name), outDir, mode);
            else
                newpath = fullfile(path, dirlist(i).name);
                folder(newpath, outDir,mode);
            end
        end
    end    
end

function move3Channels_Mask(path, outDir, mode)

    dirlist = dir(path);
    
    filelist = {dirlist(not([dirlist.isdir])).name}';
    
    pathFileSep = strfind(path, filesep);
    
    parentFolderName = path(pathFileSep(end-1)+1:pathFileSep(end)-1);
    
    if not(isempty(strfind(parentFolderName,'gSEP'))) || not(isempty(strfind(parentFolderName, 'LynG')))

        mkdir(fullfile(outDir,parentFolderName));

        for i=3:length(dirlist)
            switch mode
                case 'copy'
                    [~, msg, ~] = copyfile(fullfile(dirlist(i).folder, dirlist(i).name), ...
                        fullfile(outDir,parentFolderName,dirlist(i).name));
                case 'move'
                    [~, msg, ~] = movefile(fullfile(dirlist(i).folder, dirlist(i).name), ...
                        fullfile(outDir,parentFolderName,dirlist(i).name));
            end
            if not(isempty(msg))
                warning(['Encountered problem copying folder: \n', ...
                    fullfile(dirlist(i).folder,dirlist(i).name), '\n'...
                    msg],'\n');
            end
        end
        
    end

end

end