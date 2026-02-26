classdef PreferenceTab < handle
    % PREFERENCETAB Base class for preference dialog tabs
    %
    % Provides shared layout helpers for building preference tab UIs:
    %   - addHeader, addSeparator, addInfoText
    %   - addColorField (text field + live color swatch)
    %   - addNumericField, addTextField, addDropdownField, addCheckboxField
    %   - updateSwatchColor (parses color strings for swatch preview)
    %
    % Subclasses set obj.Layout via makeLayout() then call helpers to build UI.

    properties (Access = protected)
        Parent          % Parent uitab
        Preferences     % Reference to working StylePreferences
        Layout          % struct: xLabel, labelWidth, fieldWidth, xField, swatchX, rowHeight, controlHeight, sepWidth
    end

    properties (Constant, Access = protected)
        MARKER_ITEMS = {'+', 'o', '*', '.', 'x', 'square', 'diamond', ...
                        '^', 'v', '>', '<', 'pentagram', 'hexagram'}
        LINE_STYLE_ITEMS = {'-', '--', ':', '-.', 'none'}
    end

    methods (Access = protected)
        function L = makeLayout(~, xLabel, labelWidth, fieldWidth, gap)
            % Build a layout configuration struct
            %   gap - spacing between label and field (default 10)
            if nargin < 5; gap = 10; end
            L.xLabel = xLabel;
            L.labelWidth = labelWidth;
            L.fieldWidth = fieldWidth;
            L.rowHeight = 28;
            L.controlHeight = 22;
            L.xField = xLabel + labelWidth + gap;
            L.swatchX = L.xField + fieldWidth + 5;
            L.sepWidth = labelWidth + gap + fieldWidth;
        end

        % --- Section structure helpers ---

        function yPos = addHeader(obj, yPos, text, fontSize)
            if nargin < 4; fontSize = 12; end
            uilabel(obj.Parent, ...
                'Position', [obj.Layout.xLabel, yPos, 500, obj.Layout.controlHeight], ...
                'Text', text, 'FontWeight', 'bold', 'FontSize', fontSize);
            yPos = yPos - obj.Layout.rowHeight;
        end

        function yPos = addSeparator(obj, yPos, width)
            if nargin < 3; width = obj.Layout.sepWidth; end
            yPos = yPos - 8;
            uipanel(obj.Parent, ...
                'Position', [obj.Layout.xLabel, yPos, width, 1], ...
                'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'none');
            yPos = yPos - 26;
        end

        function addInfoText(obj, text, height)
            if nargin < 3; height = 60; end
            uilabel(obj.Parent, ...
                'Position', [obj.Layout.xLabel, 15, 520, height], ...
                'Text', text, 'FontSize', 9, 'WordWrap', 'on', ...
                'FontAngle', 'italic', 'VerticalAlignment', 'top');
        end

        % --- Control helpers ---

        function [edit, swatch, yPos] = addColorField(obj, yPos, labelText, tooltip)
            if nargin < 4; tooltip = ''; end
            L = obj.Layout;
            uilabel(obj.Parent, ...
                'Position', [L.xLabel, yPos, L.labelWidth, L.controlHeight], ...
                'Text', labelText);
            edit = uieditfield(obj.Parent, 'text', ...
                'Position', [L.xField, yPos, L.fieldWidth, L.controlHeight], ...
                'Tooltip', tooltip);
            swatch = uipanel(obj.Parent, ...
                'Position', [L.swatchX, yPos, 22, L.controlHeight], ...
                'BackgroundColor', [0.94 0.94 0.94], 'BorderType', 'line');
            edit.ValueChangedFcn = @(src, ~) obj.updateSwatchColor(swatch, src.Value);
            yPos = yPos - L.rowHeight;
        end

        function [field, yPos] = addNumericField(obj, yPos, labelText, limits, tooltip)
            if nargin < 4; limits = [0 Inf]; end
            if nargin < 5; tooltip = ''; end
            L = obj.Layout;
            uilabel(obj.Parent, ...
                'Position', [L.xLabel, yPos, L.labelWidth, L.controlHeight], ...
                'Text', labelText);
            field = uieditfield(obj.Parent, 'numeric', ...
                'Position', [L.xField, yPos, L.fieldWidth, L.controlHeight], ...
                'Limits', limits, 'Tooltip', tooltip);
            yPos = yPos - L.rowHeight;
        end

        function [field, yPos] = addTextField(obj, yPos, labelText, tooltip)
            if nargin < 4; tooltip = ''; end
            L = obj.Layout;
            uilabel(obj.Parent, ...
                'Position', [L.xLabel, yPos, L.labelWidth, L.controlHeight], ...
                'Text', labelText);
            field = uieditfield(obj.Parent, 'text', ...
                'Position', [L.xField, yPos, L.fieldWidth, L.controlHeight], ...
                'Tooltip', tooltip);
            yPos = yPos - L.rowHeight;
        end

        function [field, yPos] = addDropdownField(obj, yPos, labelText, items, tooltip)
            if nargin < 5; tooltip = ''; end
            L = obj.Layout;
            uilabel(obj.Parent, ...
                'Position', [L.xLabel, yPos, L.labelWidth, L.controlHeight], ...
                'Text', labelText);
            field = uidropdown(obj.Parent, ...
                'Position', [L.xField, yPos, L.fieldWidth, L.controlHeight], ...
                'Items', items, 'Tooltip', tooltip);
            yPos = yPos - L.rowHeight;
        end

        function [field, yPos] = addCheckboxField(obj, yPos, text, tooltip, labelText)
            % Add a checkbox, optionally preceded by a label
            %   Without labelText: checkbox spans full width from xLabel
            %   With labelText: label at xLabel, checkbox at xField
            if nargin < 4; tooltip = ''; end
            L = obj.Layout;
            if nargin >= 5 && ~isempty(labelText)
                uilabel(obj.Parent, ...
                    'Position', [L.xLabel, yPos, L.labelWidth, L.controlHeight], ...
                    'Text', labelText);
                field = uicheckbox(obj.Parent, ...
                    'Position', [L.xField, yPos, L.fieldWidth, L.controlHeight], ...
                    'Text', text, 'Tooltip', tooltip);
            else
                field = uicheckbox(obj.Parent, ...
                    'Position', [L.xLabel, yPos, L.labelWidth + L.fieldWidth, L.controlHeight], ...
                    'Text', text, 'Tooltip', tooltip);
            end
            yPos = yPos - L.rowHeight;
        end

        function updateSwatchColor(~, swatch, colorStr)
            % Parse a color string and update swatch background
            try
                colorStr = strtrim(colorStr);
                if startsWith(colorStr, '#')
                    swatch.BackgroundColor = sscanf(colorStr(2:end), '%2x%2x%2x', [1 3]) / 255;
                elseif startsWith(colorStr, '[')
                    swatch.BackgroundColor = str2num(colorStr(2:end-1)); %#ok<ST2NM>
                else
                    swatch.BackgroundColor = colorStr;
                end
            catch
                swatch.BackgroundColor = [0.94 0.94 0.94];
            end
        end
    end
end
