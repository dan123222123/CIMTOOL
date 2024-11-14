classdef MethodTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ComputationalModeButtonGroup        matlab.ui.container.ButtonGroup
        MPLoewnerButton                     matlab.ui.control.ToggleButton
        SPLoewnerButton                     matlab.ui.control.ToggleButton
        HankelButton                        matlab.ui.control.ToggleButton
        %
        EstimateMCheckbox
        EigSearchEditFieldLabel
        EigSearchEditField
        %
        MethodComponent                     GUI.Parameter.Method.MethodComponent
    end

    properties (Access = public)
        CIMData Numerics.CIM
    end
    
    methods

        function obj = MethodTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            obj.updateMethodParameters();

            obj.updateMethodComponent();

            obj.addListeners();

        end

        function updateMethodComponent(comp)
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case Numerics.ComputationalMode.Hankel
                    comp.HankelButton.Value = true;
                case Numerics.ComputationalMode.SPLoewner
                    comp.SPLoewnerButton.Value = true;
                case Numerics.ComputationalMode.MPLoewner
                    comp.MPLoewnerButton.Value = true;
            end
            comp.MethodComponent = GUI.Parameter.Method.GenericMethodComponent(comp.GridLayout,comp.CIMData);
            comp.MethodComponent.Layout.Row = [1 5];
            comp.MethodComponent.Layout.Column = [3 5];
        end

        function addListeners(comp)
            addlistener(comp.CIMData.RealizationData,'ComputationalMode','PostSet',@(src,event)comp.updateMethodParameters);
            addlistener(comp.CIMData,'auto_estimate_m','PostSet',@(src,event)comp.updateMethodParameters);
            addlistener(comp.CIMData.RealizationData,'m','PostSet',@(src,event)comp.updateMethodParameters);
        end

        function updateFontSize(comp,update)
            comp.MethodComponent.updateFontSize(update);
        end

        function ComputationalModeChangedFcn(comp,~)

            % recover the original data matrix size in case we need to
            % update K according to the new choice
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    odms = min(comp.CIMData.SampleData.ell,comp.CIMData.SampleData.r)*comp.CIMData.RealizationData.K;
                case Numerics.ComputationalMode.MPLoewner
                    odms = comp.CIMData.RealizationData.K;
            end
            switch(comp.ComputationalModeButtonGroup.SelectedObject.Text)
                case "Hankel"
                    comp.CIMData.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
                case "SPLoewner"
                    comp.CIMData.RealizationData.ComputationalMode = Numerics.ComputationalMode.SPLoewner;
                case "MPLoewner"
                    comp.CIMData.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
            end
            if comp.CIMData.auto_update_K && min(comp.CIMData.SampleData.ell,comp.CIMData.SampleData.r) ~= 0
                switch(comp.CIMData.RealizationData.ComputationalMode)
                    case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                        comp.CIMData.RealizationData.K = ceil(odms/min(comp.CIMData.SampleData.ell,comp.CIMData.SampleData.r));
                    case Numerics.ComputationalMode.MPLoewner
                        comp.CIMData.RealizationData.K = odms;
                end
            end

        end

    end

    methods % CIM -> GUI

        function updateMethodParameters(comp,~)
            comp.EigSearchEditField.Value = comp.CIMData.RealizationData.m;
            comp.EstimateMCheckbox.Value = comp.CIMData.auto_estimate_m;
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case Numerics.ComputationalMode.Hankel
                    comp.HankelButton.Value = true;
                case Numerics.ComputationalMode.SPLoewner
                    comp.SPLoewnerButton.Value = true;
                case Numerics.ComputationalMode.MPLoewner
                    comp.MPLoewnerButton.Value = true;
            end
        end

    end

    methods % GUI -> CIM

        function MethodParametersChanged(comp,~)
            comp.CIMData.RealizationData.m = comp.EigSearchEditField.Value;
            comp.CIMData.auto_estimate_m = comp.EstimateMCheckbox.Value;
            % computational mode is changed in separate callback
            % (buttongroup)
        end

    end

    methods (Access = protected)

        function update(~)
            %TODO
        end

        function setup(comp)
            comp.GridLayout = uigridlayout(comp.Parent,[5,5]);
            comp.GridLayout.Padding = [10 10 10 10];
            %
            comp.ComputationalModeButtonGroup = uibuttongroup(comp.GridLayout);
            comp.ComputationalModeButtonGroup.SelectionChangedFcn = matlab.apps.createCallbackFcn(comp, @ComputationalModeChangedFcn, true);
            comp.ComputationalModeButtonGroup.TitlePosition = 'centertop';
            comp.ComputationalModeButtonGroup.Title = 'Computational Mode';
            comp.ComputationalModeButtonGroup.Layout.Row = [1 5];
            comp.ComputationalModeButtonGroup.Layout.Column = 1;
            % %
            comp.HankelButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.HankelButton.Text = 'Hankel';
            comp.HankelButton.Position = [10 90 150 30];
            % %
            comp.SPLoewnerButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.SPLoewnerButton.Text = 'SPLoewner';
            comp.SPLoewnerButton.Position = [10 50 150 30];
            % %
            comp.MPLoewnerButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.MPLoewnerButton.Text = 'MPLoewner';
            comp.MPLoewnerButton.Position = [10 10 150 30];
            %
            comp.EstimateMCheckbox = uicheckbox(comp.GridLayout,'Text','Auto Estimate # Eig Search');
            comp.EstimateMCheckbox.Layout.Row = [1 2];
            comp.EstimateMCheckbox.Layout.Column = 2;
            comp.EstimateMCheckbox.Enable = "off";
            %
            comp.EigSearchEditFieldLabel = uilabel(comp.GridLayout);
            comp.EigSearchEditFieldLabel.HorizontalAlignment = 'center';
            comp.EigSearchEditFieldLabel.Layout.Row = [2 3];
            comp.EigSearchEditFieldLabel.Layout.Column = 2;
            comp.EigSearchEditFieldLabel.Text = '# Eig Search';
            %
            comp.EigSearchEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.EigSearchEditField.Limits = [0 Inf];
            comp.EigSearchEditField.HorizontalAlignment = 'center';
            comp.EigSearchEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.EigSearchEditField.Value = 0;
            comp.EigSearchEditField.Layout.Row = [4 5];
            comp.EigSearchEditField.Layout.Column = 2;
            
        end

    end

end