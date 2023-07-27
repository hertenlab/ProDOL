function drawBand(xArray, yArray, errArray)

    ax = gca;
    hold on
    % draw bands and + signs
    for i = 1:size(xArray,2)
        idx = ~any(isnan([xArray(:,i), yArray(:,i), errArray(:,i)]),2);
        x = xArray(idx,i);
        y = yArray(idx,i);
        err = errArray(idx,i);
        ax.ColorOrderIndex = i;
        plot(x, y, '+', 'LineWidth', 0.5, 'HandleVisibility', 'off');
        bandcolor = ax.ColorOrder(mod(i-1,7) + 1,:);
        fill([x;flipud(x)], [y-err;flipud(y+err)], bandcolor, ...
            'LineStyle','none', 'FaceAlpha', 0.1, 'HandleVisibility', 'off');
    end
    
    % draw lines
    for i = 1:size(xArray,2)
        idx = ~any(isnan([xArray(:,i), yArray(:,i), errArray(:,i)]),2);
        x = xArray(idx,i);
        y = yArray(idx,i);
        ax.ColorOrderIndex = i;
        plot(x, y, '-', 'LineWidth', 2);
    end
    
    
end