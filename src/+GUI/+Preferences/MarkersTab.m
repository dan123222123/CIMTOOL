classdef MarkersTab < handle
    % MARKERSTAB Preference tab for eigenvalue and interpolation point markers
    %
    % Allows editing of:
    %   - Reference eigenvalue markers (from OperatorData)
    %   - Computed eigenvalue markers (from ResultData)
    %   - SPLoewner shift markers
    %   - MPLoewner left/right interpolation point markers
    %   - Singular value line styles

    properties (Access = private)
        Parent
        Preferences

        % Reference eigenvalues
        RefEWColorEdit
        RefEWMarkerDropdown
        RefEWSizeEdit
        RefEWLineWidthEdit

        % Computed eigenvalues
        CompEWColorEdit
        CompEWMarkerDropdown
        CompEWSizeEdit
        CompEWLineWidthEdit

        % SPLoewner shifts
        SPShiftColorEdit
        SPShiftMarkerDropdown
        SPShiftSizeEdit
        SPShiftLineWidthEdit

        % MPLoewner right
        MPRightColorEdit
        MPRightMarkerDropdown
        MPRightSizeEdit
        MPRightLineWidthEdit

        % MPLoewner left
        MPLeftColorEdit
        MPLeftMarkerDropdown
        MPLeftSizeEdit
        MPLeftLineWidthEdit

        % Singular values
        SingValColorEdit
        SingValLineStyleEdit
        SingValMarkerSizeEdit
    end

    methods
        function obj = MarkersTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            % Reference eigenvalues
            obj.RefEWColorEdit.Value = char(prefs.ReferenceEigenvalueColor);
            obj.RefEWMarkerDropdown.Value = char(prefs.ReferenceEigenvalueMarker);
            obj.RefEWSizeEdit.Value = prefs.ReferenceEigenvalueSize;
            obj.RefEWLineWidthEdit.Value = prefs.ReferenceEigenvalueLineWidth;

            % Computed eigenvalues
            obj.CompEWColorEdit.Value = char(prefs.ComputedEigenvalueColor);
            obj.CompEWMarkerDropdown.Value = char(prefs.ComputedEigenvalueMarker);
            obj.CompEWSizeEdit.Value = prefs.ComputedEigenvalueSize;
            obj.CompEWLineWidthEdit.Value = prefs.ComputedEigenvalueLineWidth;

            % SPLoewner
            obj.SPShiftColorEdit.Value = char(prefs.SPLoewnerShiftColor);
            obj.SPShiftMarkerDropdown.Value = char(prefs.SPLoewnerShiftMarker);
            obj.SPShiftSizeEdit.Value = prefs.SPLoewnerShiftSize;
            obj.SPShiftLineWidthEdit.Value = prefs.SPLoewnerShiftLineWidth;

            % MPLoewner right
            obj.MPRightColorEdit.Value = char(prefs.MPLoewnerRightColor);
            obj.MPRightMarkerDropdown.Value = char(prefs.MPLoewnerRightMarker);
            obj.MPRightSizeEdit.Value = prefs.MPLoewnerRightSize;
            obj.MPRightLineWidthEdit.Value = prefs.MPLoewnerRightLineWidth;

            % MPLoewner left
            obj.MPLeftColorEdit.Value = char(prefs.MPLoewnerLeftColor);
            obj.MPLeftMarkerDropdown.Value = char(prefs.MPLoewnerLeftMarker);
            obj.MPLeftSizeEdit.Value = prefs.MPLoewnerLeftSize;
            obj.MPLeftLineWidthEdit.Value = prefs.MPLoewnerLeftLineWidth;

            % Singular values
            obj.SingValColorEdit.Value = char(prefs.SingularValueColor);
            obj.SingValLineStyleEdit.Value = char(prefs.SingularValueLineStyle);
            obj.SingValMarkerSizeEdit.Value = prefs.SingularValueMarkerSize;
        end

        function applyToPreferences(obj, prefs)
            % Reference eigenvalues
            prefs.ReferenceEigenvalueColor = string(obj.RefEWColorEdit.Value);
            prefs.ReferenceEigenvalueMarker = string(obj.RefEWMarkerDropdown.Value);
            prefs.ReferenceEigenvalueSize = obj.RefEWSizeEdit.Value;
            prefs.ReferenceEigenvalueLineWidth = obj.RefEWLineWidthEdit.Value;

            % Computed eigenvalues
            prefs.ComputedEigenvalueColor = string(obj.CompEWColorEdit.Value);
            prefs.ComputedEigenvalueMarker = string(obj.CompEWMarkerDropdown.Value);
            prefs.ComputedEigenvalueSize = obj.CompEWSizeEdit.Value;
            prefs.ComputedEigenvalueLineWidth = obj.CompEWLineWidthEdit.Value;

            % SPLoewner
            prefs.SPLoewnerShiftColor = string(obj.SPShiftColorEdit.Value);
            prefs.SPLoewnerShiftMarker = string(obj.SPShiftMarkerDropdown.Value);
            prefs.SPLoewnerShiftSize = obj.SPShiftSizeEdit.Value;
            prefs.SPLoewnerShiftLineWidth = obj.SPShiftLineWidthEdit.Value;

            % MPLoewner right
            prefs.MPLoewnerRightColor = string(obj.MPRightColorEdit.Value);
            prefs.MPLoewnerRightMarker = string(obj.MPRightMarkerDropdown.Value);
            prefs.MPLoewnerRightSize = obj.MPRightSizeEdit.Value;
            prefs.MPLoewnerRightLineWidth = obj.MPRightLineWidthEdit.Value;

            % MPLoewner left
            prefs.MPLoewnerLeftColor = string(obj.MPLeftColorEdit.Value);
            prefs.MPLoewnerLeftMarker = string(obj.MPLeftMarkerDropdown.Value);
            prefs.MPLoewnerLeftSize = obj.MPLeftSizeEdit.Value;
            prefs.MPLoewnerLeftLineWidth = obj.MPLeftLineWidthEdit.Value;

            % Singular values
            prefs.SingularValueColor = string(obj.SingValColorEdit.Value);
            prefs.SingularValueLineStyle = string(obj.SingValLineStyleEdit.Value);
            prefs.SingularValueMarkerSize = obj.SingValMarkerSizeEdit.Value;
        end
    end

    methods (Access = private)
        function createControls(obj)
            yPos = 360;
            labelWidth = 180;
            fieldWidth = 120;
            rowHeight = 28;
            xLabel = 20;
            xField = xLabel + labelWidth + 10;
            markerItems = {'+', 'o', '*', '.', 'x', 'square', 'diamond', '^', 'v', '>', '<', 'pentagram', 'hexagram'};

            % Use two columns for better space usage
            col2XLabel = 340;
            col2XField = col2XLabel + labelWidth + 10;

            % Column 1: Reference and Computed Eigenvalues
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 300, 22], ...
                   'Text', 'Reference Eigenvalues', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.RefEWColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Marker:');
            obj.RefEWMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 20], 'Items', markerItems);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Size:');
            obj.RefEWSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [1 1000]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Line Width:');
            obj.RefEWLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [0.1 10]);
            yPos = yPos - rowHeight - 10;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, 300, 22], ...
                   'Text', 'Computed Eigenvalues', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.CompEWColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Marker:');
            obj.CompEWMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 20], 'Items', markerItems);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Size:');
            obj.CompEWSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [1 1000]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Line Width:');
            obj.CompEWLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [0.1 10]);

            % Column 2: SPLoewner and MPLoewner
            yPos = 360;
            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, 300, 22], ...
                   'Text', 'SPLoewner Shifts', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.SPShiftColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [col2XField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Marker:');
            obj.SPShiftMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Items', markerItems);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Size:');
            obj.SPShiftSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Limits', [1 1000]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Line Width:');
            obj.SPShiftLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Limits', [0.1 10]);
            yPos = yPos - rowHeight - 10;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, 300, 22], ...
                   'Text', 'MPLoewner Right Points', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.MPRightColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [col2XField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Marker:');
            obj.MPRightMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Items', markerItems);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Size:');
            obj.MPRightSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Limits', [1 1000]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Line Width:');
            obj.MPRightLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Limits', [0.1 10]);

            % Bottom section: MPLoewner Left and Singular Values
            yPos = 140;
            uilabel(obj.Parent, 'Position', [xLabel, yPos, 300, 22], ...
                   'Text', 'MPLoewner Left Points', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.MPLeftColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [xField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Marker:');
            obj.MPLeftMarkerDropdown = uidropdown(obj.Parent, ...
                'Position', [xField, yPos, fieldWidth, 20], 'Items', markerItems);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Size:');
            obj.MPLeftSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [1 1000]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [xLabel, yPos, labelWidth, 20], 'Text', 'Line Width:');
            obj.MPLeftLineWidthEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [xField, yPos, fieldWidth, 20], 'Limits', [0.1 10]);

            yPos = 140;
            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, 300, 22], ...
                   'Text', 'Singular Values', 'FontWeight', 'bold', 'FontSize', 11);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Color:');
            obj.SingValColorEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [col2XField, yPos, fieldWidth, 20]);
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Line Style:');
            obj.SingValLineStyleEdit = uieditfield(obj.Parent, 'text', ...
                'Position', [col2XField, yPos, fieldWidth, 20], ...
                'Tooltip', 'e.g., "->" for line with markers');
            yPos = yPos - rowHeight;

            uilabel(obj.Parent, 'Position', [col2XLabel, yPos, labelWidth, 20], 'Text', 'Marker Size:');
            obj.SingValMarkerSizeEdit = uieditfield(obj.Parent, 'numeric', ...
                'Position', [col2XField, yPos, fieldWidth, 20], 'Limits', [1 100]);
        end
    end
end
