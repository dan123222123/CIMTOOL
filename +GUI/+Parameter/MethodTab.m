classdef MethodTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ComputationalModeButtonGroup        matlab.ui.container.ButtonGroup
        MPLoewnerButton                     matlab.ui.control.ToggleButton
        SPLoewnerButton                     matlab.ui.control.ToggleButton
        HankelButton                        matlab.ui.control.ToggleButton
        MethodComponent                     GUI.Parameter.Method.MethodComponent
    end

    properties (Access = public)
        CIMData
    end
    
    methods

        function obj = MethodTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            % create dynamic component
            obj.MethodComponent = GUI.Parameter.Method.GenericMethodComponent(obj.GridLayout);
            obj.MethodComponent.Layout.Row = [1 5];
            obj.MethodComponent.Layout.Column = [3 5];

            % obj.addListeners();

        end

    end

    methods (Access = protected)

        function update(comp)
            %TODO
        end

        function setup(comp)
            comp.GridLayout = uigridlayout(comp.Parent,[5,5]);
            comp.GridLayout.Padding = [10 10 10 10];
            %
            comp.ComputationalModeButtonGroup = uibuttongroup(comp.GridLayout);
            % app.ComputationalModeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ComputationalModeButtonGroupSelectionChangedFcn, true);
            comp.ComputationalModeButtonGroup.TitlePosition = 'centertop';
            comp.ComputationalModeButtonGroup.Title = 'Computational Mode';
            comp.ComputationalModeButtonGroup.Layout.Row = [1 5];
            comp.ComputationalModeButtonGroup.Layout.Column = [1 2];
            %
            comp.HankelButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.HankelButton.Text = 'Hankel';
            comp.HankelButton.Position = [10 90 150 30];
            comp.HankelButton.Value = true;
            %
            comp.SPLoewnerButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.SPLoewnerButton.Text = 'SPLoewner';
            comp.SPLoewnerButton.Position = [10 50 150 30];
            %
            comp.MPLoewnerButton = uitogglebutton(comp.ComputationalModeButtonGroup);
            comp.MPLoewnerButton.Text = 'MPLoewner';
            comp.MPLoewnerButton.Position = [10 10 150 30];
        end

    end

end