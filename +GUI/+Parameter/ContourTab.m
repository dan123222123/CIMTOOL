classdef ContourTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ContourTypeButtonGroup              matlab.ui.container.ButtonGroup
        EllipseButton                       matlab.ui.control.ToggleButton
        CircleButton                        matlab.ui.control.ToggleButton
        ContourComponent                    GUI.Parameter.Contour.ContourComponent
    end

    properties (Access = public)
        CIMData Numerics.CIM
        PlotTab
    end
    
    methods

        function obj = ContourTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            % create dynamic component
            obj.ContourComponent = GUI.Parameter.Contour.CircleComponent(obj.GridLayout,obj.CIMData);
            obj.ContourComponent.Layout.Row = [1 5];
            obj.ContourComponent.Layout.Column = [3 5];

            % obj.addListeners();

        end

        % change the current contour type
        function ContourTypeButtonGroupSelectionChanged(comp,~)
            selectedButton = comp.ContourTypeButtonGroup.SelectedObject;
            oc = comp.CIMData.SampleData.Contour;
            switch(selectedButton.Text)
                case "Circle"
                    comp.CIMData.SampleData.Contour = Numerics.Contour.Circle(0,1,oc.N,comp.CIMData.MainAx);
                    comp.ContourComponent = GUI.Parameter.Contour.CircleComponent(comp.GridLayout,comp.CIMData);
                case "Ellipse"
                    comp.CIMData.SampleData.Contour = Numerics.Contour.Ellipse(0,1,1,oc.N,comp.CIMData.MainAx);
                    comp.ContourComponent = GUI.Parameter.Contour.EllipseComponent(comp.GridLayout,comp.CIMData);
            end
            comp.ContourComponent.Layout.Row = [1 5];
            comp.ContourComponent.Layout.Column = [3 5];
        end

        function updateFontSize(comp,update)
            comp.ContourComponent.updateFontSize(update);
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
            comp.ContourTypeButtonGroup = uibuttongroup(comp.GridLayout);
            comp.ContourTypeButtonGroup.SelectionChangedFcn = matlab.apps.createCallbackFcn(comp, @ContourTypeButtonGroupSelectionChanged, true);
            comp.ContourTypeButtonGroup.TitlePosition = 'centertop';
            comp.ContourTypeButtonGroup.Title = 'Type';
            comp.ContourTypeButtonGroup.Layout.Row = [1 5];
            comp.ContourTypeButtonGroup.Layout.Column = [1 2];
            %
            comp.CircleButton = uitogglebutton(comp.ContourTypeButtonGroup);
            comp.CircleButton.Text = 'Circle';
            comp.CircleButton.Position = [10 50 100 30];
            comp.CircleButton.Value = true; % default
            %
            comp.EllipseButton = uitogglebutton(comp.ContourTypeButtonGroup);
            comp.EllipseButton.Text = 'Ellipse';
            comp.EllipseButton.Position = [10 10 100 30];
        end

    end

end