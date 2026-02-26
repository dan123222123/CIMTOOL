classdef PreferencesDialog < handle
    % PREFERENCESDIALOG Modal dialog for editing CIMTOOL style preferences
    %
    % This dialog provides a tabbed interface for customizing plot styles with
    % Apply/OK/Cancel/Reset workflow. Changes are saved to MATLAB's preferences
    % system and applied to the CIMData object.
    %
    % Usage:
    %   dlg = GUI.PreferencesDialog(parentFig, mainApp, cimData);
    %
    % The dialog creates a working copy of preferences that is only applied
    % when the user clicks Apply or OK. Cancel reverts to the original state.

    properties (Access = private)
        Figure              % Modal uifigure
        GridLayout          % Main grid layout
        TabGroup            % Tab container
        ButtonPanel         % Panel for buttons

        % Tabs (to be created)
        ContourTab          % GUI.Preferences.ContourTab
        MarkersTab          % GUI.Preferences.MarkersTab
        AxesTab             % GUI.Preferences.AxesTab
        LegendTab           % GUI.Preferences.LegendTab

        % Buttons
        ResetButton
        CancelButton
        ApplyButton
        OKButton

        % Data
        MainApp             % Reference to main CIMTOOL app
        CIMData             % Reference to CIM data object
        WorkingPreferences  % Working copy of StylePreferences
        OriginalPreferences % Original preferences for Cancel
    end

    methods
        function obj = PreferencesDialog(parentFig, mainApp, cimData)
            % PREFERENCESDIALOG Create and show preferences dialog
            %
            % Args:
            %   parentFig - Parent figure (for modal positioning)
            %   mainApp - Main CIMTOOL app instance
            %   cimData - Visual.CIM object with StylePreferences

            arguments
                parentFig
                mainApp
                cimData Visual.CIM
            end

            obj.MainApp = mainApp;
            obj.CIMData = cimData;

            % Create working copy of preferences
            obj.OriginalPreferences = cimData.StylePreferences;
            obj.WorkingPreferences = Visual.StylePreferences.fromStruct(obj.OriginalPreferences.toStruct());

            % Create modal figure
            obj.createFigure(parentFig);

            % Create tabs and controls
            obj.createTabs();

            % Create buttons
            obj.createButtons();

            % Show the dialog (non-modal for debugging)
            % uiwait(obj.Figure);  % Commented out for non-modal behavior
        end

        function delete(obj)
            % DELETE Clean up dialog when closed
            if isvalid(obj.Figure)
                delete(obj.Figure);
            end
        end
    end

    methods (Access = private)
        function createFigure(obj, parentFig)
            % Create modal dialog figure

            % Calculate position centered on parent
            if ~isempty(parentFig) && isvalid(parentFig)
                parentPos = parentFig.Position;
                width = 650;
                height = 600;
                x = parentPos(1) + (parentPos(3) - width) / 2;
                y = parentPos(2) + (parentPos(4) - height) / 2;
                pos = [x, y, width, height];
            else
                pos = [100, 100, 650, 600];
            end

            obj.Figure = uifigure('Name', 'CIMTOOL Preferences', ...
                                 'Position', pos, ...
                                 'WindowStyle', 'normal', ...
                                 'Resize', 'on', ...
                                 'CloseRequestFcn', @(~,~)obj.onCancel());

            % Create main grid layout (2 rows: tabs + buttons)
            obj.GridLayout = uigridlayout(obj.Figure, [2, 1]);
            obj.GridLayout.RowHeight = {'1x', 50};  % Tabs take remaining space, buttons fixed height
            obj.GridLayout.Padding = [10 10 10 10];
            obj.GridLayout.RowSpacing = 10;
        end

        function createTabs(obj)
            % Create tab group and preference tabs

            obj.TabGroup = uitabgroup(obj.GridLayout);
            obj.TabGroup.Layout.Row = 1;
            obj.TabGroup.Layout.Column = 1;

            % Create individual tabs
            % Note: Tab classes will be created in task #8
            try
                % Contour tab
                tab1 = uitab(obj.TabGroup, 'Title', 'Contour & Quadrature');
                obj.ContourTab = GUI.Preferences.ContourTab(tab1, obj.WorkingPreferences);

                % Markers tab
                tab2 = uitab(obj.TabGroup, 'Title', 'Markers & Points');
                obj.MarkersTab = GUI.Preferences.MarkersTab(tab2, obj.WorkingPreferences);

                % Axes tab
                tab3 = uitab(obj.TabGroup, 'Title', 'Axes & Grid');
                obj.AxesTab = GUI.Preferences.AxesTab(tab3, obj.WorkingPreferences);

                % Legend tab
                tab4 = uitab(obj.TabGroup, 'Title', 'Legend');
                obj.LegendTab = GUI.Preferences.LegendTab(tab4, obj.WorkingPreferences);
            catch ME
                % If tabs don't exist yet, create placeholder
                if contains(ME.message, 'GUI.Preferences')
                    tab = uitab(obj.TabGroup, 'Title', 'Preferences');
                    uilabel(tab, 'Position', [20, 200, 500, 50], ...
                           'Text', 'Preference tabs not yet implemented.', ...
                           'FontSize', 14, ...
                           'HorizontalAlignment', 'center');
                else
                    rethrow(ME);
                end
            end
        end

        function createButtons(obj)
            % Create button panel at bottom of dialog

            % Create button panel with grid layout
            obj.ButtonPanel = uipanel(obj.GridLayout);
            obj.ButtonPanel.Layout.Row = 2;
            obj.ButtonPanel.Layout.Column = 1;

            buttonGrid = uigridlayout(obj.ButtonPanel, [1, 5]);
            buttonGrid.ColumnWidth = {120, '1x', 100, 100, 100};  % Reset, spacer, Cancel, Apply, OK
            buttonGrid.RowHeight = {'1x'};
            buttonGrid.Padding = [5 5 5 5];
            buttonGrid.ColumnSpacing = 10;

            % Reset Defaults button (left side)
            obj.ResetButton = uibutton(buttonGrid, ...
                'Text', 'Reset Defaults', ...
                'ButtonPushedFcn', @(~,~)obj.onReset(), ...
                'Tooltip', 'Reset all preferences to factory defaults');
            obj.ResetButton.Layout.Row = 1;
            obj.ResetButton.Layout.Column = 1;

            % Cancel button
            obj.CancelButton = uibutton(buttonGrid, ...
                'Text', 'Cancel', ...
                'ButtonPushedFcn', @(~,~)obj.onCancel(), ...
                'Tooltip', 'Discard changes and close');
            obj.CancelButton.Layout.Row = 1;
            obj.CancelButton.Layout.Column = 3;

            % Apply button
            obj.ApplyButton = uibutton(buttonGrid, ...
                'Text', 'Apply', ...
                'ButtonPushedFcn', @(~,~)obj.onApply(), ...
                'Tooltip', 'Apply changes without closing');
            obj.ApplyButton.Layout.Row = 1;
            obj.ApplyButton.Layout.Column = 4;

            % OK button
            obj.OKButton = uibutton(buttonGrid, ...
                'Text', 'OK', ...
                'ButtonPushedFcn', @(~,~)obj.onOK(), ...
                'Tooltip', 'Apply changes and close');
            obj.OKButton.Layout.Row = 1;
            obj.OKButton.Layout.Column = 5;
        end

        function onReset(obj)
            % Reset all preferences to factory defaults

            % Confirm with user
            answer = uiconfirm(obj.Figure, ...
                'Reset all style preferences to factory defaults?', ...
                'Reset Preferences', ...
                'Options', {'Reset', 'Cancel'}, ...
                'DefaultOption', 2, ...
                'Icon', 'warning');

            if strcmp(answer, 'Reset')
                % Load factory defaults
                obj.WorkingPreferences = Visual.StylePreferences.factoryDefaults();

                % Update all tabs with new values
                obj.updateTabsFromPreferences();
            end
        end

        function onCancel(obj)
            % Discard changes and close dialog

            % Revert CIMData to original preferences
            obj.CIMData.StylePreferences = obj.OriginalPreferences;

            % Close dialog
            if isvalid(obj.Figure)
                % uiresume(obj.Figure);  % Not needed for non-modal
                delete(obj.Figure);
            end
        end

        function onApply(obj)
            % Apply current preferences without closing

            % Collect current values from all tabs
            obj.updatePreferencesFromTabs();

            % Validate preferences
            try
                obj.WorkingPreferences.validate();
            catch ME
                uialert(obj.Figure, ME.message, 'Invalid Preferences');
                return;
            end

            % Save to MATLAB preferences
            obj.WorkingPreferences.save();

            % Apply to CIMData (this triggers re-plot via SetObservable)
            obj.CIMData.StylePreferences = obj.WorkingPreferences;

            % Update original preferences (so Cancel returns to this state)
            obj.OriginalPreferences = Visual.StylePreferences.fromStruct(obj.WorkingPreferences.toStruct());
        end

        function onOK(obj)
            % Apply changes and close dialog

            obj.onApply();

            % Close if apply was successful
            if isvalid(obj.Figure)
                % uiresume(obj.Figure);  % Not needed for non-modal
                delete(obj.Figure);
            end
        end

        function updateTabsFromPreferences(obj)
            % Update all tab controls to reflect WorkingPreferences

            % Each tab will have an updateFromPreferences method
            try
                if ~isempty(obj.ContourTab)
                    obj.ContourTab.updateFromPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.MarkersTab)
                    obj.MarkersTab.updateFromPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.AxesTab)
                    obj.AxesTab.updateFromPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.LegendTab)
                    obj.LegendTab.updateFromPreferences(obj.WorkingPreferences);
                end
            catch
                % Tabs may not implement this method yet
            end
        end

        function updatePreferencesFromTabs(obj)
            % Collect current values from all tabs into WorkingPreferences

            % Each tab will have an applyToPreferences method
            try
                if ~isempty(obj.ContourTab)
                    obj.ContourTab.applyToPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.MarkersTab)
                    obj.MarkersTab.applyToPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.AxesTab)
                    obj.AxesTab.applyToPreferences(obj.WorkingPreferences);
                end
                if ~isempty(obj.LegendTab)
                    obj.LegendTab.applyToPreferences(obj.WorkingPreferences);
                end
            catch
                % Tabs may not implement this method yet
            end
        end
    end
end
