% function for calculating the mean translation for a set of translations.
% only entries where Flag indicates successful registration are considered.
% Translation values are set to mean values where flag indicates 
% 'Registration might not be reliable'
% 
% This function should run AFTER correlatedRegistration
% 
% input
% - Trans_x, Trans_y
%   Vector of translations in x and y
% - Flag
%   Cell array of strings indicating if values in Trans_x and Trans_y were obtained from
%   succesful registration ('Registration successfull')
% 
% output
% - meanTrans_x, meanTrans_y
%   calculated mean values
% - Trans_x, Trans_y
%   vectors of translations updated with mean values
% - Flag
%   Cell array of strings updated with 'Warning: mean Values used' for
%   former entries showing 'Registration might not be reliable'

function [meanTrans_x, meanTrans_y, Trans_x, Trans_y, Flag] = meanTranslation(Trans_x, Trans_y, Flag)

    meanTrans_x = mean(Trans_x(strcmp(Flag,'Registration successfull')));
    meanTrans_y = mean(Trans_y(strcmp(Flag,'Registration successfull')));
        
    logicIndex = strcmp(Flag,'Registration might not be reliable');
    
    Trans_x(logicIndex) = meanTrans_x;
    Trans_y(logicIndex) = meanTrans_y;
    Flag(logicIndex) = {'Warning: mean Values used'};
    
end