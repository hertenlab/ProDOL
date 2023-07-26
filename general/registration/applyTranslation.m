% function for application of translation for registration of channels
% 
% input
% - x- and y-coordinates of unregistered channel
% - translation values
% - scaling factors
%   typically: 
%   MeanScaleFactorXBlueGreen = 0.5523;
%   MeanScaleFactorYBlueGreen = 0.4909;
%   MeanScaleFactorXBlueRed = 0.6773;
%   MeanScaleFactorYBlueRed = 0.5682;
% 
% output
% - Trans_Green_x, Trans_Green_y, Trans_Red_x, Trans_Red_y
%   vectors of translations updated with correlated values
% - Flag
%   Cell array of strings updated with 'derived from correlation'

function [Reg_x, Reg_y] = applyTranslation(Unreg_x, Unreg_y, Trans_x, Trans_y, Scale_x, Scale_y)

    % Check Input
    if ~isequal(length(Unreg_x), length(Unreg_y), length(Trans_x), length(Trans_y))
        error('Input dimension mismatch')
    end

    % Preallocate variables
    [Reg_x, Reg_y] = deal(cell(size(Unreg_x)));
    
    for i = 1: length(Unreg_x)
        % apply registration
        Reg_x{i} = (Unreg_x{i} - (Unreg_x{i} - 256)./256.*Scale_x)+Trans_x(i);
        Reg_y{i} = (Unreg_y{i} - (Unreg_y{i} - 256)./256.*Scale_y)+Trans_y(i);
    end


end