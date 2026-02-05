classdef GridLayoutButtonGroup < matlab.ui.componentcontainer.ComponentContainer
    % GridLayoutButtonGroup - A resizable button group using GridLayout
    % This replaces the standard uibuttongroup which uses fixed positioning
    % with a GridLayout-based implementation that resizes with the GUI.

    properties (Access = public)
        Title char = ''
        TitlePosition char = 'centertop'
        SelectionChangedFcn = []
    end

    properties (Access = private)
        GridLayout matlab.ui.container.GridLayout
        TitleLabel matlab.ui.control.Label
        Buttons (:,1) GUI.GridLayoutToggleButton = GUI.GridLayoutToggleButton.empty(0,1)
        ButtonListeners = []
    end

    properties (Dependent)
        SelectedObject
    end

    methods

        function obj = GridLayoutButtonGroup(varargin)
            % Constructor - mimics uibuttongroup interface
            % Call superclass constructor to handle parent assignment
            obj@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
        end

        function button = addButton(obj, text, row)
            % Add a toggle button to the group
            %
            % Args:
            %   text: Button text label
            %   row: Row position in grid (optional, auto-increments if not provided)

            if nargin < 3
                % Auto-increment row: title label is row 1, so buttons start at row 2
                row = 2 + length(obj.Buttons);
            end

            % Update grid layout to accommodate new button
            obj.GridLayout.RowHeight = [{'fit'}; repmat({'1x'}, length(obj.Buttons) + 1, 1)];

            button = GUI.GridLayoutToggleButton(obj.GridLayout);
            button.Text = text;
            button.Layout.Row = row;
            button.Layout.Column = 1;

            % Store button reference
            obj.Buttons(end+1) = button;

            % Add listener for value changes to implement mutual exclusivity
            obj.ButtonListeners{end+1} = addlistener(button, 'Value', 'PostSet', ...
                @(src, event) obj.onButtonValueChanged(button));
        end

        function obj = set.Title(obj, val)
            obj.Title = val;
            if ~isempty(obj.TitleLabel)
                obj.TitleLabel.Text = val;
            end
        end

        function obj = set.SelectionChangedFcn(obj, val)
            obj.SelectionChangedFcn = val;
        end

        function selected = get.SelectedObject(obj)
            selected = [];
            for i = 1:length(obj.Buttons)
                if obj.Buttons(i).Value
                    selected = obj.Buttons(i);
                    return;
                end
            end
        end

    end

    methods (Access = private)

        function onButtonValueChanged(obj, changedButton)
            % Enforce mutual exclusivity and trigger callback
            if changedButton.Value
                % User selected this button - deselect all others
                for i = 1:length(obj.Buttons)
                    if obj.Buttons(i) ~= changedButton
                        obj.Buttons(i).Value = false;
                    end
                end

                % Trigger selection changed callback
                if ~isempty(obj.SelectionChangedFcn)
                    % Create event data structure similar to uibuttongroup
                    eventData = struct('PreviousValue', [], 'Value', changedButton);
                    obj.SelectionChangedFcn(obj, eventData);
                end
            else
                % User tried to deselect - don't allow (must have one selected)
                % unless all are being deselected programmatically
                hasSelection = false;
                for i = 1:length(obj.Buttons)
                    if obj.Buttons(i).Value
                        hasSelection = true;
                        break;
                    end
                end
                if ~hasSelection && ~isempty(obj.Buttons)
                    % Re-select this button to maintain selection
                    changedButton.Value = true;
                end
            end
        end

    end

    methods (Access = protected)

        function setup(obj)
            % Create the grid layout with title
            obj.GridLayout = uigridlayout(obj, [2, 1]);
            obj.GridLayout.RowHeight = {'fit', '1x'};
            obj.GridLayout.Padding = [5 5 5 5];
            obj.GridLayout.RowSpacing = 5;

            % Create title label
            obj.TitleLabel = uilabel(obj.GridLayout);
            obj.TitleLabel.Text = obj.Title;
            obj.TitleLabel.HorizontalAlignment = 'center';
            obj.TitleLabel.FontWeight = 'bold';
            obj.TitleLabel.Layout.Row = 1;
            obj.TitleLabel.Layout.Column = 1;
        end

        function update(obj)
            % Update title text if changed
            obj.TitleLabel.Text = obj.Title;
        end

    end

end
