classdef GhostContourTab < GUI.Preferences.PreferenceTab
    % GHOSTCONTOURTAB Preference tab for ghost contour styling

    properties (Access = private)
        % Ghost contour line controls
        GhostContourColorEdit
        GhostContourLineWidthEdit
        GhostContourLineStyleDropdown

        % Ghost center marker controls
        GhostCenterColorEdit
        GhostCenterSizeEdit
        GhostCenterMarkerDropdown

        % Color swatches
        GhostContourColorSwatch
        GhostCenterColorSwatch
    end

    methods
        function obj = GhostContourTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            obj.GhostContourColorEdit.Value = char(prefs.GhostContourColor);
            obj.GhostContourLineWidthEdit.Value = prefs.GhostContourLineWidth;
            obj.GhostContourLineStyleDropdown.Value = char(prefs.GhostContourLineStyle);
            obj.GhostCenterColorEdit.Value = char(prefs.GhostCenterColor);
            obj.GhostCenterSizeEdit.Value = prefs.GhostCenterSize;
            obj.GhostCenterMarkerDropdown.Value = char(prefs.GhostCenterMarker);

            obj.updateSwatchColor(obj.GhostContourColorSwatch, obj.GhostContourColorEdit.Value);
            obj.updateSwatchColor(obj.GhostCenterColorSwatch, obj.GhostCenterColorEdit.Value);
        end

        function applyToPreferences(obj, prefs)
            prefs.GhostContourColor = string(obj.GhostContourColorEdit.Value);
            prefs.GhostContourLineWidth = obj.GhostContourLineWidthEdit.Value;
            prefs.GhostContourLineStyle = string(obj.GhostContourLineStyleDropdown.Value);
            prefs.GhostCenterColor = string(obj.GhostCenterColorEdit.Value);
            prefs.GhostCenterSize = obj.GhostCenterSizeEdit.Value;
            prefs.GhostCenterMarker = string(obj.GhostCenterMarkerDropdown.Value);
        end
    end

    methods (Access = private)
        function createControls(obj)
            obj.Layout = obj.makeLayout(20, 160, 150);
            yPos = 480;

            yPos = obj.addHeader(yPos, 'Ghost Contour Line');
            [obj.GhostContourColorEdit, obj.GhostContourColorSwatch, yPos] = ...
                obj.addColorField(yPos, 'Color:', 'Color for ghost contour line');
            [obj.GhostContourLineWidthEdit, yPos] = obj.addNumericField(yPos, 'Line Width:', [0.1 20], 'Ghost contour line width');
            [obj.GhostContourLineStyleDropdown, yPos] = obj.addDropdownField(yPos, 'Line Style:', obj.LINE_STYLE_ITEMS, 'Ghost contour line style');

            yPos = obj.addSeparator(yPos);

            yPos = obj.addHeader(yPos, 'Ghost Center Marker');
            [obj.GhostCenterColorEdit, obj.GhostCenterColorSwatch, yPos] = ...
                obj.addColorField(yPos, 'Color:', 'Color for ghost center marker');
            [obj.GhostCenterSizeEdit, yPos] = obj.addNumericField(yPos, 'Size:', [1 1000], 'Ghost center marker size');
            [obj.GhostCenterMarkerDropdown, yPos] = obj.addDropdownField(yPos, 'Marker:', obj.MARKER_ITEMS, 'Ghost center marker style'); %#ok<NASGU>
        end
    end
end
