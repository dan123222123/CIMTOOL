classdef LegendTab < GUI.Preferences.PreferenceTab
    % LEGENDTAB Preference tab for legend styling

    properties (Access = private)
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
            obj.Layout = obj.makeLayout(20, 160, 150);
            yPos = 480;

            yPos = obj.addHeader(yPos, 'Legend Settings');
            [obj.LocationDropdown, yPos] = obj.addDropdownField(yPos, 'Location:', ...
                {'north', 'south', 'east', 'west', 'northeast', 'northwest', ...
                 'southeast', 'southwest', 'northoutside', 'southoutside', ...
                 'eastoutside', 'westoutside', 'northeastoutside', 'northwestoutside', ...
                 'southeastoutside', 'southwestoutside', 'best', 'bestoutside', 'none'}, ...
                'Legend position on the plot');
            [obj.OrientationDropdown, yPos] = obj.addDropdownField(yPos, 'Orientation:', ...
                {'horizontal', 'vertical'}, 'Arrange legend items horizontally or vertically');
            [obj.InterpreterDropdown, yPos] = obj.addDropdownField(yPos, 'Interpreter:', ...
                {'latex', 'tex', 'none'}, 'Text interpreter for legend labels');
            [obj.FontSizeEdit, yPos] = obj.addNumericField(yPos, 'Font Size:', ...
                [6 24], 'Font size for legend text (points)'); %#ok<NASGU>

            obj.addInfoText( ...
                ['Common locations:' newline ...
                 char(8226) ' northoutside - Above the plot (default)' newline ...
                 char(8226) ' northeast - Inside plot, upper right corner' newline ...
                 char(8226) ' best - MATLAB chooses least obstructive position' newline ...
                 char(8226) ' none - Hide legend' newline newline ...
                 'Note: LaTeX interpreter allows math symbols and formatting in legend labels.'], ...
                120);
        end
    end
end
