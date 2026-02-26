classdef LegendTab < handle
    % LEGENDTAB Preference tab for legend styling
    %
    % Allows editing of:
    %   - Legend location
    %   - Legend orientation (horizontal/vertical)
    %   - Legend interpreter (latex/tex/none)
    %   - Legend font size

    properties (Access = private)
        Parent
        Preferences

        % Legend controls
        LocationDropdown
        OrientationDropdown
        InterpreterDropdown
        FontSizeEdit
    end

    methods
        function obj = LegendTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            obj.LocationDropdown.Value = char(prefs.LegendLocation);
            obj.OrientationDropdown.Value = char(prefs.LegendOrientation);
            obj.InterpreterDropdown.Value = char(prefs.LegendInterpreter);
            obj.FontSizeEdit.Value = prefs.LegendFontSize;
        end

        function applyToPreferences(obj, prefs)
            prefs.LegendLocation = string(obj.LocationDropdown.Value);
            prefs.LegendOrientation = string(obj.OrientationDropdown.Value);
            prefs.LegendInterpreter = string(obj.InterpreterDropdown.Value);
            prefs.LegendFontSize = obj.FontSizeEdit.Value;
        end
    end

    methods (Access = private)
        function createControls(obj)
            yPos = 300;
            labelWidth = 180;
            fieldWidth = 250;
            rowHeight = 35;
            xLabel = 20;
            xField = xLabel + labelWidth + 10;

            % Section header
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Legend Settings', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight;

            % Location
            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Location:');
            obj.LocationDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'north', 'south', 'east', 'west', 'northeast', 'northwest', ...
                         'southeast', 'southwest', 'northoutside', 'southoutside', ...
                         'eastoutside', 'westoutside', 'northeastoutside', 'northwestoutside', ...
                         'southeastoutside', 'southwestoutside', 'best', 'bestoutside', 'none'}, ...
                'Tooltip', 'Legend position on the plot');
            yPos = yPos - rowHeight;

            % Orientation
            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Orientation:');
            obj.OrientationDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'horizontal', 'vertical'}, ...
                'Tooltip', 'Arrange legend items horizontally or vertically');
            yPos = yPos - rowHeight;

            % Interpreter
            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Interpreter:');
            obj.InterpreterDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'latex', 'tex', 'none'}, ...
                'Tooltip', 'Text interpreter for legend labels');
            yPos = yPos - rowHeight;

            % Font size
            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Font Size:');
            obj.FontSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Limits', [6 24], ...
                'Tooltip', 'Font size for legend text (points)');
            yPos = yPos - rowHeight - 20;

            % Add informational text about locations
            infoText = ['Common locations:' newline ...
                       '• northoutside - Above the plot (default)' newline ...
                       '• northeast - Inside plot, upper right corner' newline ...
                       '• best - MATLAB chooses least obstructive position' newline ...
                       '• none - Hide legend' newline newline ...
                       'Note: LaTeX interpreter allows math symbols and formatting in legend labels.'];

            uilabel(obj.Parent, 'Position', [xLabel, 20, 520, 120], ...
                   'Text', infoText, ...
                   'FontSize', 9, ...
                   'WordWrap', 'on', ...
                   'FontAngle', 'italic', ...
                   'VerticalAlignment', 'top');
        end
    end
end
