% If window cannot be closed, focus by clicking on it and then type
% delete(gcf) in console

function imageSetInspector(imgSet)

    figH = figure('Position', [100 100 494 171],...
        'Name', 'blueCherryPicker',...
        'WindowKeyPressFcn', @KeyControl,...
        'WindowKeyReleaseFcn', @KeyRelease,...
        'CloseRequestFcn', @closeWindow);
    % dropdown menu
    handles.imageDrop = uicontrol('Parent', figH,...
        'Style', 'popupmenu',...
        'Callback', @showCurrentImage,...
        'Position', [28 132 440 22]);
    
    % random checkbox
    handles.randomCheck = uicontrol('Parent', figH,...
        'Style', 'checkbox',...
        'String', 'random order',...
        'Position', [372 45 96 15]);
    
    % skip set images
    handles.unsetOnlyCheck = uicontrol('Parent', figH,...
        'Style', 'checkbox',...
        'String', 'unset only',...
        'Position', [372 25 96 15]);
    
    % navigation buttons
    uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', '10 Previous',...
        'Callback', {@navigate, -10},...
        'Position', [28 74 100 35]);
    uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', 'Previous (A)',...
        'Callback', {@navigate, -1},...
        'Position', [141 74 100 35]);
    uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', 'Next (D)',...
        'Callback', {@navigate, 1},...
        'Position', [257 74 100 35]);
    uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', '10 Next',...
        'Callback', {@navigate, 10},...
        'Position', [368 74 100 35]);
    
    % evaluation buttons
    handles.includeButton = uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', 'include (1)',...
        'BackgroundColor', [.5 .8 .3],...
        'Callback', {@evaluate, 'include'},...
        'Position', [28 25 100 35]);
    handles.unsetButton = uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', 'unset (2)',...
        'BackgroundColor', [.8 .8 .8],...
        'Callback', {@evaluate, 'unset'},...
        'Position', [141 25 100 35]);
    handles.excludeButton = uicontrol('Parent', figH,...
        'Style', 'pushbutton',...
        'String', 'exclude (3)',...
        'BackgroundColor', [.8 .3 .3],...
        'Callback', {@evaluate, 'exclude'},...
        'Position', [257 25 100 35]);
    
    setappdata(figH, 'handles', handles);
    
    initializeImages(figH, imgSet);
    
end


function KeyControl(hObject, eventdata)

    Character = eventdata.Character;
    Source = eventdata.Source;
    Key = eventdata.Key;
    Modifier = eventdata.Modifier;
    
    switch Character
        case '1'
            evaluate([], [], 'include')
        case '2'
            evaluate([], [], 'unset')
        case '3'
            evaluate([], [], 'exclude')
        case 'a'
            navigate([], [], -1)
        case 'd'
            navigate([], [], 1)
    end

end

function KeyRelease(varargin)
    uiresume
end

function initializeImages(figH, imgSet)
    
    handles = getappdata(figH, 'handles');
    
    % retrieve image entries
    handles.imageVector = [imgSet.childImages];
    % fill dropdown menu
    handles.imageDescription = handles.imageVector.description;
    
    handles = createDropDownList(handles);
    
    handles.imageDrop.Value = 1;
    % random order indices
    handles.randomIndex = randperm(numel(handles.imageVector));
    
    handles.showImageH = figure('Name', 'blueCherryPicker - showImage');
    
    setappdata(figH, 'handles', handles);
    showCurrentImage(figH, []);

end

function handles = createDropDownList(handles)
    
    list = handles.imageDescription;
    includeVector = {handles.imageVector.include};
    
    for i = 1:length(list)
        if ~isempty(includeVector{i})
            if includeVector{i}
                list{i} = ['<HTML><FONT COLOR="green">', list{i}];
            else
                list{i} = ['<HTML><FONT COLOR="red">', list{i}];
            end
        end
    end
    
    handles.imageDrop.String = list;
    
end

function showCurrentImage(figH, eventdata)

    if isempty(gcbf)
        handles = getappdata(figH, 'handles');
    else
        handles = getappdata(gcbf, 'handles');
    end
    
    currentImage = handles.imageVector(handles.imageDrop.Value);
    showImage(currentImage, {'blue', 'mask'}, '', handles.showImageH);
    
    if isempty(currentImage.include)
        handles.includeButton.FontWeight = 'normal';
        handles.unsetButton.FontWeight = 'bold';
        handles.excludeButton.FontWeight = 'normal';
        clr = [.5 .5 .5];
    elseif currentImage.include
        handles.includeButton.FontWeight = 'bold';
        handles.unsetButton.FontWeight = 'normal';
        handles.excludeButton.FontWeight = 'normal';
        clr = [.2 .8 .2];
    else
        handles.includeButton.FontWeight = 'normal';
        handles.unsetButton.FontWeight = 'normal';
        handles.excludeButton.FontWeight = 'bold';
        clr = [.8 .2 .2];
    end
    
    rectangle('Position', [.5 , .5, 512, 512], 'EdgeColor', clr, 'LineWidth', 4);
    
    figure(gcbf);
    
end

function navigate(hObject, eventdata, stepSize)
    
    handles = getappdata(gcbf, 'handles');
    
    if handles.randomCheck.Value
        currentRandomIndex = find(handles.randomIndex == handles.imageDrop.Value);
        newRandomIndex = min(max(currentRandomIndex + stepSize, 1), numel(handles.imageVector));
        newIndex = handles.randomIndex(newRandomIndex);
    else
        currentIndex = handles.imageDrop.Value;
        newIndex = min(max(currentIndex + stepSize, 1), numel(handles.imageVector));
    end
    
    handles.imageDrop.Value = newIndex;
    setappdata(gcbf, 'handles', handles);
    
    if handles.unsetOnlyCheck.Value && ~isempty(handles.imageVector(newIndex).include)...
        && newIndex > 1 && newIndex < length(handles.imageVector)
        navigate([], [], sign(stepSize))
    else
        showCurrentImage(gcbf, []);
    end

end

function evaluate(hObject, eventdata, eligibility)
    
    handles = getappdata(gcbf, 'handles');
    currentImage = handles.imageVector(handles.imageDrop.Value);
    switch eligibility
        case 'exclude'
            currentImage.include = false;
        case 'include'
            currentImage.include = true;
        case 'unset'
            currentImage.include = [];
    end
    navigate([], [], 1)
    
    createDropDownList(handles);

end

function closeWindow(hObject, eventdata)

    handles = getappdata(gcbf, 'handles');
    close(handles.showImageH);
    delete(hObject);

end

