classdef ContourTab < handle
    % CONTOURTAB Preference tab for contour and quadrature styling
    %
    % Allows editing of:
    %   - Contour line color, width, and style
    %   - Quadrature point color, marker, and size
    %   - Ghost contour color, width, style, and center marker

    properties (Access = private)
        Parent              % Parent uitab
        Preferences         % Reference to working StylePreferences

        % Contour line controls
        ContourColorEdit
        ContourLineWidthEdit
        ContourLineStyleDropdown

        % Quadrature point controls
        ShowQuadratureCheckbox
        QuadratureColorEdit
        QuadratureMarkerDropdown
        QuadratureSizeEdit

        % Ghost contour controls
        GhostContourColorEdit
        GhostContourLineWidthEdit
        GhostContourLineStyleDropdown
        GhostCenterColorEdit
        GhostCenterSizeEdit
        GhostCenterMarkerDropdown
    end

    methods
        function obj = ContourTab(parent, preferences)
            % CONTOURTAB Create contour preferences tab
            %
            % Args:
            %   parent - Parent uitab
            %   preferences - Visual.StylePreferences object

            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            % Update UI controls from StylePreferences object

            % Contour line
            obj.ContourColorEdit.Value = char(prefs.ContourColor);
            obj.ContourLineWidthEdit.Value = prefs.ContourLineWidth;
            obj.ContourLineStyleDropdown.Value = char(prefs.ContourLineStyle);

            % Quadrature points
            obj.ShowQuadratureCheckbox.Value = prefs.ShowQuadratureNodes;
            obj.QuadratureColorEdit.Value = char(prefs.QuadratureColor);
            obj.QuadratureMarkerDropdown.Value = char(prefs.QuadratureMarker);
            obj.QuadratureSizeEdit.Value = prefs.QuadratureSize;

            % Ghost contour
            obj.GhostContourColorEdit.Value = char(prefs.GhostContourColor);
            obj.GhostContourLineWidthEdit.Value = prefs.GhostContourLineWidth;
            obj.GhostContourLineStyleDropdown.Value = char(prefs.GhostContourLineStyle);
            obj.GhostCenterColorEdit.Value = char(prefs.GhostCenterColor);
            obj.GhostCenterSizeEdit.Value = prefs.GhostCenterSize;
            obj.GhostCenterMarkerDropdown.Value = char(prefs.GhostCenterMarker);
        end

        function applyToPreferences(obj, prefs)
            % Apply current UI values to StylePreferences object

            % Contour line
            prefs.ContourColor = string(obj.ContourColorEdit.Value);
            prefs.ContourLineWidth = obj.ContourLineWidthEdit.Value;
            prefs.ContourLineStyle = string(obj.ContourLineStyleDropdown.Value);

            % Quadrature points
            prefs.ShowQuadratureNodes = obj.ShowQuadratureCheckbox.Value;
            prefs.QuadratureColor = string(obj.QuadratureColorEdit.Value);
            prefs.QuadratureMarker = string(obj.QuadratureMarkerDropdown.Value);
            prefs.QuadratureSize = obj.QuadratureSizeEdit.Value;

            % Ghost contour
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
            % Create all UI controls for this tab

            yPos = 350;
            labelWidth = 180;
            fieldWidth = 150;
            rowHeight = 30;
            xLabel = 20;
            xField = xLabel + labelWidth + 10;

            % Section: Contour Line
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Contour Line', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Color:');
            obj.ContourColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Color name (e.g., "blue") or hex code (e.g., "#0000FF")');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Line Width:');
            obj.ContourLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Limits', [0.1 20], ...
                'Tooltip', 'Line width in points');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Line Style:');
            obj.ContourLineStyleDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'-', '--', ':', '-.', 'none'}, ...
                'Tooltip', 'Line style');
            yPos = yPos - rowHeight - 10;

            % Section: Quadrature Points
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Quadrature Points', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            obj.ShowQuadratureCheckbox = uicheckbox(obj.Parent, ...
                'Position', [xLabel, yPos, labelWidth + fieldWidth, 22], ...
                'Text', 'Show Quadrature Nodes', ...
                'Tooltip', 'Toggle visibility of quadrature nodes on contour');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Color:');
            obj.QuadratureColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Color name or hex code');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Marker:');
            obj.QuadratureMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'+', 'o', '*', '.', 'x', 'square', 'diamond', '^', 'v', '>', '<', 'pentagram', 'hexagram'}, ...
                'Tooltip', 'Marker style');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Size:');
            obj.QuadratureSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Limits', [1 1000], ...
                'Tooltip', 'Marker size in points²');
            yPos = yPos - rowHeight - 10;

            % Section: Ghost Contour (Interactive Preview)
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 500, 25], ...
                   'Text', 'Ghost Contour (Interactive Preview)', 'FontWeight', 'bold', 'FontSize', 12);
            yPos = yPos - rowHeight - 5;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Contour Color:');
            obj.GhostContourColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Color for ghost contour line');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Contour Line Width:');
            obj.GhostContourLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Limits', [0.1 20], ...
                'Tooltip', 'Ghost contour line width');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Contour Line Style:');
            obj.GhostContourLineStyleDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'-', '--', ':', '-.', 'none'}, ...
                'Tooltip', 'Ghost contour line style');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Center Marker Color:');
            obj.GhostCenterColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Tooltip', 'Color for ghost center marker');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Center Marker Size:');
            obj.GhostCenterSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Limits', [1 1000], ...
                'Tooltip', 'Ghost center marker size');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 22], 'Text', 'Center Marker:');
            obj.GhostCenterMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 22], ...
                'Items', {'+', 'o', '*', '.', 'x', 'square', 'diamond', '^', 'v', '>', '<', 'pentagram', 'hexagram'}, ...
                'Tooltip', 'Ghost center marker style');
        end
    end
end
