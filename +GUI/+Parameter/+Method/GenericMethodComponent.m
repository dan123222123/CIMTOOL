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
        MaxMomentsEditFieldLabel
        MaxMomentsEditField
    end

    properties (Access = public)
        CIMData Numerics.CIM
    end

    methods (Access = public)

        function obj = GenericMethodComponent(Parent,CIMData)

            obj@GUI.Parameter.Method.MethodComponent(Parent)
            obj.CIMData = CIMData;

            % set defaults
            obj.updateLeftProbingSize();
            obj.updateRightProbingSize();
            obj.updateMaxMoments();

            obj.addListeners();

        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end

    methods % CIM -> GUI

        function updateKText(comp,~)
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    comp.MaxMomentsEditFieldLabel.Text = '# Moments';
                case Numerics.ComputationalMode.MPLoewner
                    comp.MaxMomentsEditFieldLabel.Text = '# Left/Right Interpolants';
            end
        end

        function updateLeftProbingSize(comp,~)
            comp.LeftProbingSizeEditField.Value = comp.CIMData.SampleData.ell;
        end

        function updateRightProbingSize(comp,~)
            comp.RightProbingSizeEditField.Value = comp.CIMData.SampleData.r;
        end

        function updateMaxMoments(comp,~)
            comp.MaxMomentsEditField.Value = comp.CIMData.RealizationData.K;
        end

    end

    methods % GUI -> CIM

        function MethodParametersChanged(comp,~)
            comp.CIMData.SampleData.ell = comp.LeftProbingSizeEditField.Value;
            comp.CIMData.SampleData.r = comp.RightProbingSizeEditField.Value;
            comp.CIMData.RealizationData.K = comp.MaxMomentsEditField.Value;
        end

    end

    methods (Access = protected)

        function addListeners(comp)
            addlistener(comp.CIMData.SampleData,'ell','PostSet',@(src,event)comp.updateLeftProbingSize);
            addlistener(comp.CIMData.SampleData,'r','PostSet',@(src,event)comp.updateRightProbingSize);
            addlistener(comp.CIMData.RealizationData,'K','PostSet',@(src,event)comp.updateMaxMoments);
            addlistener(comp.CIMData.RealizationData,'ComputationalMode','PostSet',@(src,event)comp.updateKText);
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
            comp.LeftProbingSizeEditFieldLabel.Text = '# Left Tangential Directions';
        
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
            comp.RightProbingSizeEditFieldLabel.Text = '# Right Tangential Directions';
        
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
        
            % Create MaxMomentsEditFieldLabel
            comp.MaxMomentsEditFieldLabel = uilabel(comp.MethodDataParameterGridLayout);
            comp.MaxMomentsEditFieldLabel.HorizontalAlignment = 'center';
            comp.MaxMomentsEditFieldLabel.Layout.Row = 1;
            comp.MaxMomentsEditFieldLabel.Layout.Column = [1 2];
            comp.MaxMomentsEditFieldLabel.Text = '# Moments';
        
            % Create MaxMomentsEditField
            comp.MaxMomentsEditField = uieditfield(comp.MethodDataParameterGridLayout, 'numeric');
            comp.MaxMomentsEditField.Limits = [0 Inf];
            comp.MaxMomentsEditField.HorizontalAlignment = 'center';
            comp.MaxMomentsEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.MaxMomentsEditField.Layout.Row = 2;
            comp.MaxMomentsEditField.Layout.Column = [1 2];

        end

    end
    
end

