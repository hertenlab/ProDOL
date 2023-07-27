% function for displaying progress when running through multiple loops in
% output console on a single line. Can handle input from up to 3 loops.
% 
% syntax:
% arguments are the current element (i) of the loop and the maximum value
% (iMax). When running through multiple loops hand over current element and
% maximum consecutevly.
%
% output might look odd if first and last element of loops are not called
% 
% example
% iMax = 20;
% for i = 1:iMax
%     tMax = 50;
%     for t = 1:tMax
%         dispProgress(i, iMax, t, tMax)
%         pause(0.1);
%     end
% end

function dispProgress(varargin)

    if mod(nargin,2)
        error('Odd number of inputs required')
    end
    
    if nargin > 6
        error('cannot handle more than 6 inputs')
    end
    
    switch nargin
        case 2
            totalMax = varargin{2};
            current = varargin{1};
            displayProgress(current, totalMax)
        case 4
            totalMax = varargin{2} * varargin{4};
            current = (varargin{1} - 1) * varargin{4} + varargin{3};
            displayProgress(current, totalMax)            
        case 6
            totalMax = varargin{2} * varargin{4} * varargin{6};
            current = (varargin{1} - 1) * varargin{4} + (varargin{3} - 1) * varargin{6} + varargin{5};
            displayProgress(current, totalMax)      
    end    
    
end

function displayProgress(current, totalMax)
    
    if current == 1
        fprintf('  0 %%\n');
    elseif current == totalMax
        fprintf('\b\b\b\b\b\b100 %%\n');
    else
        fprintf('\b\b\b\b\b\b%3.0f %%\n',100*current/totalMax)
    end
    
end