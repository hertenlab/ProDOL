% function to extract points from movielist

function points = singlecondition_pointExtraction(movieListPath, channel)

    movielist = load(movieListPath);
    MDpaths = movielist.ML.movieDataFile_;

    [params, x, y, A, c, s] = pointsFromMovieData(MDpaths, channel);

    pointStruct = struct('PointDetectionParameters', params,...
                    'x', x, 'y', y, 'A', A, 'c', c, 's', s);
    points.x = {pointStruct.x};
    points.y = {pointStruct.y};
    points.A = {pointStruct.A};
    points.c = {pointStruct.c};
    points.s = {pointStruct.s};
            
end