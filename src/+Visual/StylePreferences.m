classdef StylePreferences < handle
    % STYLEPREFERENCES Centralized container for all CIMTOOL plot styling properties
    %
    % This class stores and persists visual styling preferences for CIMTOOL plots,
    % including contour lines, markers, axes, grids, and legends. Preferences are
    % automatically saved to MATLAB's preference system and persist across sessions.
    %
    % Default values match CIMTOOL's original hard-coded styles (no visual change).
    %
    % Usage:
    %   sp = Visual.StylePreferences()                    % Create with defaults
    %   sp.ContourColor = "cyan";                         % Modify a property
    %   sp.save()                                         % Save to disk
    %   sp = Visual.StylePreferences.load()               % Load from disk
    %   sp = Visual.StylePreferences.fromStruct(s)        % Create from struct
    %   s = sp.toStruct()                                 % Export to struct

    properties
        % Contour line styling
        ContourColor         string = "blue"
        ContourLineWidth     double = 5
        ContourLineStyle     string = "-"

        % Quadrature point markers
        ShowQuadratureNodes  logical = false
        QuadratureColor      string = "red"
        QuadratureMarker     string = "x"
        QuadratureSize       double = 200

        % Reference eigenvalues (from OperatorData)
        ReferenceEigenvalueColor    string = "#E66100"
        ReferenceEigenvalueMarker   string = "diamond"
        ReferenceEigenvalueSize     double = 100
        ReferenceEigenvalueLineWidth double = 1.5

        % Computed eigenvalues (from ResultData)
        ComputedEigenvalueColor      string = "#1AFF1A"
        ComputedEigenvalueMarker     string = "o"
        ComputedEigenvalueSize       double = 30
        ComputedEigenvalueLineWidth  double = 1.5

        % SPLoewner shifts (single-point Loewner)
        SPLoewnerShiftColor    string = "blue"
        SPLoewnerShiftMarker   string = "square"
        SPLoewnerShiftSize     double = 50
        SPLoewnerShiftLineWidth double = 1.5

        % MPLoewner interpolation points (multi-point Loewner)
        MPLoewnerRightColor    string = "blue"
        MPLoewnerRightMarker   string = "square"
        MPLoewnerRightSize     double = 50
        MPLoewnerRightLineWidth double = 1.5
        MPLoewnerLeftColor     string = "red"
        MPLoewnerLeftMarker    string = "square"
        MPLoewnerLeftSize      double = 50
        MPLoewnerLeftLineWidth  double = 1.5

        % Singular value plot styling
        SingularValueColor      string = "r"
        SingularValueLineStyle  string = "->"
        SingularValueMarkerSize double = 10

        % Ghost contour (interactive preview during drag)
        GhostContourColor       string = "red"
        GhostContourLineWidth   double = 5
        GhostContourLineStyle   string = "-"
        GhostCenterColor        string = "red"
        GhostCenterSize         double = 200
        GhostCenterMarker       string = "o"

        % Axes and grid
        AxesGridVisible         string = "on"
        AxesGridLineStyle       string = ":"
        AxesGridColor                  = [0.15 0.15 0.15]  % default grid color (can be string or RGB array)
        AxesBackgroundColor     string = "white"
        AxesXLabelText          string = "$\bf{R}$"
        AxesYLabelText          string = "$i\bf{R}$"
        AxesLabelInterpreter    string = "latex"

        % Legend
        LegendLocation      string = "northoutside"
        LegendOrientation   string = "horizontal"
        LegendInterpreter   string = "latex"
        LegendFontSize      double = 10
    end

    methods
        function obj = StylePreferences()
            % STYLEPREFERENCES Construct with factory defaults
            % All properties already initialized with default values
        end

        function save(obj)
            % SAVE Save preferences to MATLAB's persistent preferences system
            %
            % Preferences are stored using MATLAB's getpref/setpref API and
            % persist across MATLAB sessions.
            s = obj.toStruct();
            setpref('CIMTOOL', 'StylePreferences', s);
        end

        function s = toStruct(obj)
            % TOSTRUCT Convert preferences to struct for programmatic interface
            %
            % Returns:
            %   s - Struct with all preference properties as fields
            %
            % Usage:
            %   s = sp.toStruct();
            %   s.ContourColor = "magenta";
            %   sp2 = Visual.StylePreferences.fromStruct(s);

            props = properties(obj);
            s = struct();
            for i = 1:length(props)
                s.(props{i}) = obj.(props{i});
            end
        end

        function validate(obj)
            % VALIDATE Check that all properties have valid values
            %
            % Throws an error if any property is invalid. Checks include:
            %   - Color values are valid MATLAB color specs
            %   - Size values are positive
            %   - LineWidth values are positive
            %   - Marker/LineStyle values are recognized by MATLAB

            % Validate colors (string or numeric RGB)
            colorProps = {'ContourColor', 'QuadratureColor', ...
                         'ReferenceEigenvalueColor', 'ComputedEigenvalueColor', ...
                         'SPLoewnerShiftColor', 'MPLoewnerRightColor', 'MPLoewnerLeftColor', ...
                         'SingularValueColor', 'GhostContourColor', 'GhostCenterColor', ...
                         'AxesBackgroundColor'};
            for i = 1:length(colorProps)
                prop = colorProps{i};
                val = obj.(prop);
                if isstring(val) || ischar(val)
                    % Valid color names or hex codes
                    if ~any(strcmpi(val, {'red','blue','green','black','white','cyan','magenta','yellow', ...
                                          'r','g','b','c','m','y','k','w'})) && ...
                       ~startsWith(val, '#')
                        error('StylePreferences:InvalidColor', ...
                              'Invalid color "%s" for property %s', val, prop);
                    end
                elseif ~(isnumeric(val) && length(val) == 3 && all(val >= 0) && all(val <= 1))
                    error('StylePreferences:InvalidColor', ...
                          'Color must be a valid name, hex code, or [R G B] triplet for property %s', prop);
                end
            end

            % Validate positive size values
            sizeProps = {'QuadratureSize', 'ReferenceEigenvalueSize', 'ComputedEigenvalueSize', ...
                        'SPLoewnerShiftSize', 'MPLoewnerRightSize', 'MPLoewnerLeftSize', ...
                        'SingularValueMarkerSize', 'GhostCenterSize', 'LegendFontSize'};
            for i = 1:length(sizeProps)
                prop = sizeProps{i};
                val = obj.(prop);
                if ~isnumeric(val) || val <= 0
                    error('StylePreferences:InvalidSize', ...
                          'Size must be a positive number for property %s', prop);
                end
            end

            % Validate positive line width values
            widthProps = {'ContourLineWidth', 'ReferenceEigenvalueLineWidth', ...
                         'ComputedEigenvalueLineWidth', 'SPLoewnerShiftLineWidth', ...
                         'MPLoewnerRightLineWidth', 'MPLoewnerLeftLineWidth', 'GhostContourLineWidth'};
            for i = 1:length(widthProps)
                prop = widthProps{i};
                val = obj.(prop);
                if ~isnumeric(val) || val <= 0
                    error('StylePreferences:InvalidLineWidth', ...
                          'LineWidth must be a positive number for property %s', prop);
                end
            end

            % Validate line styles
            validLineStyles = {'-', '--', ':', '-.', 'none'};
            lineStyleProps = {'ContourLineStyle', 'AxesGridLineStyle', 'GhostContourLineStyle'};
            for i = 1:length(lineStyleProps)
                prop = lineStyleProps{i};
                val = obj.(prop);
                if ~any(strcmpi(val, validLineStyles))
                    error('StylePreferences:InvalidLineStyle', ...
                          'Invalid line style "%s" for property %s. Must be one of: %s', ...
                          val, prop, strjoin(validLineStyles, ', '));
                end
            end

            % Validate markers
            validMarkers = {'+', 'o', '*', '.', 'x', 'square', 's', 'diamond', 'd', ...
                           '^', 'v', '>', '<', 'pentagram', 'p', 'hexagram', 'h', 'none'};
            markerProps = {'QuadratureMarker', 'ReferenceEigenvalueMarker', 'ComputedEigenvalueMarker', ...
                          'SPLoewnerShiftMarker', 'MPLoewnerRightMarker', 'MPLoewnerLeftMarker', 'GhostCenterMarker'};
            for i = 1:length(markerProps)
                prop = markerProps{i};
                val = obj.(prop);
                if ~any(strcmpi(val, validMarkers))
                    error('StylePreferences:InvalidMarker', ...
                          'Invalid marker "%s" for property %s. Must be one of: %s', ...
                          val, prop, strjoin(validMarkers, ', '));
                end
            end

            % Validate axes grid visibility
            if ~any(strcmpi(obj.AxesGridVisible, {'on', 'off'}))
                error('StylePreferences:InvalidGridVisible', ...
                      'AxesGridVisible must be "on" or "off"');
            end

            % Validate legend location
            validLocations = {'north', 'south', 'east', 'west', 'northeast', 'northwest', ...
                             'southeast', 'southwest', 'northoutside', 'southoutside', ...
                             'eastoutside', 'westoutside', 'northeastoutside', 'northwestoutside', ...
                             'southeastoutside', 'southwestoutside', 'best', 'bestoutside', 'none'};
            if ~any(strcmpi(obj.LegendLocation, validLocations))
                error('StylePreferences:InvalidLegendLocation', ...
                      'Invalid legend location "%s"', obj.LegendLocation);
            end

            % Validate legend orientation
            if ~any(strcmpi(obj.LegendOrientation, {'horizontal', 'vertical'}))
                error('StylePreferences:InvalidLegendOrientation', ...
                      'LegendOrientation must be "horizontal" or "vertical"');
            end

            % Validate interpreters
            validInterpreters = {'latex', 'tex', 'none'};
            if ~any(strcmpi(obj.LegendInterpreter, validInterpreters))
                error('StylePreferences:InvalidInterpreter', ...
                      'LegendInterpreter must be one of: %s', strjoin(validInterpreters, ', '));
            end
            if ~any(strcmpi(obj.AxesLabelInterpreter, validInterpreters))
                error('StylePreferences:InvalidInterpreter', ...
                      'AxesLabelInterpreter must be one of: %s', strjoin(validInterpreters, ', '));
            end
        end
    end

    methods (Static)
        function sp = load()
            % LOAD Load preferences from MATLAB's persistent preferences system
            %
            % Returns factory defaults if no saved preferences exist.
            %
            % Returns:
            %   sp - StylePreferences object with saved or default values
            %
            % Usage:
            %   sp = Visual.StylePreferences.load();

            if ispref('CIMTOOL', 'StylePreferences')
                s = getpref('CIMTOOL', 'StylePreferences');
                sp = Visual.StylePreferences.fromStruct(s);
            else
                sp = Visual.StylePreferences();  % Factory defaults
            end
        end

        function sp = fromStruct(s)
            % FROMSTRUCT Create StylePreferences from a struct
            %
            % Args:
            %   s - Struct with preference properties as fields
            %
            % Returns:
            %   sp - StylePreferences object
            %
            % Usage:
            %   customStyles = struct('ContourColor', 'cyan', 'QuadratureMarker', 'o');
            %   sp = Visual.StylePreferences.fromStruct(customStyles);

            sp = Visual.StylePreferences();

            % Only set properties that exist in both the struct and the class
            props = properties(sp);
            fields = fieldnames(s);
            for i = 1:length(fields)
                field = fields{i};
                if any(strcmp(field, props))
                    sp.(field) = s.(field);
                else
                    warning('StylePreferences:UnknownProperty', ...
                            'Ignoring unknown property "%s" in input struct', field);
                end
            end
        end

        function sp = factoryDefaults()
            % FACTORYDEFAULTS Return a fresh StylePreferences with factory defaults
            %
            % This is equivalent to calling the constructor, but more explicit
            % for use in Reset buttons in GUIs.
            %
            % Returns:
            %   sp - StylePreferences object with factory default values

            sp = Visual.StylePreferences();
        end
    end
end
