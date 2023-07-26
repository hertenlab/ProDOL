
handles.rootDir = 'y:\DOL Calibration\Data\felix\3ChannelsMask\';
handles.matFilePath = 'y:\DOL Calibration\Data\felix\analysis\felix_base.mat';

dataSet = load(handles.matFilePath, 'CellType', 'incubation_time', 'concentration', 'replicate');
handles.dataSet = dataSet;

handles.blueTifList = findBlueTif(handles.rootDir);

handles.blueTifListIndex = 1;

handles.valid = true(length(handles.dataSet.CellType),1);

mainfig = figure('Name', 'Sag ja oder nein',...
    'Position', [0 0 600 700],...
    'WindowKeyPressFcn', @KeyControl,...
    'CloseRequestFcn', @closeWindow);
handles.ax = axes('Units', 'Normalized',...
    'Position', [0 0.1 1 0.9]);

handles.loadbutton = uicontrol('Parent', mainfig,...
    'Style', 'pushbutton',...
    'String', 'Load',...
    'Callback', @loadData,...
    'Units', 'Normalized',...
    'Position', [0.01 0.055 0.08 0.035]);
handles.savebutton = uicontrol('Parent', mainfig,...
    'Style', 'pushbutton',...
    'String', 'Save',...
    'Callback', @saveData,...
    'Units', 'Normalized',...
    'Position', [0.01 0.01 0.08 0.035]);

handles.yesbutton = uicontrol('Parent', mainfig,...
    'Style', 'pushbutton',...
    'String', 'Yes (y)',...
    'Callback', {@push, 'yes'},...
    'Units', 'Normalized',...
    'Position', [0.1 0.01 0.4 0.08]);
handles.nobutton = uicontrol('Parent', mainfig,...
    'Style', 'pushbutton',...
    'String', 'No (n)',...
    'Callback', {@push, 'no'},...
    'Units', 'Normalized',...
    'Position', [0.5 0.01 0.4 0.08]);

handles.index = uicontrol('Parent', mainfig,...
    'Style', 'edit',...
    'String', '',...
    'Callback', @goToIndex,...
    'Units', 'Normalized',...
    'Position', [0.91 0.01 0.08 0.08]);

guidata(mainfig, handles);

displayImage(handles.blueTifListIndex);


function push(hObject, actiondata, answer)
    
    handles = guidata(gcbf);
    ListIndex = handles.blueTifListIndex;
    filepath = handles.blueTifList{ListIndex};
    
    [thisCellType, thisincubation_time, thisconcentration, thisreplicate] = conditions(filepath);
    
    dataSet = handles.dataSet;
    dataSetIndex = findIndex(thisCellType, thisincubation_time, thisconcentration, thisreplicate, dataSet);
    
    switch answer
        case 'yes'
            handles.valid(dataSetIndex) = true;
        case 'no'
            handles.valid(dataSetIndex) = false;
    end
    fprintf('%s %.2f h, %d nM %02d ----> %s \n', thisCellType,  thisincubation_time, thisconcentration, thisreplicate, answer);
    
    guidata(gcbf, handles);
    
    displayNextImage();
    
end

function KeyControl(hObject, eventdata)

    Key = eventdata.Key;
    
    switch Key
        case 'y'
            push([], [], 'yes');
        case 'n'
            push([], [], 'no');
    end
        
end

function displayNextImage

    handles = guidata(gcbf);
    handles.blueTifListIndex = handles.blueTifListIndex + 1;
    
    guidata(gcf, handles);
    
    displayImage(handles.blueTifListIndex)
    
end

function displayImage(ListIndex)
    
    handles = guidata(gcf);
    filepath = handles.blueTifList{ListIndex};
    
%     filepath = 'y:\DOL Calibration\Data\sigi\3ChannelsMask\15min\gSEP 0,1nM\gSEP_0,1nM_01_blue.tif';
    maskpath = strrep(filepath,'blue','mask');
    
    im = imread(filepath);
    mask = imread(maskpath);
    [B,~] = bwboundaries(mask,'noholes');
    axes(handles.ax);
    cla
    image(im, 'CDataMapping','scaled')
    handles.ax.XTickLabel = '';
    hold on
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    
    filepath = handles.blueTifList{ListIndex};    
    [thisCellType, thisincubation_time, thisconcentration, thisreplicate] = conditions(filepath);    
    dataSet = handles.dataSet;
    dataSetIndex = findIndex(thisCellType, thisincubation_time, thisconcentration, thisreplicate, dataSet);
    
    if ~handles.valid(dataSetIndex)
        plot(handles.ax.XLim, handles.ax.YLim, 'Color', 'r', 'LineWidth', 3);
        plot(flip(handles.ax.XLim), handles.ax.YLim, 'Color', 'r', 'LineWidth', 3);
    end
    
    handles.index.String = num2str(ListIndex);

end

function loadData(varargin)

    handles = guidata(gcbf);
    
    [filename, pathname, filterindex] = uigetfile('*_cherryPicking.mat');
    
    load(fullfile(pathname, filename));
    
    if ~isequal(cherryPick.CellType, handles.dataSet.CellType) ||...
            ~isequal(cherryPick.incubation_time, handles.dataSet.incubation_time) ||...
            ~isequal(cherryPick.concentration, handles.dataSet.concentration) ||...
            ~isequal(cherryPick.replicate, handles.dataSet.replicate)
        errordlg('loaded data not matching loaded analysis mat file');
        return
    end
    
    handles.valid = cherryPick.valid;

    guidata(gcbf, handles);

end

function saveData(varargin)

    handles = guidata(gcbf);
    
    cherryPick = handles.dataSet;
    cherryPick.valid = handles.valid;
    
    savepath = [handles.matFilePath(1:end-4) '_cherryPicking.mat'];
    
    uisave('cherryPick', savepath);
    
end

function goToIndex(hObject, eventdata)

    handles = guidata(gcbf);
    handles.blueTifListIndex = str2num(hObject.String);
    
    guidata(gcf, handles);
    
    displayImage(handles.blueTifListIndex)
    
end

function closeWindow(varargin)
    
    handles = guidata(gcbf);
    
    button = questdlg('Save before closing?', '', 'Yes', 'No', 'Cancel', 'Cancel');
    
    switch button
        case 'Yes'
            saveData();
            delete(gcbf);
        case 'No'
            delete(gcbf);
        case 'Cancel'
            return
    end
    
end
    
function output = findBlueTif(path)
    
    rootdir = path;
    blueTifList = cell(0);
    folder(rootdir);
    
    function folder(path)
    
    dirlist = dir(path);
    
    for j=3:length(dirlist)
        filename = dirlist(j).name;
        newpath = fullfile(path, filename);
        if isdir(newpath)
            folder(newpath);
        elseif contains(dirlist(j).name, 'blue.tif')
            disp(newpath);
            blueTifList = [blueTifList; newpath];
        end
    end
    
    end
    
    output = blueTifList;

end

function temp(filepath, dataSet)
    
    [thisCellType, thisincubation_time, thisconcentration, thisreplicate] = conditions(filepath);
    
    index = findIndex(thisCellType, thisincubation_time, thisconcentration, thisreplicate, dataSet);
    
end

function [CellType, incubation_time, concentration, replicate] = conditions(path)

    % CellType
    if strfind(path, 'LynG')
        CellType = 'LynG';
    elseif strfind(path, 'gSEP')
        CellType = 'gSEP';
    else
        CellType = '?';
    end

    % incubation time
    incubation_time_temp=path;
    if strfind(incubation_time_temp, 'overnight')
        incubation_time_temp=16;
    elseif strfind(incubation_time_temp, '15min')
            incubation_time_temp=0.25;
    elseif strfind(incubation_time_temp, '30min')
            incubation_time_temp=0.5;
    elseif strfind(incubation_time_temp, '60min')
            incubation_time_temp=1;
    elseif strfind(incubation_time_temp, '3h')
            incubation_time_temp=3;
    end
    incubation_time=incubation_time_temp;

    % concentration
    nMIndex = max(strfind(path, 'nM'));
    underscoreIndex = strfind(path, '_');
    Cstart = max(underscoreIndex(underscoreIndex<nMIndex)) + 1;
    Cend = nMIndex - 1;
    conc = path(Cstart:Cend);
    if strfind(conc, ',')
        conc = strrep(conc, ',', '.');
    end
    concentration = str2double(conc);

    % replicate number
    replicate = str2double(path(nMIndex+3:nMIndex+4));
    
end

function index = findIndex(CellType, incubation_time, concentration, replicate, dataSet)
    
    index = find(strcmp(dataSet.CellType,CellType) &...
    dataSet.incubation_time == incubation_time &...
    dataSet.concentration == concentration &...
    dataSet.replicate == replicate);
    
end