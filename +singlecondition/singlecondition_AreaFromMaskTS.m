function area = simulations_AreaFromMaskTS(movie,channelsMask_dir)

stem = [channelsMask_dir,filesep,'cond1'];
subdir = [movie.CellType,' ',num2str(movie.concentration),'nM'];
file = ['DOLeval_',movie.CellType,'_',num2str(movie.concentration),'nM_',num2str(movie.replicate,'%02.f'),'_mask.tif'];

maskFile = fullfile(stem,subdir,file);



mask = imread(maskFile);
area = sum(mask(:) > 0);

end