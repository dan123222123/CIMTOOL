classdef ContourTab < GUI.Preferences.PreferenceTab
    % CONTOURTAB Preference tab for contour and quadrature styling

    properties (Access = private)
        % Contour line controls
        ContourColorEdit
        ContourLineWidthEdit
        ContourLineStyleDropdown

        % Quadrature point controls
        ShowQuadratureCheckbox
        QuadratureColorEdit
        QuadratureMarkerDropdown
        QuadratureSizeEdit

        % Color swatches
        ContourColorSwatch
        QuadratureColorSwatch
    end

    methods
        function obj = ContourTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            obj.ContourColorEdit.Value = char(prefs.ContourColor);
            obj.ContourLineWidthEdit.Value = prefs.ContourLineWidth;
            obj.ContourLineStyleDropdown.Value = char(prefs.ContourLineStyle);

            obj.ShowQuadratureCheckbox.Value = prefs.ShowQuadratureNodes;
            obj.QuadratureColorEdit.Value = char(prefs.QuadratureColor);
            obj.QuadratureMarkerDropdown.Value = char(prefs.QuadratureMarker);
            obj.QuadratureSizeEdit.Value = prefs.QuadratureSize;

            obj.updateSwatchColor(obj.ContourColorSwatch, obj.ContourColorEdit.Value);
            obj.updateSwatchColor(obj.QuadratureColorSwatch, obj.QuadratureColorEdit.Value);
        end

        function applyToPreferences(obj, prefs)
            prefs.ContourColor = string(obj.ContourColorEdit.Value);
            prefs.ContourLineWidth = obj.ContourLineWidthEdit.Value;
            prefs.ContourLineStyle = string(obj.ContourLineStyleDropdown.Value);

            prefs.ShowQuadratureNodes = obj.ShowQuadratureCheckbox.Value;
            prefs.QuadratureColor = string(obj.QuadratureColorEdit.Value);
            prefs.QuadratureMarker = string(obj.QuadratureMarkerDropdown.Value);
            prefs.QuadratureSize = obj.QuadratureSizeEdit.Value;
        end
    end

    methods (Access = private)
        function createControls(obj)
            obj.Layout = obj.makeLayout(20, 160, 150);
            yPos = 480;

            yPos = obj.addHeader(yPos, 'Contour Line');
            [obj.ContourColorEdit, obj.ContourColorSwatch, yPos] = ...
                obj.addColorField(yPos, 'Color:', 'Color name (e.g., "blue") or hex code (e.g., "#0000FF")');
            [obj.ContourLineWidthEdit, yPos] = obj.addNumericField(yPos, 'Line Width:', [0.1 20], 'Line width in points');
            [obj.ContourLineStyleDropdown, yPos] = obj.addDropdownField(yPos, 'Line Style:', obj.LINE_STYLE_ITEMS, 'Line style');

            yPos = obj.addSeparator(yPos);

            yPos = obj.addHeader(yPos, 'Quadrature Points');
            [obj.ShowQuadratureCheckbox, yPos] = obj.addCheckboxField(yPos, 'Show Quadrature Nodes', 'Toggle visibility of quadrature nodes on contour');
            [obj.QuadratureColorEdit, obj.QuadratureColorSwatch, yPos] = ...
                obj.addColorField(yPos, 'Color:', 'Color name or hex code');
            [obj.QuadratureMarkerDropdown, yPos] = obj.addDropdownField(yPos, 'Marker:', obj.MARKER_ITEMS, 'Marker style');
            [obj.QuadratureSizeEdit, yPos] = obj.addNumericField(yPos, 'Size:', [1 1000], 'Marker size in points²'); %#ok<NASGU>
        end
    end
end
