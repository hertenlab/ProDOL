% function for extraction of point coordinates and gauss fit parameters
% from u-track movieData file
% input
% - movieDataPath
%   String or cell array of strings containing full path to movieData file
% output:
% - point detection parameters
% - x,y-coordinates
% - A Amplitude, c Offset, s Sigma of Gaussfit

function [params, x, y, A, c, s] = screen_pointsFromMovieData(movieDataPath, channel)

    if iscellstr(movieDataPath)
        [params, x, y, A, c, s] = cell(size(movieDataPath));
        for i = 1:length(movieDataPath)
            [params{i}, x{i}, y{i}, A{i}, c{i}, s{i}] = getPoints(movieDataPath{i}, channel);
        end
    elseif ischar(movieDataPath)
        [params, x, y, A, c, s] = getPoints(movieDataPath, channel);
    else
        error('Input Error. movieDataPath must be string or cell array of strings')
    end
    
end

function [params, x, y, A, c, s] = getPoints(movieDataPath, channel)

% store point detection parameters from u-track results
% u-track point detection parameters as stored in movieData.mat
moviedata = load(movieDataPath);
params = moviedata.MD.processes_{1,1}.funParams_;
clear moviedata

channelPath = strrep(movieDataPath, 'movieData.mat', ['TrackingPackage\point_sources\channel_' num2str(channel) '.mat']);

Channel = load(channelPath);
    
if not(isfield(Channel.movieInfo, 'x'))
    warning(sprintf('No points found in\n%s',movieDataPath))
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