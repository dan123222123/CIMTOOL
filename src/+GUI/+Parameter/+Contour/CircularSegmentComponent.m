classdef CircularSegmentComponent < GUI.Parameter.Contour.ContourComponent

    % GUI Properties
    properties (Access = private)
        GridLayout              matlab.ui.container.GridLayout
        gammaEditField          matlab.ui.control.EditField
        rhoEditField            matlab.ui.control.NumericEditField
        thetaEditField          matlab.ui.control.EditField
        gammaEditFieldLabel     matlab.ui.control.Label
        rhoEditFieldLabel       matlab.ui.control.Label
        thetaEditFieldLabel     matlab.ui.control.Label
    end

    properties (Access = public)
        CIMData                 Numerics.CIM
    end

    methods (Access = public)

        function obj = CircularSegmentComponent(Parent,CIMData)

            obj@GUI.Parameter.Contour.ContourComponent(Parent)
            obj.CIMData = CIMData;
            assert(isa(obj.CIMData.SampleData.Contour,'Numerics.Contour.CircularSegment'));

            obj.setDefaults();

            % obj.addListeners();

            addlistener(obj.CIMData.SampleData.Contour,'gamma','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'rho','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'theta','PostSet',@(src,event)obj.setDefaults);

        end

        function setDefaults(comp)
            contour = comp.CIMData.SampleData.Contour;
            comp.gammaEditField.Value = num2str(contour.gamma);
            comp.rhoEditField.Value = contour.rho;
            comp.thetaEditField.Value = num2str(contour.theta);
        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end

    % Callbacks that handle component events
    methods (Access = private)

        function rhoEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.rho = comp.rhoEditField.Value;
            catch
                update(comp);
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        function thetaEditFieldValueChanged(comp,~)
            try
                theta = str2num(comp.thetaEditField.Value);
                if isscalar(theta)
                    theta = [-theta,theta];
                end
                comp.CIMData.SampleData.Contour.theta = theta;
            catch
                update(comp);
                errordlg("Invalid angle. Please check input and try again.")
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

            comp.rhoEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.rhoEditField.Limits = [0 Inf];
            comp.rhoEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @rhoEditFieldValueChanged, true);
            comp.rhoEditField.HorizontalAlignment = 'center';
            comp.rhoEditField.Layout.Row = 1;
            comp.rhoEditField.Layout.Column = 2;
            comp.rhoEditField.Value = 1;

            comp.rhoEditFieldLabel = uilabel(comp.GridLayout);
            comp.rhoEditFieldLabel.HorizontalAlignment = 'center';
            comp.rhoEditFieldLabel.WordWrap = 'on';
            comp.rhoEditFieldLabel.Layout.Row = 2;
            comp.rhoEditFieldLabel.Layout.Column = 2;
            comp.rhoEditFieldLabel.Text = 'rho';

            comp.thetaEditField = uieditfield(comp.GridLayout, 'text');
            comp.thetaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @thetaEditFieldValueChanged, true);
            comp.thetaEditField.HorizontalAlignment = 'center';
            comp.thetaEditField.Layout.Row = 1;
            comp.thetaEditField.Layout.Column = 3;
            comp.thetaEditField.Value = '-pi/2 pi/2';

            comp.thetaEditFieldLabel = uilabel(comp.GridLayout);
            comp.thetaEditFieldLabel.HorizontalAlignment = 'center';
            comp.thetaEditFieldLabel.WordWrap = 'on';
            comp.thetaEditFieldLabel.Layout.Row = 2;
            comp.thetaEditFieldLabel.Layout.Column = 3;
            comp.thetaEditFieldLabel.Text = 'theta';

        end
    end

end