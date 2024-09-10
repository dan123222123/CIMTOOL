classdef CircleComponent < ContourComponentInterface

    % GUI Properties
    properties (Access = private)
        GridLayout               matlab.ui.container.GridLayout
        centerEditField          matlab.ui.control.EditField
        radiusEditField          matlab.ui.control.NumericEditField
        centerEditFieldLabel     matlab.ui.control.Label
        radiusEditFieldLabel     matlab.ui.control.Label
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = public)
        ContourUpdated
    end

    properties (Access = public)
        MainApp % app that contains this component, set in constructor
        center (1,1) double {mustBeNonmissing(center), mustBeNonNan(center), mustBeFinite(center)} = 0+0i;
        radius (1,1) double {mustBeReal(radius), mustBePositive(radius), mustBeNonzero(radius), mustBeNonmissing(radius), mustBeNonNan(radius), mustBeFinite(radius)} = 1;
    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: radiusEditField
        function radiusEditFieldValueChanged(comp, event)
            try
                comp.radius = comp.radiusEditField.Value;
            catch
                comp.radiusEditField.Value = event.PreviousValue;
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        % Value changed function: centerEditField
        function centerEditFieldValueChanged(comp, event)
            try
                comp.center = str2double(comp.centerEditField.Value);
            catch
                comp.centerEditField.Value = event.PreviousValue;
                errordlg("Invalid center. Please check input and try again.")
            end
        end
    end

    methods (Access = public)
        function [z,w] = getNodesWeights(comp,N)
            [z,w] = circle_trapezoid(N,comp.center,comp.radius);
        end
        function phandles = plot(comp,ax,zd)
            zc = circle_trapezoid(128,comp.center,comp.radius);
            phandles = {};
            phandles{1} = plot(ax,real(zc),imag(zc),"blue");
            phandles{2} = scatter(ax,real(zd),imag(zd),"red","x",'LineWidth',2);
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
            comp.radiusEditField.Value = comp.radius;
            comp.centerEditField.Value = num2str(comp.center);
            notify(comp.MainApp,"ContourParametersChanged");
        end

        % Create the underlying components
        function setup(comp)

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