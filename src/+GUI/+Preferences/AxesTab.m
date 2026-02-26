classdef AxesTab < handle
    % AXESTAB Preference tab for axes and grid styling
    %
    % Allows editing of:
    %   - Grid visibility, line style, and color
    %   - Axes background color
    %   - X and Y axis label text and interpreter

    properties (Access = private)
        Parent
        Preferences

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
                    % Fallback for unexpected type
                    warning('AxesTab:UnexpectedGridColorType', ...
                            'AxesGridColor has unexpected type: %s. Using default.', class(prefs.AxesGridColor));
                    obj.GridColorEdit.Value = '[0.15 0.15 0.15]';
                end
            catch ME
                warning('AxesTab:GridColorError', ...
                        'Error setting grid color: %s. Using default.', ME.message);
                obj.GridColorEdit.Value = '[0.15 0.15 0.15]';
            end

            obj.BackgroundColorEdit.Value = char(prefs.AxesBackgroundColor);
            obj.XLabelEdit.Value = char(prefs.AxesXLabelText);
            obj.YLabelEdit.Value = char(prefs.AxesYLabelText);
            obj.LabelInterpreterDropdown.Value = char(prefs.AxesLabelInterpreter);
        end

        function applyToPreferences(obj, prefs)
            prefs.AxesGridVisible = string(obj.GridVisibleCheckbox.Value * 1);  % 1='on', 0='off'
            if obj.GridVisibleCheckbox.Value
                prefs.AxesGridVisible = "on";
            else
                prefs.AxesGridVisible = "off";
            end

            prefs.AxesGridLineStyle = string(obj.GridLineStyleDropdown.Value);

            % Parse grid color (can be string or [R G B])
            gridColorStr = strtrim(obj.GridColorEdit.Value);
            if startsWith(gridColorStr, '[') && endsWith(gridColorStr, ']')
                % Parse as RGB array
                rgbStr = gridColorStr(2:end-1);
                rgb = str2num(rgbStr); %#ok<ST2NM>
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
            yPos = 350;
            labelWidth = 180;
            fieldWidth = 250;
            rowHeight = 30;
            xLabel = 20;
            xField = xLabel + labelWidth + 10;

            % Section: Grid
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Grid', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Grid Visible:');
            obj.GridVisibleCheckbox = uicheckbox(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Text', 'Show grid on plots', ...
                'Tooltip', 'Enable or disable grid lines');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Grid Line Style:');
            obj.GridLineStyleDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'-', '--', ':', '-.', 'none'}, ...
                'Tooltip', 'Line style for grid');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Grid Color:');
            obj.GridColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Color name, hex code, or [R G B] triplet (e.g., "[0.15 0.15 0.15]")');
            yPos = yPos - rowHeight - 15;

            % Section: Background
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Background', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Background Color:');
            obj.BackgroundColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Axes background color (e.g., "white", "#FFFFFF")');
            yPos = yPos - rowHeight - 15;

            % Section: Axis Labels
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Axis Labels', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'X-Axis Label:');
            obj.XLabelEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Label text for X-axis (supports LaTeX if interpreter is latex)');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Y-Axis Label:');
            obj.YLabelEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Label text for Y-axis (supports LaTeX if interpreter is latex)');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Label Interpreter:');
            obj.LabelInterpreterDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'latex', 'tex', 'none'}, ...
                'Tooltip', 'Text interpreter for axis labels');
            yPos = yPos - rowHeight - 15;

            % Add informational text
            uilabel(obj.Parent, 'Position', [xLabel, 20, 520, 60], ...
                   'Text', ['Note: LaTeX formatting examples: $\bf{R}$ for bold R, ' ...
                           '$\alpha$ for Greek letters. ' ...
                           'Grid color can be a color name (e.g., "gray"), ' ...
                           'hex code (e.g., "#CCCCCC"), or RGB array (e.g., "[0.8 0.8 0.8]").'], ...
                   'FontSize', 9, ...
                   'WordWrap', 'on', ...
                   'FontAngle', 'italic');
        end
    end
end
