% function for calculating channel registration translation for cells where
% registration was successful only in one channel
% 
% This function must run BEFORE meanTranslation
% 
% input
% - x- and y-coordinates of points in green and red channel
% - flags indicating registration succes
%   translation is correlated if flag indicates 'Registration might not be
%   reliable' in one channel and 'Registration successfull' in the other
% 
% output
% - Trans_Green_x, Trans_Green_y, Trans_Red_x, Trans_Red_y
%   vectors of translations updated with correlated values
% - Flag
%   Cell array of strings updated with 'derived from correlation'


function [Trans_Green_x, Trans_Green_y, Trans_Red_x, Trans_Red_y, FlagGreen, FlagRed] = correlatedRegistration(Trans_Green_x, Trans_Green_y, Trans_Red_x, Trans_Red_y, FlagGreen, FlagRed)

    % Check Input
    if ~isequal(length(Trans_Green_x), length(Trans_Green_y), length(Trans_Red_x),...
            length(Trans_Red_y), length(FlagGreen), length(FlagRed))
        error('Input dimension mismatch')
    end


    for i = 1:length(Trans_Green_x)
        
        if strcmp(FlagRed{i},'Registration successfull') && ...
                strcmp(FlagGreen{i},'Registration might not be reliable')

            Trans_Green_x(i) = (Trans_Red_x(i) + 0.18) / 1.41;
            Trans_Green_y(i) = (Trans_Red_y(i) + 0.26 ) / 1.09;
            FlagGreen{i} = 'derived from correlation';

        elseif strcmp(FlagGreen{i},'Registration successfull') &&...
                strcmp(FlagRed{i},'Registration might not be reliable')

            Trans_Red_x(i) = 1.41*Trans_Green_x(i)-0.18;
            Trans_Red_y(i) = 1.09*Trans_Green_y(i)-0.26;
            FlagRed{i}='derived from correlation';

        end
        
    end

end