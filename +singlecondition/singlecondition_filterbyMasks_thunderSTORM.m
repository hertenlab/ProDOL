function singlecondition_filterbyMasks_thunderSTORM(datasets,maskStem,pixelsize)
% Filter points based on 3ChannelsMask binary images by looping through
% movie objects in dataset.

for i=1:length(datasets)
    % Construct path to mask file
    fprintf('Current dataset: %d.\n', i)
    
    stem = [maskStem,filesep,'cond1'];
    subdir = [datasets(i).CellType,' ',num2str(datasets(i).concentration),'nM'];
    file = ['DOLeval_',datasets(i).CellType,'_',num2str(datasets(i).concentration),'nM_',num2str(datasets(i).replicate,'%02.f'),'_mask.tif'];
    
    maskfileP = fullfile(stem,subdir,file);
    
    % perform point filtering
    if exist(maskfileP)
        datasets(i).filteranalysisbymask(maskfileP,pixelsize);
    else
        fprintf('mask file not found')
    end
end

