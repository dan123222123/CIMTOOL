classdef ContourTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ContourTypeButtonGroup              matlab.ui.container.ButtonGroup
        EllipseButton                       matlab.ui.control.ToggleButton
        CircleButton                        matlab.ui.control.ToggleButton
        ContourComponent                    GUI.Parameter.Contour.ContourComponent
    end

    properties (Access = public)
        MainApp
        CIMData Numerics.CIM
        PlotTab
    end
    
    methods

        function obj = ContourTab(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.updateContourComponent();

            % obj.addListeners();

        end

        function updateContourComponent(comp)
            switch(class(comp.CIMData.SampleData.Contour))
                case {'Visual.Contour.Circle','Visual.Contour.SemiCircle'}
                    comp.CircleButton.Value = true;
                    comp.ContourComponent = GUI.Parameter.Contour.CircleComponent(comp.GridLayout,comp.CIMData);
                case 'Visual.Contour.Ellipse'
                    comp.ContourComponent = GUI.Parameter.Contour.EllipseComponent(comp.GridLayout,comp.CIMData);
                    comp.EllipseButton.Value = true;
            end
            comp.ContourComponent.Layout.Row = [1 5];
            comp.ContourComponent.Layout.Column = [3 5];
            comp.updateFontSize(comp.MainApp.FontSize);
        end

        function ContourTypeButtonGroupSelectionChanged(comp,~)
            selectedButton = comp.ContourTypeButtonGroup.SelectedObject;
            oc = comp.CIMData.SampleData.Contour;
            center = oc.gamma; N = oc.N;
            switch(class(oc))
                case 'Visual.Contour.Circle'
                    radius = comp.CIMData.SampleData.Contour.rho;
                case 'Visual.Contour.Ellipse'
                    radius = max(comp.CIMData.SampleData.Contour.alpha,comp.CIMData.SampleData.Contour.beta);
            end
            delete(comp.CIMData.SampleData.Contour); % MATLAB is slow to delete unreferenced objects...
            switch(selectedButton.Text)
                case "Circle"
                    comp.CIMData.SampleData.Contour = Visual.Contour.Circle(center,radius,N);
                case "Ellipse"
                    comp.CIMData.SampleData.Contour = Visual.Contour.Ellipse(center,radius,radius,N);
            end
            comp.updateContourComponent();
        end

        function updateFontSize(comp,update)
            comp.ContourComponent.updateFontSize(update);
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
            %
            comp.EllipseButton = uitogglebutton(comp.ContourTypeButtonGroup);
            comp.EllipseButton.Text = 'Ellipse';
            comp.EllipseButton.Position = [10 10 100 30];
        end

    end

end