allpaths = {...
    'y:\DOL Calibration\Data\klaus\analysis\klaus_base_1.2.mat'
    'y:\DOL Calibration\Data\felix\analysis\felix_base_1.2.mat'
    'y:\DOL Calibration\Data\sigi\analysis\sigi_base_1.2.mat'
    'y:\DOL Calibration\Data\wioleta\analysis\wioleta_base_1.2.mat'};

thresholds = [0.8 0.95; 0.252 0.385];
for t = 1:2
    for i = 1:length(allpaths)
        doIt(allpaths{i}, thresholds(:,t));
    end
end

function doIt(sourcepath, t)

    filterPointsDOL(sourcepath, t(2));
    newpath = strrep(sourcepath, 'base_1.2.mat', ['rg-A2C-0.2_b-' num2str(100*t(1)) '-percentile.mat']);
    save(newpath);

end