function beadsImageSets = beads_importUtrack(beadsImageSets)

    ndFilter = [0 8 16 32];
    ndFolder_str = {'ND00' 'ND08' 'ND16' 'ND32'};
    ndFile_str = {'nd00' 'nd8' 'nd16' 'nd32'};
    laserIntensity = [.001 .0025 .005 .01 .02 .05 .1 .2 .5 1];
    laserIntensity_str = {'0-0010' '0-0025' '0-0050' '0-01' '0-02' '0-05' '0-1' '0-2' '0-5' '1-0'};

    channels = {'blue' 'green' 'mask' 'red'};
    channels_str = channels;

    movieListPath = 'y:\DOL Calibration\Data\beads-control\intensity_screen2\u-track\movieList_all.mat';
    movielist = load(movieListPath);
    MDpaths = movielist.ML.movieDataFile_;

    % loop through beadsImageSets and children, find matching MDpath,
    % import points and create point objects as children of multicolorimage

    uTrackChannels = [1 2 4];
    fitMode = questdlg('u-track fit type', 'fit type', 'single', 'multi', 'single');
    uTrackChNames = strcat({'u-track '}, fitMode, {' '}, {'blue' 'green' 'red'});

    for setIndex = 1:length(beadsImageSets)

        % loop through replicates
        for repIndex = 1:length(beadsImageSets(setIndex).childImages)
            dispProgress(setIndex, length(beadsImageSets), repIndex, length(beadsImageSets(setIndex).childImages));

            thisimage = beadsImageSets(setIndex).childImages(repIndex);
            % construct u-track movie data folder name from image(set) descriptors
            nd = thisimage.parentImageSet.descriptors.ndFilter;
            li = thisimage.parentImageSet.descriptors.laserIntensity;
            rep = thisimage.replicate;
            nd_str = ndFile_str{ndFilter == nd};
            li_str = laserIntensity_str{laserIntensity == li};
            rep_str = num2str(rep, '%02.0f');
            mdFolderName = ['beads_' nd_str '_' li_str '_' rep_str '_'];
            thisMDpath = MDpaths{~cellfun(@isempty, strfind(MDpaths,mdFolderName))};

            thisMDpath = strrep(thisMDpath, 'Z:', 'y:');

            % loop through channels
            for ch = 1:length(uTrackChannels)

                [PointDetectionParameters, x, y, A, c, s] = ...
                    pointsFromMovieData(thisMDpath, uTrackChannels(ch));
                % path to actual point_sources data of this channel
                pointSourcePath = strrep(thisMDpath, 'movieData.mat', ['TrackingPackage\point_sources\channel_' uTrackChannels(ch) '.mat']);
                % create pointset for every channel of u-track data
                ptSet = pointset(uTrackChNames{ch}, thisimage, pointSourcePath);

                % store point detection parameters
                ptSet.pointDetectionParameters = PointDetectionParameters;

                % link pointset to parent image
                ptSet.parentImage.addPointSet(ptSet);

                % add points to pointet
                ptSet.addPoints(x, y, A, s, c);

                % calculate density
                ptSet.calculateDensity();

            end

        end

    end

end