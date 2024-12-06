classdef CircleComponent < GUI.Parameter.Contour.ContourComponent

    properties (Access = private)
        GridLayout              matlab.ui.container.GridLayout
        %
        gammaEditField          matlab.ui.control.EditField
        gammaEditFieldLabel     matlab.ui.control.Label
        %
        radiusEditField         matlab.ui.control.NumericEditField
        radiusEditFieldLabel    matlab.ui.control.Label
    end

    properties (Access = public)
        CIMData                 Numerics.CIM
    end

    methods (Access = public)

        function obj = CircleComponent(Parent,CIMData)

            obj@GUI.Parameter.Contour.ContourComponent(Parent)
            obj.CIMData = CIMData;
            assert(isa(obj.CIMData.SampleData.Contour,'Numerics.Contour.Circle'));

            obj.setDefaults(0,0);

            % obj.addListeners();

            addlistener(obj.CIMData.SampleData.Contour,'gamma','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'rho','PostSet',@(src,event)obj.setDefaults);

        end

        function setDefaults(comp,src,event)
            contour = comp.CIMData.SampleData.Contour;
            comp.gammaEditField.Value = num2str(contour.gamma);
            comp.radiusEditField.Value = contour.rho;
        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        function radiusEditFieldValueChanged(comp, event)
            contour = comp.CIMData.SampleData.Contour;
            try
                contour.rho = comp.radiusEditField.Value;
            catch
                comp.radiusEditField.Value = event.PreviousValue;
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        function centerEditFieldValueChanged(comp, event)
            contour = comp.CIMData.SampleData.Contour;
            try
                contour.gamma = str2double(comp.gammaEditField.Value);
            catch
                comp.gammaEditField.Value = event.PreviousValue;
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

            comp.GridLayout = uigridlayout(comp,[2 2]);
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];

            comp.gammaEditField = uieditfield(comp.GridLayout, 'text');
            comp.gammaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @centerEditFieldValueChanged, true);
            comp.gammaEditField.HorizontalAlignment = 'center';
            comp.gammaEditField.Layout.Row = 1;
            comp.gammaEditField.Layout.Column = 1;
            comp.gammaEditField.Value = '0';

            comp.gammaEditFieldLabel = uilabel(comp.GridLayout);
            comp.gammaEditFieldLabel.HorizontalAlignment = 'center';
            comp.gammaEditFieldLabel.Layout.Row = 2;
            comp.gammaEditFieldLabel.Layout.Column = 1;
            comp.gammaEditFieldLabel.Text = 'center';

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