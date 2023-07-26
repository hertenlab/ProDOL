function [params, x, y, A, c, s] = pointsFromMovieData(movieDataPath, channel)
% channel: integer
% label: color of the channel (e.g. 'Blue', 'Red' or 'Green')

% store point detection parameters from u-track results
% u-track point detection parameters as stored in movieData.mat

if iscellstr(movieDataPath)
    
    for i = 1:length(movieDataPath)
        dispProgress(i, length(movieDataPath));
        [params{i}, x{i}, y{i}, A{i}, c{i}, s{i}] = readMovieData(movieDataPath{i}, channel);
    end
    
elseif ischar(movieDataPath)
    [params, x, y, A, c, s] = readMovieData(movieDataPath, channel);
else
    error('input moviDataPath must be string or cell array of strings');
end

end

function [params, x, y, A, c, s] = readMovieData(movieDataPath, channel)

moviedata = load(movieDataPath);
params = moviedata.MD.processes_{1,1}.funParams_;
clear moviedata

channelPath = strrep(movieDataPath, 'movieData.mat', ['TrackingPackage\point_sources\channel_' num2str(channel) '.mat']);

Channel = load(channelPath);
    
if not(isfield(Channel.movieInfo, 'x'))
    x = [];
    y = [];
    A = [];
    c = [];
    s = [];
else       
    x = Channel.movieInfo.x;
    y = Channel.movieInfo.y;
    A = Channel.movieInfo.A;
    c = Channel.movieInfo.c;
    s = Channel.movieInfo.s;
end
    
end