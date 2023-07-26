function filterbyMasks_thunderSTORM(datasets, maskStem, pixelsize)
% Filter points based on 3ChannelsMask binary images by looping through
% movie objects in dataset.

disp('Filtering thunderSTORM points by mask')

for i=1:length(datasets)
    % Construct path to mask file
    dispProgress(i, length(datasets));
    
    density = strrep(num2str(datasets(i).concentration,'%01.1f'),'.','-');
    dol = strrep(num2str(datasets(i).incubation_time,'%01.2f'),'.','-');
       
    if density == '0'
        density = '0-0';
    end
    
    folder = [maskStem, '/', 'density_', density, '/', 'DOL_', dol, '/'];
    filename = ['fullImage_density_', density, '_', 'DOL_', dol, '_', ...
        num2str(datasets(i).replicate,'%02.f'), '_mask.tif'];
    maskfile = [folder filename];
    
    % perform point filtering
    datasets(i).filteranalysisbymask(maskfile, pixelsize);
    
end

