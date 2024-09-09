classdef circleparameters < contourparameters

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout               matlab.ui.container.GridLayout
        centerEditField          matlab.ui.control.EditField
        centerEditFieldLabel     matlab.ui.control.Label
        radiusEditField          matlab.ui.control.NumericEditField
        radiusEditField_2Label   matlab.ui.control.Label
        numquadnodesEditField    matlab.ui.control.NumericEditField
        quadnodesEditFieldLabel  matlab.ui.control.Label
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        centerUpdate
        quadnodesUpdate
        radiusUpdate
    end

    properties (Access = public)
        N (1,1) double {mustBePositive(N), mustBeNonmissing(N), mustBeNonNan(N), mustBeInteger(N), mustBeFinite(N)} = 8;
        center (1,1) double {mustBeNonmissing(center), mustBeNonNan(center), mustBeFinite(center)} = 0+0i;
        radius (1,1) double {mustBeReal(radius), mustBePositive(radius), mustBeNonzero(radius), mustBeNonmissing(radius), mustBeNonNan(radius), mustBeFinite(radius)} = 1;
    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: numquadnodesEditField
        function numquadnodesEditFieldValueChanged(comp, event)
            try
                comp.N = comp.numquadnodesEditField.Value;
                notify(comp, 'quadnodesUpdate');
            catch
                update(comp);
                errordlg("Invalid # of quadrature nodes. Please check input and try again.")
            end
        end

        % Value changed function: radiusEditField
        function radiusEditFieldValueChanged(comp, event)
            try
                comp.radius = comp.radiusEditField.Value;
                notify(comp, 'radiusUpdate');
            catch
                update(comp);
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        % Value changed function: centerEditField
        function centerEditFieldValueChanged(comp, event)
            try
                comp.center = str2double(comp.centerEditField.Value);
                notify(comp, 'centerUpdate');
            catch
                update(comp);
                errordlg("Invalid center. Please check input and try again.")
            end
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
            comp.radiusEditField.Value = comp.radius;
            comp.centerEditField.Value = num2str(comp.center);
            comp.numquadnodesEditField.Value = comp.N;
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 367 169];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x', 52, 52, 52, '1x'};
            comp.GridLayout.RowHeight = {'1x', 31, 22, '1x'};
            comp.GridLayout.ColumnSpacing = 9.75;
            comp.GridLayout.Padding = [9.75 10 9.75 10];

            % Create quadnodesEditFieldLabel
            comp.quadnodesEditFieldLabel = uilabel(comp.GridLayout);
            comp.quadnodesEditFieldLabel.HorizontalAlignment = 'center';
            comp.quadnodesEditFieldLabel.WordWrap = 'on';
            comp.quadnodesEditFieldLabel.Layout.Row = 2;
            comp.quadnodesEditFieldLabel.Layout.Column = 2;
            comp.quadnodesEditFieldLabel.Text = '# quad nodes';

            % Create numquadnodesEditField
            comp.numquadnodesEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.numquadnodesEditField.Limits = [0 Inf];
            comp.numquadnodesEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @numquadnodesEditFieldValueChanged, true);
            comp.numquadnodesEditField.HorizontalAlignment = 'center';
            comp.numquadnodesEditField.Layout.Row = 3;
            comp.numquadnodesEditField.Layout.Column = 2;
            comp.numquadnodesEditField.Value = 8;

            % Create radiusEditField_2Label
            comp.radiusEditField_2Label = uilabel(comp.GridLayout);
            comp.radiusEditField_2Label.HorizontalAlignment = 'center';
            comp.radiusEditField_2Label.WordWrap = 'on';
            comp.radiusEditField_2Label.Layout.Row = 2;
            comp.radiusEditField_2Label.Layout.Column = 4;
            comp.radiusEditField_2Label.Text = 'radius';

            % Create radiusEditField
            comp.radiusEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.radiusEditField.Limits = [0 Inf];
            comp.radiusEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @radiusEditFieldValueChanged, true);
            comp.radiusEditField.HorizontalAlignment = 'center';
            comp.radiusEditField.Layout.Row = 3;
            comp.radiusEditField.Layout.Column = 4;
            comp.radiusEditField.Value = 1;

            % Create centerEditFieldLabel
            comp.centerEditFieldLabel = uilabel(comp.GridLayout);
            comp.centerEditFieldLabel.HorizontalAlignment = 'center';
            comp.centerEditFieldLabel.Layout.Row = 2;
            comp.centerEditFieldLabel.Layout.Column = 3;
            comp.centerEditFieldLabel.Text = 'center';

            % Create centerEditField
            comp.centerEditField = uieditfield(comp.GridLayout, 'text');
            comp.centerEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.centerEditField.HorizontalAlignment = 'center';
            comp.centerEditField.Layout.Row = 3;
            comp.centerEditField.Layout.Column = 3;
            comp.centerEditField.Value = '0';
        end
    end
end