classdef GenericMethodComponent < GUI.Parameter.Method.MethodComponent
    
    properties
        GridLayout
        %
        ProbingGridLayout
        LeftProbingSizeEditFieldLabel
        RightProbingSizeEditFieldLabel
        LeftProbingSizeEditField
        RightProbingSizeEditField
        %
        MethodDataParameterGridLayout
        EigSearchEditFieldLabel
        EigSearchEditField
        MaxMomentsEditFieldLabel
        MaxMomentsEditField
        % EstimateMCheckbox
    end

    properties (Access = public)
        CIMData Numerics.CIM
    end

    methods (Access = public)

        function obj = GenericMethodComponent(Parent,CIMData)

            obj@GUI.Parameter.Method.MethodComponent(Parent)
            obj.CIMData = CIMData;

            % obj.addListeners();

        end

    end

    methods (Access = protected)



        % function addListeners(comp)
        %     addlistener(comp.CIMData.SampleData.NLEVP,'loaded','PostSet',@(src,event)comp.NLEVPChangedFcn);
        %     addlistener(comp.CIMData.SampleData.Contour,'N','PostSet',@(src,event)comp.QuadratureChangedFcn);
        % end

        function MethodParametersChanged(comp,event)
            comp.CIMData.SampleData.ell = comp.LeftProbingSizeEditField.Value;
            comp.CIMData.SampleData.r = comp.RightProbingSizeEditField.Value;
            comp.CIMData.RealizationData.m = comp.EigSearchEditField.Value;
            comp.CIMData.RealizationData.K = comp.MaxMomentsEditField.Value;
        end
        
        function setup(comp)

            % do the layout in the parent grid, not the component
            % it has default position 100...
            comp.GridLayout = uigridlayout(comp,[2,1]);

            % Create ProbingLayout
            comp.ProbingGridLayout = uigridlayout(comp.GridLayout,[2,2]);
            comp.ProbingGridLayout.Layout.Row = 1;
            comp.ProbingGridLayout.Layout.Column = 1;
        
            % Create LeftProbingSizeEditFieldLabel
            comp.LeftProbingSizeEditFieldLabel = uilabel(comp.ProbingGridLayout);
            comp.LeftProbingSizeEditFieldLabel.HorizontalAlignment = 'center';
            comp.LeftProbingSizeEditFieldLabel.Layout.Row = 1;
            comp.LeftProbingSizeEditFieldLabel.Layout.Column = 1;
            comp.LeftProbingSizeEditFieldLabel.Text = 'ell';
        
            % Create LeftProbingSizeEditField
            comp.LeftProbingSizeEditField = uieditfield(comp.ProbingGridLayout, 'numeric');
            comp.LeftProbingSizeEditField.Limits = [0 Inf];
            comp.LeftProbingSizeEditField.HorizontalAlignment = 'center';
            comp.LeftProbingSizeEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.LeftProbingSizeEditField.Layout.Row = 2;
            comp.LeftProbingSizeEditField.Layout.Column = 1;
        
            % Create RightProbingSizeEditFieldLabel
            comp.RightProbingSizeEditFieldLabel = uilabel(comp.ProbingGridLayout);
            comp.RightProbingSizeEditFieldLabel.HorizontalAlignment = 'center';
            comp.RightProbingSizeEditFieldLabel.Layout.Row = 1;
            comp.RightProbingSizeEditFieldLabel.Layout.Column = 2;
            comp.RightProbingSizeEditFieldLabel.Text = 'r';
        
            % Create RightProbingSizeEditField
            comp.RightProbingSizeEditField = uieditfield(comp.ProbingGridLayout, 'numeric');
            comp.RightProbingSizeEditField.Limits = [0 Inf];
            comp.RightProbingSizeEditField.HorizontalAlignment = 'center';
            comp.RightProbingSizeEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.RightProbingSizeEditField.Layout.Row = 2;
            comp.RightProbingSizeEditField.Layout.Column = 2;
            %
            %
            % Create MethodDataParameterLayout
            comp.MethodDataParameterGridLayout = uigridlayout(comp.GridLayout,[2,2]);
            comp.MethodDataParameterGridLayout.Layout.Row = 2;
            comp.MethodDataParameterGridLayout.Layout.Column = 1;
        
            % Create EigSearchEditFieldLabel
            comp.EigSearchEditFieldLabel = uilabel(comp.MethodDataParameterGridLayout);
            comp.EigSearchEditFieldLabel.HorizontalAlignment = 'center';
            comp.EigSearchEditFieldLabel.Layout.Row = 1;
            comp.EigSearchEditFieldLabel.Layout.Column = 1;
            comp.EigSearchEditFieldLabel.Text = 'm';
        
            % Create EigSearchEditField
            comp.EigSearchEditField = uieditfield(comp.MethodDataParameterGridLayout, 'numeric');
            comp.EigSearchEditField.Limits = [0 Inf];
            comp.EigSearchEditField.HorizontalAlignment = 'center';
            comp.EigSearchEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.EigSearchEditField.Value = 0;
            comp.EigSearchEditField.Layout.Row = 2;
            comp.EigSearchEditField.Layout.Column = 1;
        
            % Create MaxMomentsEditFieldLabel
            comp.MaxMomentsEditFieldLabel = uilabel(comp.MethodDataParameterGridLayout);
            comp.MaxMomentsEditFieldLabel.HorizontalAlignment = 'center';
            comp.MaxMomentsEditFieldLabel.Layout.Row = 1;
            comp.MaxMomentsEditFieldLabel.Layout.Column = 2;
            comp.MaxMomentsEditFieldLabel.Text = 'K';
        
            % Create MaxMomentsEditField
            comp.MaxMomentsEditField = uieditfield(comp.MethodDataParameterGridLayout, 'numeric');
            comp.MaxMomentsEditField.Limits = [0 Inf];
            comp.MaxMomentsEditField.HorizontalAlignment = 'center';
            comp.MaxMomentsEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.MaxMomentsEditField.Layout.Row = 2;
            comp.MaxMomentsEditField.Layout.Column = 2;

            % comp.EstimateMCheckbox = uicheckbox(comp.MethodDataParameterGridLayout,'Text','Auto Estimate m');
            % comp.EstimateMCheckbox.HorizontalAlignment = 'center';
            % comp.EstimateMCheckbox.Layout.Row = 2;
            % comp.EstimateMCheckbox.Layout.Column = 2;
        end

    end
    
end

