classdef ellipseparameters < contourparameters

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout               matlab.ui.container.GridLayout
        alphaEditField           matlab.ui.control.NumericEditField
        Label                    matlab.ui.control.Label
        centerEditField          matlab.ui.control.EditField
        centerEditField_2Label   matlab.ui.control.Label
        betaEditField            matlab.ui.control.NumericEditField
        EditFieldLabel           matlab.ui.control.Label
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
        alpha (1,1) double {mustBeReal(alpha), mustBePositive(alpha), mustBeNonzero(alpha), mustBeNonmissing(alpha), mustBeNonNan(alpha), mustBeFinite(alpha)} = 1; % 1/2 horizontal width of ellipse
        beta (1,1) double {mustBeReal(beta), mustBePositive(beta), mustBeNonzero(beta), mustBeNonmissing(beta), mustBeNonNan(beta), mustBeFinite(beta)} = 1; % 1/2 vertical width of ellipse
        center (1,1) double {mustBeNonmissing(center), mustBeNonNan(center), mustBeFinite(center)} = 0+0i;
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
            comp.betaEditField.Value = comp.beta;
            comp.alphaEditField.Value = comp.alpha;
            comp.centerEditField.Value = num2str(comp.center);
            comp.numquadnodesEditField.Value = comp.N;
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 367 169];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x', 52, '1x', 52, 52, '1x'};
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

            % Create EditFieldLabel
            comp.EditFieldLabel = uilabel(comp.GridLayout);
            comp.EditFieldLabel.HorizontalAlignment = 'center';
            comp.EditFieldLabel.WordWrap = 'on';
            comp.EditFieldLabel.Layout.Row = 2;
            comp.EditFieldLabel.Layout.Column = 5;
            comp.EditFieldLabel.Text = 'β';

            % Create betaEditField
            comp.betaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.betaEditField.Limits = [0 Inf];
            comp.betaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @betaEditFieldValueChanged, true);
            comp.betaEditField.HorizontalAlignment = 'center';
            comp.betaEditField.Layout.Row = 3;
            comp.betaEditField.Layout.Column = 5;
            comp.betaEditField.Value = 1;

            % Create centerEditField_2Label
            comp.centerEditField_2Label = uilabel(comp.GridLayout);
            comp.centerEditField_2Label.HorizontalAlignment = 'center';
            comp.centerEditField_2Label.Layout.Row = 2;
            comp.centerEditField_2Label.Layout.Column = 3;
            comp.centerEditField_2Label.Text = 'center';

            % Create centerEditField
            comp.centerEditField = uieditfield(comp.GridLayout, 'text');
            comp.centerEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.centerEditField.HorizontalAlignment = 'center';
            comp.centerEditField.Layout.Row = 3;
            comp.centerEditField.Layout.Column = 3;
            comp.centerEditField.Value = '0';

            % Create Label
            comp.Label = uilabel(comp.GridLayout);
            comp.Label.HorizontalAlignment = 'center';
            comp.Label.WordWrap = 'on';
            comp.Label.Layout.Row = 2;
            comp.Label.Layout.Column = 4;
            comp.Label.Text = 'α';

            % Create alphaEditField
            comp.alphaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.alphaEditField.Limits = [0 Inf];
            comp.alphaEditField.HorizontalAlignment = 'center';
            comp.alphaEditField.Layout.Row = 3;
            comp.alphaEditField.Layout.Column = 4;
            comp.alphaEditField.Value = 1;
        end
    end
end