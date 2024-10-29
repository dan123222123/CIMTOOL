classdef ContourTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ContourTypeButtonGroup              matlab.ui.container.ButtonGroup
        EllipseButton                       matlab.ui.control.ToggleButton
        CircleButton                        matlab.ui.control.ToggleButton
        ContourComponent                    GUI.Parameter.Contour.ContourComponent
    end

    properties (Access = public)
        CIMData
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
        function ContourTypeButtonGroupSelectionChanged(comp, event)
            selectedButton = comp.ContourTypeButtonGroup.SelectedObject;
            switch(selectedButton.Text)
                case "Circle"
                    comp.ContourComponent = GUI.Parameter.Contour.CircleComponent(comp.GridLayout,comp.CIMData);
                % case "Ellipse"
                %     comp.ContourComponent = GUI.Parameter.Contour.EllipseComponent(comp.ContourTabGridLayout,comp.CIMData);

            end
            comp.ContourComponent.Layout.Row = [1 5];
            comp.ContourComponent.Layout.Column = [3 5];
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
            comp.ContourTypeButtonGroup.SelectionChangedFcn = @(src,event)ContourTypeButtonGroupSelectionChanged;
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
            comp.EllipseButton.Enable = 'off';
            comp.EllipseButton.Text = 'Ellipse';
            comp.EllipseButton.Position = [10 10 100 30];
        end

    end

end