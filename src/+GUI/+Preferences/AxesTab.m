classdef AxesTab < GUI.Preferences.PreferenceTab
    % AXESTAB Preference tab for axes and grid styling

    properties (Access = private)
        % Grid controls
        GridVisibleCheckbox
        GridLineStyleDropdown
        GridColorEdit

        % Background
        BackgroundColorEdit

        % Axis labels
        XLabelEdit
        YLabelEdit
        LabelInterpreterDropdown

        % Color swatches
        GridColorSwatch
        BackgroundColorSwatch
    end

    methods
        function obj = AxesTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            obj.GridVisibleCheckbox.Value = strcmpi(prefs.AxesGridVisible, 'on');
            obj.GridLineStyleDropdown.Value = char(prefs.AxesGridLineStyle);

            % Handle grid color (can be string or RGB array)
            try
                if isnumeric(prefs.AxesGridColor)
                    obj.GridColorEdit.Value = sprintf('[%.2f %.2f %.2f]', ...
                        prefs.AxesGridColor(1), prefs.AxesGridColor(2), prefs.AxesGridColor(3));
                elseif isstring(prefs.AxesGridColor) || ischar(prefs.AxesGridColor)
                    obj.GridColorEdit.Value = char(prefs.AxesGridColor);
                else
                    obj.GridColorEdit.Value = '[0.15 0.15 0.15]';
                end
            catch
                obj.GridColorEdit.Value = '[0.15 0.15 0.15]';
            end

            obj.BackgroundColorEdit.Value = char(prefs.AxesBackgroundColor);
            obj.XLabelEdit.Value = char(prefs.AxesXLabelText);
            obj.YLabelEdit.Value = char(prefs.AxesYLabelText);
            obj.LabelInterpreterDropdown.Value = char(prefs.AxesLabelInterpreter);

            obj.updateSwatchColor(obj.GridColorSwatch, obj.GridColorEdit.Value);
            obj.updateSwatchColor(obj.BackgroundColorSwatch, obj.BackgroundColorEdit.Value);
        end

        function applyToPreferences(obj, prefs)
            if obj.GridVisibleCheckbox.Value
                prefs.AxesGridVisible = "on";
            else
                prefs.AxesGridVisible = "off";
            end

            prefs.AxesGridLineStyle = string(obj.GridLineStyleDropdown.Value);

            % Parse grid color (can be string or [R G B])
            gridColorStr = strtrim(obj.GridColorEdit.Value);
            if startsWith(gridColorStr, '[') && endsWith(gridColorStr, ']')
                rgb = str2num(gridColorStr(2:end-1)); %#ok<ST2NM>
                if length(rgb) == 3
                    prefs.AxesGridColor = rgb;
                else
                    prefs.AxesGridColor = string(gridColorStr);
                end
            else
                prefs.AxesGridColor = string(gridColorStr);
            end

            prefs.AxesBackgroundColor = string(obj.BackgroundColorEdit.Value);
            prefs.AxesXLabelText = string(obj.XLabelEdit.Value);
            prefs.AxesYLabelText = string(obj.YLabelEdit.Value);
            prefs.AxesLabelInterpreter = string(obj.LabelInterpreterDropdown.Value);
        end
    end

    methods (Access = private)
        function createControls(obj)
            obj.Layout = obj.makeLayout(20, 160, 150);
            yPos = 480;

            yPos = obj.addHeader(yPos, 'Grid');
            [obj.GridVisibleCheckbox, yPos] = obj.addCheckboxField(yPos, ...
                'Show grid on plots', 'Enable or disable grid lines', 'Grid Visible:');
            [obj.GridLineStyleDropdown, yPos] = obj.addDropdownField(yPos, ...
                'Grid Line Style:', obj.LINE_STYLE_ITEMS, 'Line style for grid');
            [obj.GridColorEdit, obj.GridColorSwatch, yPos] = obj.addColorField(yPos, ...
                'Grid Color:', 'Color name, hex code, or [R G B] triplet (e.g., "[0.15 0.15 0.15]")');

            yPos = obj.addSeparator(yPos);

            yPos = obj.addHeader(yPos, 'Background');
            [obj.BackgroundColorEdit, obj.BackgroundColorSwatch, yPos] = obj.addColorField(yPos, ...
                'Background Color:', 'Axes background color (e.g., "white", "#FFFFFF")');

            yPos = obj.addSeparator(yPos);

            yPos = obj.addHeader(yPos, 'Axis Labels');
            [obj.XLabelEdit, yPos] = obj.addTextField(yPos, 'X-Axis Label:', ...
                'Label text for X-axis (supports LaTeX if interpreter is latex)');
            [obj.YLabelEdit, yPos] = obj.addTextField(yPos, 'Y-Axis Label:', ...
                'Label text for Y-axis (supports LaTeX if interpreter is latex)');
            [obj.LabelInterpreterDropdown, yPos] = obj.addDropdownField(yPos, ...
                'Label Interpreter:', {'latex', 'tex', 'none'}, 'Text interpreter for axis labels'); %#ok<NASGU>

            obj.addInfoText(['Note: LaTeX formatting examples: $\bf{R}$ for bold R, ' ...
                           '$\alpha$ for Greek letters. ' ...
                           'Grid color can be a color name (e.g., "gray"), ' ...
                           'hex code (e.g., "#CCCCCC"), or RGB array (e.g., "[0.8 0.8 0.8]").']);
        end
    end
end
