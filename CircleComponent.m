classdef CircleComponent < ContourComponentInterface

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout               matlab.ui.container.GridLayout
        centerEditField          matlab.ui.control.EditField
        radiusEditField          matlab.ui.control.NumericEditField
        centerEditFieldLabel     matlab.ui.control.Label
        radiusEditFieldLabel     matlab.ui.control.Label
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        centerUpdate
        radiusUpdate
    end

    properties (Access = public)
        center (1,1) double {mustBeNonmissing(center), mustBeNonNan(center), mustBeFinite(center)} = 0+0i;
        radius (1,1) double {mustBeReal(radius), mustBePositive(radius), mustBeNonzero(radius), mustBeNonmissing(radius), mustBeNonNan(radius), mustBeFinite(radius)} = 1;
    end
    
    % Callbacks that handle component events
    methods (Access = private)

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
            comp.f = @(z) comp.center + comp.radius*exp(1i*z);
        end

        % Create the underlying components
        function setup(comp)

            % default cirlce parametrization
            comp.f = @(z) comp.center + comp.radius*exp(1i*z);
            % default quadrature rule
            comp.q = @(N) ((2*pi)/N)*((1:N) - (1/2));

            comp.Position = [1 1 367 169];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x', 52, 52, '1x'};
            comp.GridLayout.RowHeight = {'1x', 31, 31, '1x'};
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];

            % Create radiusEditFieldLabel
            comp.radiusEditFieldLabel = uilabel(comp.GridLayout);
            comp.radiusEditFieldLabel.HorizontalAlignment = 'center';
            comp.radiusEditFieldLabel.WordWrap = 'on';
            comp.radiusEditFieldLabel.Layout.Row = 2;
            comp.radiusEditFieldLabel.Layout.Column = 3;
            comp.radiusEditFieldLabel.Text = 'radius';

            % Create radiusEditField
            comp.radiusEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.radiusEditField.Limits = [0 Inf];
            comp.radiusEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @radiusEditFieldValueChanged, true);
            comp.radiusEditField.HorizontalAlignment = 'center';
            comp.radiusEditField.Layout.Row = 3;
            comp.radiusEditField.Layout.Column = 3;
            comp.radiusEditField.Value = 1;

            % Create centerEditFieldLabel
            comp.centerEditFieldLabel = uilabel(comp.GridLayout);
            comp.centerEditFieldLabel.HorizontalAlignment = 'center';
            comp.centerEditFieldLabel.Layout.Row = 2;
            comp.centerEditFieldLabel.Layout.Column = 2;
            comp.centerEditFieldLabel.Text = 'center';

            % Create centerEditField
            comp.centerEditField = uieditfield(comp.GridLayout, 'text');
            comp.centerEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.centerEditField.HorizontalAlignment = 'center';
            comp.centerEditField.Layout.Row = 3;
            comp.centerEditField.Layout.Column = 2;
            comp.centerEditField.Value = '0';
        end
    end

end