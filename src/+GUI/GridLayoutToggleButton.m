classdef GridLayoutToggleButton < handle
    % GridLayoutToggleButton - A toggle button wrapper for GridLayout
    % This provides toggle button functionality using a standard uibutton
    % since uitogglebutton requires a ButtonGroup parent.
    %
    % This is a lightweight wrapper that manages a uibutton and provides
    % toggle state behavior without creating an extra container layer.

    properties (SetObservable)
        Value logical = false
    end

    properties (Dependent)
        Text
        Layout
        Parent
        FontSize
    end

    properties (Access = private)
        Button matlab.ui.control.Button
    end

    methods

        function obj = GridLayoutToggleButton(parent)
            % Constructor
            % Args:
            %   parent: GridLayout or other valid parent for uibutton
            arguments
                parent = []
            end

            % Create the button directly with the parent
            if isempty(parent)
                obj.Button = uibutton();
            else
                obj.Button = uibutton(parent);
            end

            % Set up button callback
            obj.Button.ButtonPushedFcn = @obj.buttonPushed;

            % Set initial style
            obj.updateButtonStyle();

            % Add listener to update style when Value changes
            addlistener(obj, 'Value', 'PostSet', @(~,~) obj.updateButtonStyle());
        end

        % Text property forwarding
        function val = get.Text(obj)
            val = obj.Button.Text;
        end

        function set.Text(obj, val)
            obj.Button.Text = val;
        end

        % Layout property forwarding
        function val = get.Layout(obj)
            val = obj.Button.Layout;
        end

        function set.Layout(obj, val)
            obj.Button.Layout = val;
        end

        % Parent property forwarding
        function val = get.Parent(obj)
            val = obj.Button.Parent;
        end

        function set.Parent(obj, val)
            obj.Button.Parent = val;
        end

        % FontSize property forwarding
        function val = get.FontSize(obj)
            val = obj.Button.FontSize;
        end

        function set.FontSize(obj, val)
            obj.Button.FontSize = val;
        end

    end

    methods (Access = private)

        function buttonPushed(obj, ~, ~)
            % Toggle the value when button is clicked
            obj.Value = ~obj.Value;
        end

        function updateButtonStyle(obj)
            % Update button appearance based on Value state
            if obj.Value
                % Selected state - darker/highlighted appearance
                obj.Button.BackgroundColor = [0.3 0.6 1.0];  % Blue background
                obj.Button.FontWeight = 'bold';
                obj.Button.FontColor = [1 1 1];  % White text
            else
                % Unselected state - normal appearance
                obj.Button.BackgroundColor = [0.96 0.96 0.96];  % Light gray
                obj.Button.FontWeight = 'normal';
                obj.Button.FontColor = [0 0 0];  % Black text
            end
        end

    end

end
