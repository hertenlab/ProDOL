function filterbyMasks_thunderSTORM(datasets,maskStem,pixelsize)
% Filter points based on 3ChannelsMask binary images by looping through
% movie objects in dataset.

disp('Filterng thunderSTORM points by mask')

for i=1:length(datasets)
    % Construct path to mask file
    dispProgress(i, length(datasets));
    
    density = strrep(num2str(datasets(i).concentration,'%01.1f'),'.','-');
       
    if density == '0'
        density = '0-0';
    end
    
    maskfile = [maskStem,'density_',density,'/','fullImage_density_',density,'_',num2str(datasets(i).replicate,'%02.f'),'_mask.tif'];
    
    % report on progress
    progress = round((i/length(datasets))*100,2);
    
    % perform point filtering
    datasets(i).filteranalysisbymask(maskfile,pixelsize);
end

