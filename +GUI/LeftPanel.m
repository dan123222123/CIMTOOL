classdef LeftPanel < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout
        %
        ProblemNameLabel
        ProblemName
        %
        ProblemSizeLabel
        ProblemSize
        %
        NumQuadNodesLabel
        NumQuadNodes
        %
        ComputeButton
        AutoSampleCheckBox
        AutoRealizationCheckBox
        %
        RefineQuadratureButton
        %
        PlotViewportControl
    end

    properties (Access = public)
        MainApp
        CIMData
    end

    methods (Access = public)
        
        function obj = LeftPanel(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.createDynamicComponents();

        end

        function createDynamicComponents(comp)
            comp.PlotViewportControl = GUI.Plot.PlotViewportComplexPlane(comp.GridLayout,comp.MainApp.PlotPanel.MainPlotAxes);
            comp.PlotViewportControl.Layout.Row = 7;
            comp.PlotViewportControl.Layout.Column = [1 3];    
        end

    end
    
    methods (Access = protected)

        function update(comp)
            %TODO
        end

        function setup(comp)

            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.RowHeight = {'0.5x','0.5x','0.5x','0.5x','0.5x','0.5x','2x'};
            % %
            comp.ProblemNameLabel = uilabel(comp.GridLayout);
            comp.ProblemNameLabel.HorizontalAlignment = 'center';
            comp.ProblemNameLabel.Text = 'Problem Name';
            comp.ProblemNameLabel.WordWrap = 'on';
            comp.ProblemNameLabel.Layout.Row = 1;
            comp.ProblemNameLabel.Layout.Column = 1;
            %
            comp.ProblemName = uitextarea(comp.GridLayout);
            comp.ProblemName.Editable = 'off';
            comp.ProblemName.HorizontalAlignment = 'center';
            comp.ProblemName.FontName = 'Hack';
            comp.ProblemName.Placeholder = 'None';
            comp.ProblemName.Layout.Row = 1;
            comp.ProblemName.Layout.Column = [2 3];
            % %
            comp.ProblemSizeLabel = uilabel(comp.GridLayout);
            comp.ProblemSizeLabel.HorizontalAlignment = 'center';
            comp.ProblemSizeLabel.Text = 'Problem Size';
            comp.ProblemSizeLabel.WordWrap = 'on';
            comp.ProblemSizeLabel.Layout.Row = 2;
            comp.ProblemSizeLabel.Layout.Column = 1;
            %
            comp.ProblemSize = uitextarea(comp.GridLayout);
            comp.ProblemSize.Editable = 'off';
            comp.ProblemSize.HorizontalAlignment = 'center';
            comp.ProblemSize.FontName = 'Hack';
            comp.ProblemSize.Placeholder = 'N/A';
            comp.ProblemSize.Layout.Row = 2;
            comp.ProblemSize.Layout.Column = [2 3];
            % %
            comp.NumQuadNodesLabel = uilabel(comp.GridLayout);
            comp.NumQuadNodesLabel.HorizontalAlignment = 'center';
            comp.NumQuadNodesLabel.Text = '# Quad Nodes';
            comp.NumQuadNodesLabel.WordWrap = 'on';
            comp.NumQuadNodesLabel.Layout.Row = 3;
            comp.NumQuadNodesLabel.Layout.Column = 1;
            %
            comp.NumQuadNodes = uitextarea(comp.GridLayout);
            comp.NumQuadNodes.HorizontalAlignment = 'center';
            comp.NumQuadNodes.FontName = 'Hack';
            comp.NumQuadNodes.Placeholder = 'N/A';
            comp.NumQuadNodes.Layout.Row = 3;
            comp.NumQuadNodes.Layout.Column = [2 3];
            % %
            comp.AutoSampleCheckBox = uicheckbox(comp.GridLayout,'Text','Auto Compute Samples');
            comp.AutoSampleCheckBox.WordWrap = 'on';
            comp.AutoSampleCheckBox.Layout.Row = 4;
            comp.AutoSampleCheckBox.Layout.Column = 3;
            % %
            comp.AutoRealizationCheckBox = uicheckbox(comp.GridLayout,'Text','Auto Compute Realization');
            comp.AutoRealizationCheckBox.WordWrap = 'on';
            comp.AutoRealizationCheckBox.Layout.Row = 5;
            comp.AutoRealizationCheckBox.Layout.Column = 3;
            % %
            comp.ComputeButton = uibutton(comp.GridLayout);
            % app.ComputeButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeButtonPushed, true);
            comp.ComputeButton.Text = 'Compute';
            comp.ComputeButton.Layout.Row = [4 5];
            comp.ComputeButton.Layout.Column = [1 2];
            % %
            comp.RefineQuadratureButton = uibutton(comp.GridLayout);
            comp.RefineQuadratureButton.Text = 'Refine Quadrature';
            comp.RefineQuadratureButton.Layout.Row = 6;
            comp.RefineQuadratureButton.Layout.Column = [1 3];
        
        end

    end

end

