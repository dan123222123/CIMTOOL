classdef EllipseComponent < ContourComponentInterface

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout               matlab.ui.container.GridLayout
        alphaEditField           matlab.ui.control.NumericEditField
        betaEditField            matlab.ui.control.NumericEditField
        centerEditField          matlab.ui.control.EditField
        centerEditFieldLabel     matlab.ui.control.Label
        alphaEditFieldLabel      matlab.ui.control.Label
        betaEditFieldLabel       matlab.ui.control.Label
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        centerUpdate
        radiiUpdate
    end

    properties (Access = public)
        center (1,1) double {mustBeNonmissing(center), mustBeNonNan(center), mustBeFinite(center)} = 0+0i;
        alpha (1,1) double {mustBeReal(alpha), mustBePositive(alpha), mustBeNonzero(alpha), mustBeNonmissing(alpha), mustBeNonNan(alpha), mustBeFinite(alpha)} = 1; % 1/2 horizontal width of ellipse
        beta (1,1) double {mustBeReal(beta), mustBePositive(beta), mustBeNonzero(beta), mustBeNonmissing(beta), mustBeNonNan(beta), mustBeFinite(beta)} = 1; % 1/2 vertical width of ellipse
    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Callback function: not associated with a component
        function alphaEditFieldValueChanged(comp, event)
            try
                comp.alpha = comp.alphaEditField.Value;
                notify(comp, 'radiusUpdate');
            catch
                update(comp);
                errordlg("Invalid horizontal radius. Please check input and try again.")
            end
        end

        % Value changed function: betaEditField
        function betaEditFieldValueChanged(comp, event)
            try
                comp.alpha = comp.betaEditField.Value;
                notify(comp, 'radiusUpdate');
            catch
                update(comp);
                errordlg("Invalid vertical radius. Please check input and try again.")
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

    methods (Access = public)
        function [z,w] = getNodesWeights(comp,N)
            [z,w] = ellipse_trapezoid(N,comp.center,comp.alpha,comp.beta);
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
            comp.centerEditField.Value = num2str(comp.center);
            comp.alphaEditField.Value = comp.alpha;
            comp.betaEditField.Value = comp.beta;
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 367 169];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x', 52, 52, 52, '1x'};
            comp.GridLayout.RowHeight = {'1x', 31, 31, '1x'};
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];

            % Create centerEditFieldLabel
            comp.centerEditFieldLabel = uilabel(comp.GridLayout);
            comp.centerEditFieldLabel.HorizontalAlignment = 'center';
            comp.centerEditFieldLabel.WordWrap = 'on';
            comp.centerEditFieldLabel.Layout.Row = 2;
            comp.centerEditFieldLabel.Layout.Column = 2;
            comp.centerEditFieldLabel.Text = 'center';

            % Create alphaEditFieldLabel
            comp.alphaEditFieldLabel = uilabel(comp.GridLayout);
            comp.alphaEditFieldLabel.HorizontalAlignment = 'center';
            comp.alphaEditFieldLabel.WordWrap = 'on';
            comp.alphaEditFieldLabel.Layout.Row = 2;
            comp.alphaEditFieldLabel.Layout.Column = 3;
            comp.alphaEditFieldLabel.Text = 'α';

            % Create betaEditFieldLabel
            comp.betaEditFieldLabel = uilabel(comp.GridLayout);
            comp.betaEditFieldLabel.HorizontalAlignment = 'center';
            comp.betaEditFieldLabel.WordWrap = 'on';
            comp.betaEditFieldLabel.Layout.Row = 2;
            comp.betaEditFieldLabel.Layout.Column = 4;
            comp.betaEditFieldLabel.Text = 'β';

            % Create centerEditField
            comp.centerEditField = uieditfield(comp.GridLayout, 'text');
            comp.centerEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.centerEditField.HorizontalAlignment = 'center';
            comp.centerEditField.Layout.Row = 3;
            comp.centerEditField.Layout.Column = 2;
            comp.centerEditField.Value = '0';

            % Create alphaEditField
            comp.alphaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.alphaEditField.Limits = [0 Inf];
            comp.alphaEditField.HorizontalAlignment = 'center';
            comp.alphaEditField.Layout.Row = 3;
            comp.alphaEditField.Layout.Column = 3;
            comp.alphaEditField.Value = 1;

            % Create betaEditField
            comp.betaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.betaEditField.Limits = [0 Inf];
            comp.betaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @betaEditFieldValueChanged, true);
            comp.betaEditField.HorizontalAlignment = 'center';
            comp.betaEditField.Layout.Row = 3;
            comp.betaEditField.Layout.Column = 4;
            comp.betaEditField.Value = 1;

        end
    end
end