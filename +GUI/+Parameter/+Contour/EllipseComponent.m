classdef EllipseComponent < GUI.Parameter.Contour.ContourComponent

    % GUI Properties
    properties (Access = private)
        GridLayout              matlab.ui.container.GridLayout
        gammaEditField          matlab.ui.control.EditField
        alphaEditField          matlab.ui.control.NumericEditField
        betaEditField           matlab.ui.control.NumericEditField
        gammaEditFieldLabel     matlab.ui.control.Label
        alphaEditFieldLabel     matlab.ui.control.Label
        betaEditFieldLabel      matlab.ui.control.Label
    end

    properties (Access = public)
        CIMData                 Numerics.CIM
    end

    methods (Access = public)

        function obj = EllipseComponent(Parent,CIMData)

            obj@GUI.Parameter.Contour.ContourComponent(Parent)
            obj.CIMData = CIMData;
            assert(isa(obj.CIMData.SampleData.Contour,'Numerics.Contour.Ellipse'));

            obj.setDefaults();

            % obj.addListeners();

        end

        function setDefaults(comp)
            contour = comp.CIMData.SampleData.Contour;
            comp.gammaEditField.Value = num2str(contour.gamma);
            comp.alphaEditField.Value = contour.alpha;
            comp.betaEditField.Value = contour.beta;
        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        function alphaEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.alpha = comp.alphaEditField.Value;
            catch
                update(comp);
                errordlg("Invalid horizontal semi-radius. Please check input and try again.")
            end
        end

        function betaEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.beta = comp.betaEditField.Value;
            catch
                update(comp);
                errordlg("Invalid vertical semi-radius. Please check input and try again.")
            end
        end

        function gammaEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.gamma = str2double(comp.gammaEditField.Value);
            catch
                update(comp);
                errordlg("Invalid center. Please check input and try again.")
            end
        end
        
    end

    methods (Access = protected)
        
        function update(~)
            %nothing
        end

        % Create the underlying components
        function setup(comp)

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp,[2 3]);
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];

            comp.gammaEditField = uieditfield(comp.GridLayout, 'text');
            comp.gammaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @gammaEditFieldValueChanged, true);
            comp.gammaEditField.HorizontalAlignment = 'center';
            comp.gammaEditField.Layout.Row = 1;
            comp.gammaEditField.Layout.Column = 1;
            comp.gammaEditField.Value = '0';

            comp.gammaEditFieldLabel = uilabel(comp.GridLayout);
            comp.gammaEditFieldLabel.HorizontalAlignment = 'center';
            comp.gammaEditFieldLabel.Layout.Row = 2;
            comp.gammaEditFieldLabel.Layout.Column = 1;
            comp.gammaEditFieldLabel.Text = 'center';

            comp.alphaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.alphaEditField.Limits = [0 Inf];
            comp.alphaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @alphaEditFieldValueChanged, true);
            comp.alphaEditField.HorizontalAlignment = 'center';
            comp.alphaEditField.Layout.Row = 1;
            comp.alphaEditField.Layout.Column = 2;
            comp.alphaEditField.Value = 1;

            comp.alphaEditFieldLabel = uilabel(comp.GridLayout);
            comp.alphaEditFieldLabel.HorizontalAlignment = 'center';
            comp.alphaEditFieldLabel.WordWrap = 'on';
            comp.alphaEditFieldLabel.Layout.Row = 2;
            comp.alphaEditFieldLabel.Layout.Column = 2;
            comp.alphaEditFieldLabel.Text = 'alpha';

            comp.betaEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.betaEditField.Limits = [0 Inf];
            comp.betaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @betaEditFieldValueChanged, true);
            comp.betaEditField.HorizontalAlignment = 'center';
            comp.betaEditField.Layout.Row = 1;
            comp.betaEditField.Layout.Column = 3;
            comp.betaEditField.Value = 1;

            comp.betaEditFieldLabel = uilabel(comp.GridLayout);
            comp.betaEditFieldLabel.HorizontalAlignment = 'center';
            comp.betaEditFieldLabel.WordWrap = 'on';
            comp.betaEditFieldLabel.Layout.Row = 2;
            comp.betaEditFieldLabel.Layout.Column = 3;
            comp.betaEditFieldLabel.Text = 'beta';

        end
    end

end