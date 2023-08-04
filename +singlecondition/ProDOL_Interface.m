classdef ProDOL_Interface < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        ChannelstoanalyseLabel          matlab.ui.control.Label
        ChannelstoanalyseDropDown       matlab.ui.control.DropDown
        EditField_7                     matlab.ui.control.EditField
        EditField_6                     matlab.ui.control.EditField
        SNAPtagdyeLabel                 matlab.ui.control.Label
        HaloTagdyeLabel                 matlab.ui.control.Label
        ProDOLanalysisLabel             matlab.ui.control.Label
        RunProDOLanalysisButton         matlab.ui.control.Button
        ThunderSTORMfoldernameLabel     matlab.ui.control.Label
        ChannelsmaskfoldernameLabel     matlab.ui.control.Label
        EditField_5                     matlab.ui.control.EditField
        EditField_4                     matlab.ui.control.EditField
        SelectsoftwarerootfolderButton  matlab.ui.control.Button
        EditField_3                     matlab.ui.control.EditField
        EditField_2                     matlab.ui.control.NumericEditField
        PixelwidthnmLabel               matlab.ui.control.Label
        EditField                       matlab.ui.control.EditField
        SelectdatarootfolderButton      matlab.ui.control.Button
        ContextMenu                     matlab.ui.container.ContextMenu
        Menu                            matlab.ui.container.Menu
        Menu2                           matlab.ui.container.Menu
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SelectdatarootfolderButton
        function SelectdatarootfolderButtonPushed(app, event)
            rootfolder = uigetdir('C:\');
            app.EditField.Value=rootfolder;
            figure(app.UIFigure);
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value1 = app.EditField.Value;
            
        end

        % Value changed function: EditField_2
        function EditField_2ValueChanged(app, event)
            pixelsize = app.EditField_2.Value;
            
        end

        % Value changed function: EditField_3
        function EditField_3ValueChanged(app, event)
            value3 = app.EditField_3.Value;

        end

        % Button pushed function: SelectsoftwarerootfolderButton
        function SelectsoftwarerootfolderButtonPushed(app, event)
            dolP = uigetdir('C:\');
            app.EditField_3.Value=dolP;
            figure(app.UIFigure);
        end

        % Button pushed function: RunProDOLanalysisButton
        function RunProDOLanalysisButtonPushed(app, event)
            assignin('base','pixelsize',app.EditField_2.Value)
            assignin('base','dolP',app.EditField_3.Value)
            assignin('base','rootfolder',app.EditField.Value)
            assignin('base','expressionCh',app.EditField_4.Value)
            assignin('base','expressionTS',app.EditField_5.Value)
            assignin('base','dye_Halo',app.EditField_6.Value)
            assignin('base','dye_SNAP',app.EditField_7.Value)
            assignin('base','AnalysisOption',app.ChannelstoanalyseDropDown.Value)
            delete(app)
        end

        % Value changed function: EditField_7
        function EditField_7ValueChanged(app, event)
            value7 = app.EditField_7.Value;
            
        end

        % Value changed function: EditField_6
        function EditField_6ValueChanged(app, event)
            value6 = app.EditField_6.Value;
            
        end

        % Value changed function: ChannelstoanalyseDropDown
        function ChannelstoanalyseDropDownValueChanged(app, event)
            valuedrop = app.ChannelstoanalyseDropDown.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 572 377];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {117, '1x', 45, 117, '1x', 45};
            app.GridLayout.RowHeight = {55, 22, 22, 36, 36, 36, 36, 40};

            % Create SelectdatarootfolderButton
            app.SelectdatarootfolderButton = uibutton(app.GridLayout, 'push');
            app.SelectdatarootfolderButton.ButtonPushedFcn = createCallbackFcn(app, @SelectdatarootfolderButtonPushed, true);
            app.SelectdatarootfolderButton.Layout.Row = 5;
            app.SelectdatarootfolderButton.Layout.Column = 1;
            app.SelectdatarootfolderButton.Text = {'Select data'; 'root folder'};

            % Create EditField
            app.EditField = uieditfield(app.GridLayout, 'text');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Layout.Row = 5;
            app.EditField.Layout.Column = [2 6];
            app.EditField.Value = 'E:\ProDOL-App\ExampleData';

            % Create PixelwidthnmLabel
            app.PixelwidthnmLabel = uilabel(app.GridLayout);
            app.PixelwidthnmLabel.Layout.Row = 2;
            app.PixelwidthnmLabel.Layout.Column = 1;
            app.PixelwidthnmLabel.Text = 'Pixelwidth [nm]';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.GridLayout, 'numeric');
            app.EditField_2.Limits = [0 Inf];
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.EditField_2.Layout.Row = 2;
            app.EditField_2.Layout.Column = [2 3];
            app.EditField_2.Value = 105.6;

            % Create EditField_3
            app.EditField_3 = uieditfield(app.GridLayout, 'text');
            app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            app.EditField_3.Layout.Row = 4;
            app.EditField_3.Layout.Column = [2 6];
            app.EditField_3.Value = 'E:\ProDOL-App\DOL_Github';

            % Create SelectsoftwarerootfolderButton
            app.SelectsoftwarerootfolderButton = uibutton(app.GridLayout, 'push');
            app.SelectsoftwarerootfolderButton.ButtonPushedFcn = createCallbackFcn(app, @SelectsoftwarerootfolderButtonPushed, true);
            app.SelectsoftwarerootfolderButton.Layout.Row = 4;
            app.SelectsoftwarerootfolderButton.Layout.Column = 1;
            app.SelectsoftwarerootfolderButton.Text = {'Select software'; 'root folder'};

            % Create EditField_4
            app.EditField_4 = uieditfield(app.GridLayout, 'text');
            app.EditField_4.Layout.Row = 6;
            app.EditField_4.Layout.Column = [2 6];
            app.EditField_4.Value = '3Channels_Mask';

            % Create EditField_5
            app.EditField_5 = uieditfield(app.GridLayout, 'text');
            app.EditField_5.Layout.Row = 7;
            app.EditField_5.Layout.Column = [2 6];
            app.EditField_5.Value = 'ThunderSTORM_results';

            % Create ChannelsmaskfoldernameLabel
            app.ChannelsmaskfoldernameLabel = uilabel(app.GridLayout);
            app.ChannelsmaskfoldernameLabel.Layout.Row = 6;
            app.ChannelsmaskfoldernameLabel.Layout.Column = 1;
            app.ChannelsmaskfoldernameLabel.Text = {'Channels & mask'; 'folder name'};

            % Create ThunderSTORMfoldernameLabel
            app.ThunderSTORMfoldernameLabel = uilabel(app.GridLayout);
            app.ThunderSTORMfoldernameLabel.Layout.Row = 7;
            app.ThunderSTORMfoldernameLabel.Layout.Column = 1;
            app.ThunderSTORMfoldernameLabel.Text = {'ThunderSTORM '; 'folder name'};

            % Create RunProDOLanalysisButton
            app.RunProDOLanalysisButton = uibutton(app.GridLayout, 'push');
            app.RunProDOLanalysisButton.ButtonPushedFcn = createCallbackFcn(app, @RunProDOLanalysisButtonPushed, true);
            app.RunProDOLanalysisButton.Layout.Row = 8;
            app.RunProDOLanalysisButton.Layout.Column = [1 6];
            app.RunProDOLanalysisButton.Text = 'Run ProDOL analysis';

            % Create ProDOLanalysisLabel
            app.ProDOLanalysisLabel = uilabel(app.GridLayout);
            app.ProDOLanalysisLabel.FontSize = 28;
            app.ProDOLanalysisLabel.Layout.Row = 1;
            app.ProDOLanalysisLabel.Layout.Column = [1 3];
            app.ProDOLanalysisLabel.Text = 'ProDOL analysis ';

            % Create HaloTagdyeLabel
            app.HaloTagdyeLabel = uilabel(app.GridLayout);
            app.HaloTagdyeLabel.Layout.Row = 2;
            app.HaloTagdyeLabel.Layout.Column = 4;
            app.HaloTagdyeLabel.Text = 'HaloTag dye';

            % Create SNAPtagdyeLabel
            app.SNAPtagdyeLabel = uilabel(app.GridLayout);
            app.SNAPtagdyeLabel.Layout.Row = 3;
            app.SNAPtagdyeLabel.Layout.Column = 4;
            app.SNAPtagdyeLabel.Text = 'SNAPtag dye';

            % Create EditField_6
            app.EditField_6 = uieditfield(app.GridLayout, 'text');
            app.EditField_6.ValueChangedFcn = createCallbackFcn(app, @EditField_6ValueChanged, true);
            app.EditField_6.Layout.Row = 2;
            app.EditField_6.Layout.Column = [5 6];
            app.EditField_6.Value = 'Halo-SiR';

            % Create EditField_7
            app.EditField_7 = uieditfield(app.GridLayout, 'text');
            app.EditField_7.ValueChangedFcn = createCallbackFcn(app, @EditField_7ValueChanged, true);
            app.EditField_7.Layout.Row = 3;
            app.EditField_7.Layout.Column = [5 6];
            app.EditField_7.Value = 'SNAP-TMR';

            % Create ChannelstoanalyseDropDown
            app.ChannelstoanalyseDropDown = uidropdown(app.GridLayout);
            app.ChannelstoanalyseDropDown.Items = {'HaloTag', 'SNAPtag', 'Both Channels'};
            app.ChannelstoanalyseDropDown.ValueChangedFcn = createCallbackFcn(app, @ChannelstoanalyseDropDownValueChanged, true);
            app.ChannelstoanalyseDropDown.Layout.Row = 3;
            app.ChannelstoanalyseDropDown.Layout.Column = [2 3];
            app.ChannelstoanalyseDropDown.Value = 'Both Channels';

            % Create ChannelstoanalyseLabel
            app.ChannelstoanalyseLabel = uilabel(app.GridLayout);
            app.ChannelstoanalyseLabel.Layout.Row = 3;
            app.ChannelstoanalyseLabel.Layout.Column = 1;
            app.ChannelstoanalyseLabel.Text = 'Channels to analyse';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';
            
            % Assign app.ContextMenu
            app.HaloTagdyeLabel.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProDOL_Interface

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end