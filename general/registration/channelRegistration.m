% function for mapping two channels by a set of x- and y-coordinates
% 
% input
% - x- and y-coordinates of reference channel and unregistered channel
% - scaling factors
%   typically: 
%   MeanScaleFactorXBlueGreen = 0.5523;
%   MeanScaleFactorYBlueGreen = 0.4909;
%   MeanScaleFactorXBlueRed = 0.6773;
%   MeanScaleFactorYBlueRed = 0.5682;
% 
% output
% - Trans_x, Trans_y
%   vectors of translations updated with correlated values
% - Flag
%   Cell array of strings indicating registration succes
% 

function [Trans_x, Trans_y, Flag] = channelRegistration(Ref_x, Ref_y, Unreg_x, Unreg_y, Scale_x, Scale_y)

    % Check Input
    if ~isequal(size(Ref_x), size(Ref_y), size(Unreg_x), size(Unreg_y))
        error('Input dimension mismatch')
    end
    
    if iscell(Ref_x)
        % preallocate variables
        [Trans_x, Trans_y] = deal(zeros(length(Ref_x),1));
        [Reg_x, Reg_y, Flag] = deal(cell(size(Ref_x)));
        
        % loop through cell array of position vectors
        for i = 1:length(Ref_x)
            
            dispProgress(i, length(Ref_x))
            
            [Trans_x(i), Trans_y(i), Flag{i}] = channelReg(...
            Ref_x{i}, Ref_y{i}, Unreg_x{i}, Unreg_y{i}, Scale_x, Scale_y);
            
        end
        
    else
        [Trans_x, Trans_y, Flag] = channelReg(...
            Ref_x, Ref_y, Unreg_x, Unreg_y, Scale_x, Scale_y);
    end

    
end

function [Trans_x, Trans_y, Flag] = channelReg( Ref_x, Ref_y, Unreg_x, Unreg_y, Scale_x, Scale_y)

% perform registration if there are more than 10 points in channels
if isempty(Ref_x) || length(Ref_x) < 10
%     warning('Not enough points for registration in reference channel');
    Trans_x = 0;
    Trans_y = 0;
    Flag = 'Registration might not be reliable';
elseif isempty(Unreg_x) || length(Unreg_x) < 10
%     warning('Not enough points for registration in registration channel');
    Trans_x = 0;
    Trans_y = 0;
    Flag = 'Registration might not be reliable';
else
    [Trans_x, Trans_y, Flag, ~] = ...
            SigiRegistrationCells(Ref_x, Ref_y, Unreg_x, Unreg_y,...
            Scale_x, Scale_y);
    Flag = 'Registration successfull';
end

end