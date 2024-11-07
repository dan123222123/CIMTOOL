classdef CircleComponent < GUI.Parameter.Contour.ContourComponent

    % GUI Properties
    properties (Access = private)
        GridLayout               matlab.ui.container.GridLayout
        centerEditField          matlab.ui.control.EditField
        radiusEditField          matlab.ui.control.NumericEditField
        centerEditFieldLabel     matlab.ui.control.Label
        radiusEditFieldLabel     matlab.ui.control.Label
    end

    properties (Access = public)
        CIMData
    end

    methods (Access = public)

        function obj = CircleComponent(Parent,CIMData)

            obj@GUI.Parameter.Contour.ContourComponent(Parent)
            obj.CIMData = CIMData;

            % obj.addListeners();

        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: radiusEditField
        function radiusEditFieldValueChanged(comp, event)
            try
                comp.CIMData.SampleData.Contour.radius = comp.radiusEditField.Value;
            catch
                comp.radiusEditField.Value = event.PreviousValue;
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        % Value changed function: centerEditField
        function centerEditFieldValueChanged(comp, event)
            try
                comp.CIMData.SampleData.Contour.center = str2double(comp.centerEditField.Value);
            catch
                comp.centerEditField.Value = event.PreviousValue;
                errordlg("Invalid center. Please check input and try again.")
            end
        end
    end

    methods (Access = protected)
        
        function update(comp)
            %nothing
        end

        % Create the underlying components
        function setup(comp)

            comp.GridLayout = uigridlayout(comp,[2 2]);
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];

            comp.centerEditField = uieditfield(comp.GridLayout, 'text');
            comp.centerEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.centerEditField.HorizontalAlignment = 'center';
            comp.centerEditField.Layout.Row = 1;
            comp.centerEditField.Layout.Column = 1;
            comp.centerEditField.Value = '0';

            comp.centerEditFieldLabel = uilabel(comp.GridLayout);
            comp.centerEditFieldLabel.HorizontalAlignment = 'center';
            comp.centerEditFieldLabel.Layout.Row = 2;
            comp.centerEditFieldLabel.Layout.Column = 1;
            comp.centerEditFieldLabel.Text = 'center';

            comp.radiusEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.radiusEditField.Limits = [0 Inf];
            comp.radiusEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @radiusEditFieldValueChanged, true);
            comp.radiusEditField.HorizontalAlignment = 'center';
            comp.radiusEditField.Layout.Row = 1;
            comp.radiusEditField.Layout.Column = 2;
            comp.radiusEditField.Value = 1;

            comp.radiusEditFieldLabel = uilabel(comp.GridLayout);
            comp.radiusEditFieldLabel.HorizontalAlignment = 'center';
            comp.radiusEditFieldLabel.WordWrap = 'on';
            comp.radiusEditFieldLabel.Layout.Row = 2;
            comp.radiusEditFieldLabel.Layout.Column = 2;
            comp.radiusEditFieldLabel.Text = 'radius';

        end
    end

end