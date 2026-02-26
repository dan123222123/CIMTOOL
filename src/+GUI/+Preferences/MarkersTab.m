classdef MarkersTab < GUI.Preferences.PreferenceTab
    % MARKERSTAB Preference tab for eigenvalue and interpolation point markers

    properties (Access = private)
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

        % Color swatches
        RefEWColorSwatch
        CompEWColorSwatch
        SPShiftColorSwatch
        MPRightColorSwatch
        MPLeftColorSwatch
        SingValColorSwatch
    end

    methods
        function obj = MarkersTab(parent, preferences)
            obj.Parent = parent;
            obj.Preferences = preferences;
            obj.createControls();
            obj.updateFromPreferences(preferences);
        end

        function updateFromPreferences(obj, prefs)
            obj.RefEWColorEdit.Value = char(prefs.ReferenceEigenvalueColor);
            obj.RefEWMarkerDropdown.Value = char(prefs.ReferenceEigenvalueMarker);
            obj.RefEWSizeEdit.Value = prefs.ReferenceEigenvalueSize;
            obj.RefEWLineWidthEdit.Value = prefs.ReferenceEigenvalueLineWidth;

            obj.CompEWColorEdit.Value = char(prefs.ComputedEigenvalueColor);
            obj.CompEWMarkerDropdown.Value = char(prefs.ComputedEigenvalueMarker);
            obj.CompEWSizeEdit.Value = prefs.ComputedEigenvalueSize;
            obj.CompEWLineWidthEdit.Value = prefs.ComputedEigenvalueLineWidth;

            obj.SPShiftColorEdit.Value = char(prefs.SPLoewnerShiftColor);
            obj.SPShiftMarkerDropdown.Value = char(prefs.SPLoewnerShiftMarker);
            obj.SPShiftSizeEdit.Value = prefs.SPLoewnerShiftSize;
            obj.SPShiftLineWidthEdit.Value = prefs.SPLoewnerShiftLineWidth;

            obj.MPRightColorEdit.Value = char(prefs.MPLoewnerRightColor);
            obj.MPRightMarkerDropdown.Value = char(prefs.MPLoewnerRightMarker);
            obj.MPRightSizeEdit.Value = prefs.MPLoewnerRightSize;
            obj.MPRightLineWidthEdit.Value = prefs.MPLoewnerRightLineWidth;

            obj.MPLeftColorEdit.Value = char(prefs.MPLoewnerLeftColor);
            obj.MPLeftMarkerDropdown.Value = char(prefs.MPLoewnerLeftMarker);
            obj.MPLeftSizeEdit.Value = prefs.MPLoewnerLeftSize;
            obj.MPLeftLineWidthEdit.Value = prefs.MPLoewnerLeftLineWidth;

            obj.SingValColorEdit.Value = char(prefs.SingularValueColor);
            obj.SingValLineStyleEdit.Value = char(prefs.SingularValueLineStyle);
            obj.SingValMarkerSizeEdit.Value = prefs.SingularValueMarkerSize;

            obj.updateSwatchColor(obj.RefEWColorSwatch, obj.RefEWColorEdit.Value);
            obj.updateSwatchColor(obj.CompEWColorSwatch, obj.CompEWColorEdit.Value);
            obj.updateSwatchColor(obj.SPShiftColorSwatch, obj.SPShiftColorEdit.Value);
            obj.updateSwatchColor(obj.MPRightColorSwatch, obj.MPRightColorEdit.Value);
            obj.updateSwatchColor(obj.MPLeftColorSwatch, obj.MPLeftColorEdit.Value);
            obj.updateSwatchColor(obj.SingValColorSwatch, obj.SingValColorEdit.Value);
        end

        function applyToPreferences(obj, prefs)
            prefs.ReferenceEigenvalueColor = string(obj.RefEWColorEdit.Value);
            prefs.ReferenceEigenvalueMarker = string(obj.RefEWMarkerDropdown.Value);
            prefs.ReferenceEigenvalueSize = obj.RefEWSizeEdit.Value;
            prefs.ReferenceEigenvalueLineWidth = obj.RefEWLineWidthEdit.Value;

            prefs.ComputedEigenvalueColor = string(obj.CompEWColorEdit.Value);
            prefs.ComputedEigenvalueMarker = string(obj.CompEWMarkerDropdown.Value);
            prefs.ComputedEigenvalueSize = obj.CompEWSizeEdit.Value;
            prefs.ComputedEigenvalueLineWidth = obj.CompEWLineWidthEdit.Value;

            prefs.SPLoewnerShiftColor = string(obj.SPShiftColorEdit.Value);
            prefs.SPLoewnerShiftMarker = string(obj.SPShiftMarkerDropdown.Value);
            prefs.SPLoewnerShiftSize = obj.SPShiftSizeEdit.Value;
            prefs.SPLoewnerShiftLineWidth = obj.SPShiftLineWidthEdit.Value;

            prefs.MPLoewnerRightColor = string(obj.MPRightColorEdit.Value);
            prefs.MPLoewnerRightMarker = string(obj.MPRightMarkerDropdown.Value);
            prefs.MPLoewnerRightSize = obj.MPRightSizeEdit.Value;
            prefs.MPLoewnerRightLineWidth = obj.MPRightLineWidthEdit.Value;

            prefs.MPLoewnerLeftColor = string(obj.MPLeftColorEdit.Value);
            prefs.MPLoewnerLeftMarker = string(obj.MPLeftMarkerDropdown.Value);
            prefs.MPLoewnerLeftSize = obj.MPLeftSizeEdit.Value;
            prefs.MPLoewnerLeftLineWidth = obj.MPLeftLineWidthEdit.Value;

            prefs.SingularValueColor = string(obj.SingValColorEdit.Value);
            prefs.SingularValueLineStyle = string(obj.SingValLineStyleEdit.Value);
            prefs.SingularValueMarkerSize = obj.SingValMarkerSizeEdit.Value;
        end
    end

    methods (Access = private)
        function createControls(obj)
            L1 = obj.makeLayout(15, 130, 120, 5);
            L2 = obj.makeLayout(350, 130, 120, 5);
            fullSepWidth = L2.xField + L2.fieldWidth - L1.xLabel;

            yPos = 500;

            % === Column 1 top: Reference Eigenvalues ===
            obj.Layout = L1;
            yCol1 = obj.addHeader(yPos, 'Reference Eigenvalues', 11);
            [obj.RefEWColorEdit, obj.RefEWColorSwatch, yCol1] = obj.addColorField(yCol1, 'Color:');
            [obj.RefEWMarkerDropdown, yCol1] = obj.addDropdownField(yCol1, 'Marker:', obj.MARKER_ITEMS);
            [obj.RefEWSizeEdit, yCol1] = obj.addNumericField(yCol1, 'Size:', [1 1000]);
            [obj.RefEWLineWidthEdit, yCol1] = obj.addNumericField(yCol1, 'Line Width:', [0.1 10]);
            yCol1 = obj.addSeparator(yCol1);

            % === Column 1 top: Computed Eigenvalues ===
            yCol1 = obj.addHeader(yCol1, 'Computed Eigenvalues', 11);
            [obj.CompEWColorEdit, obj.CompEWColorSwatch, yCol1] = obj.addColorField(yCol1, 'Color:');
            [obj.CompEWMarkerDropdown, yCol1] = obj.addDropdownField(yCol1, 'Marker:', obj.MARKER_ITEMS);
            [obj.CompEWSizeEdit, yCol1] = obj.addNumericField(yCol1, 'Size:', [1 1000]);
            [obj.CompEWLineWidthEdit, yCol1] = obj.addNumericField(yCol1, 'Line Width:', [0.1 10]);

            % === Column 2 top: SPLoewner Shifts ===
            obj.Layout = L2;
            yCol2 = obj.addHeader(yPos, 'SPLoewner Shifts', 11);
            [obj.SPShiftColorEdit, obj.SPShiftColorSwatch, yCol2] = obj.addColorField(yCol2, 'Color:');
            [obj.SPShiftMarkerDropdown, yCol2] = obj.addDropdownField(yCol2, 'Marker:', obj.MARKER_ITEMS);
            [obj.SPShiftSizeEdit, yCol2] = obj.addNumericField(yCol2, 'Size:', [1 1000]);
            [obj.SPShiftLineWidthEdit, yCol2] = obj.addNumericField(yCol2, 'Line Width:', [0.1 10]);
            yCol2 = obj.addSeparator(yCol2);

            % === Column 2 top: MPLoewner Right Points ===
            yCol2 = obj.addHeader(yCol2, 'MPLoewner Right Points', 11);
            [obj.MPRightColorEdit, obj.MPRightColorSwatch, yCol2] = obj.addColorField(yCol2, 'Color:');
            [obj.MPRightMarkerDropdown, yCol2] = obj.addDropdownField(yCol2, 'Marker:', obj.MARKER_ITEMS);
            [obj.MPRightSizeEdit, yCol2] = obj.addNumericField(yCol2, 'Size:', [1 1000]);
            [obj.MPRightLineWidthEdit, yCol2] = obj.addNumericField(yCol2, 'Line Width:', [0.1 10]);

            % === Full-width separator ===
            obj.Layout = L1;
            yBottom = obj.addSeparator(min(yCol1, yCol2), fullSepWidth);

            % === Bottom column 1: MPLoewner Left Points ===
            yCol1 = obj.addHeader(yBottom, 'MPLoewner Left Points', 11);
            [obj.MPLeftColorEdit, obj.MPLeftColorSwatch, yCol1] = obj.addColorField(yCol1, 'Color:');
            [obj.MPLeftMarkerDropdown, yCol1] = obj.addDropdownField(yCol1, 'Marker:', obj.MARKER_ITEMS);
            [obj.MPLeftSizeEdit, yCol1] = obj.addNumericField(yCol1, 'Size:', [1 1000]);
            [obj.MPLeftLineWidthEdit, yCol1] = obj.addNumericField(yCol1, 'Line Width:', [0.1 10]); %#ok<NASGU>

            % === Bottom column 2: Singular Values ===
            obj.Layout = L2;
            yCol2 = obj.addHeader(yBottom, 'Singular Values', 11);
            [obj.SingValColorEdit, obj.SingValColorSwatch, yCol2] = obj.addColorField(yCol2, 'Color:');
            [obj.SingValLineStyleEdit, yCol2] = obj.addTextField(yCol2, 'Line Style:', 'e.g., "->" for line with markers');
            [obj.SingValMarkerSizeEdit, yCol2] = obj.addNumericField(yCol2, 'Marker Size:', [1 100]); %#ok<NASGU>
        end
    end
end
