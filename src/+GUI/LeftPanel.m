classdef LeftPanel < matlab.ui.componentcontainer.ComponentContainer
    
    properties (Access = public)
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
        DataMatrixSizeLabel
        DataMatrixSize
        %
        ComputeButton
        AutoSampleCheckBox
        AutoRealizationCheckBox
        %
        RefineQuadratureButton
        %
        PlotViewportControl
        % % %
        MainApp
        CIMData                     Numerics.CIM
        MainPlotAxes
    end

    methods (Access = public)
        
        function obj = LeftPanel(Parent,MainApp,CIMData,MainPlotAxes)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;
            obj.MainPlotAxes = MainPlotAxes;

            obj.createDynamicComponents();

            obj.setDefaults();

            obj.addListeners();

        end

        function createDynamicComponents(comp)
            comp.PlotViewportControl = GUI.Plot.PlotViewportComplexPlane(comp.GridLayout,comp.MainPlotAxes);
            comp.PlotViewportControl.Layout.Row = 7;
            comp.PlotViewportControl.Layout.Column = [1 3];    
        end

        function setDefaults(comp)
            CIM = comp.CIMData;
            comp.NLEVPDataChangedFcn(missing);
            comp.DataDirtinessChangedFcn(missing);
            comp.NumQuadNodes.Value = CIM.SampleData.Contour.N;
            % comp.AutoSampleCheckBox.Value = CIM.auto_compute_samples;
            % comp.AutoRealizationCheckBox.Value = CIM.auto_compute_realization;
        end

        function addListeners(comp)
            addlistener(comp.CIMData.SampleData.NLEVPData,'loaded','PostSet',@(src,event)comp.NLEVPDataChangedFcn);
            addlistener(comp.CIMData.SampleData.Contour,'N','PostSet',@(src,event)comp.QuadratureChangedFcn);
            addlistener(comp.CIMData.ResultData,'Db','PostSet',@(src,event)comp.DataMatrixSizeChangedFcn);
            addlistener(comp.CIMData,'DataDirtiness','PostSet',@(src,event)comp.DataDirtinessChangedFcn);
            addlistener(comp.MainApp,'FontSize','PostSet',@(src,event)comp.updateFontSize);
            % listeners for reference changes
            addlistener(comp.CIMData.SampleData,'Contour','PostSet',@(src,event)comp.updateContourListeners);
        end

        function updateContourListeners(comp,~)
            addlistener(comp.CIMData.SampleData.Contour,'N','PostSet',@(src,event)comp.QuadratureChangedFcn);
            comp.QuadratureChangedFcn(missing);
        end

        function updateFontSize(comp,~)
            fontsize(comp.GridLayout.Children,comp.MainApp.FontSize,"points");
            comp.PlotViewportControl.updateFontSize(comp.MainApp.FontSize);
        end

    end

    methods % CIM -> GUI
        
        function NLEVPDataChangedFcn(comp,~)
            CIM = comp.CIMData;
            if CIM.SampleData.NLEVPData.loaded
                if all(ismissing(CIM.SampleData.NLEVPData.name))
                    comp.ProblemName.Value = "";
                else
                    comp.ProblemName.Value = CIM.SampleData.NLEVPData.name;
                end
                comp.ProblemSize.Value = CIM.SampleData.NLEVPData.n;
            else
                comp.ProblemName.Value = "Not Loaded";
                comp.ProblemSize.Value = CIM.SampleData.NLEVPData.n;
            end
        end

        function QuadratureChangedFcn(comp,~)
            comp.NumQuadNodes.Value = comp.CIMData.SampleData.Contour.N;
        end

        function DataMatrixSizeChangedFcn(comp,~)
            comp.DataMatrixSize.Value = size(comp.CIMData.ResultData.Db,1);
        end

        function DataDirtinessChangedFcn(comp,~)
            CIM = comp.CIMData;
            if CIM.DataDirtiness == 2
                comp.ComputeButton.BackgroundColor = "g";
            elseif CIM.DataDirtiness == 1
                comp.ComputeButton.BackgroundColor = "y";
            else
                comp.ComputeButton.BackgroundColor = [0.96 0.96 0.96];
            end
        end
            
    end

    methods % GUI -> CIM

        function ComputeButtonPushed(comp,~)
            try
                comp.CIMData.compute();
            catch e
                comp.ComputeButton.BackgroundColor = "r";
                uialert(comp.MainApp.UIFigure,e.message,"Compute Error","Interpreter","html");
                % rethrow(e);
            end
        end

        function RefineQuadratureButtonPushed(comp,~)
            try
                comp.CIMData.refineQuadrature();
            catch e
                comp.ComputeButton.BackgroundColor = "r";
                uialert(comp.MainApp.UIFigure,e.message,"Refine Quadrature Error","Interpreter","html");
            end
        end

        function NumQuadNodesChanged(comp,~)
            comp.CIMData.SampleData.Contour.N = comp.NumQuadNodes.Value;
        end

        function AutoButtonsChanged(comp,~)
            comp.CIMData.auto_compute_samples = comp.AutoSampleCheckBox.Value;
            comp.CIMData.auto_compute_realization = comp.AutoRealizationCheckBox.Value;
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
            comp.ProblemName = uieditfield(comp.GridLayout,"text");
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
            comp.ProblemSize = uieditfield(comp.GridLayout,"numeric");
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
            comp.NumQuadNodes = uieditfield(comp.GridLayout,"numeric");
            comp.NumQuadNodes.HorizontalAlignment = 'center';
            comp.NumQuadNodes.FontName = 'Hack';
            comp.NumQuadNodes.Placeholder = 'N/A';
            comp.NumQuadNodes.Layout.Row = 3;
            comp.NumQuadNodes.Layout.Column = [2 3];
            comp.NumQuadNodes.ValueChangedFcn = matlab.apps.createCallbackFcn(comp,@NumQuadNodesChanged,true);
            % %
            % comp.AutoSampleCheckBox = uicheckbox(comp.GridLayout,'Text','Auto Compute Samples');
            % comp.AutoSampleCheckBox.WordWrap = 'on';
            % comp.AutoSampleCheckBox.Layout.Row = 4;
            % comp.AutoSampleCheckBox.Layout.Column = 3;
            % comp.AutoSampleCheckBox.ValueChangedFcn = matlab.apps.createCallbackFcn(comp,@AutoButtonsChanged,true);
            % comp.AutoSampleCheckBox.Enable = "off";
            % % %
            % comp.AutoRealizationCheckBox = uicheckbox(comp.GridLayout,'Text','Auto Compute Realization');
            % comp.AutoRealizationCheckBox.WordWrap = 'on';
            % comp.AutoRealizationCheckBox.Layout.Row = 5;
            % comp.AutoRealizationCheckBox.Layout.Column = 3;
            % comp.AutoRealizationCheckBox.ValueChangedFcn = matlab.apps.createCallbackFcn(comp,@AutoButtonsChanged,true);
            % comp.AutoRealizationCheckBox.Enable = "off";
            % %
            comp.ComputeButton = uibutton(comp.GridLayout);
            comp.ComputeButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @ComputeButtonPushed, true);
            comp.ComputeButton.Text = 'Compute';
            comp.ComputeButton.Layout.Row = 4;
            comp.ComputeButton.Layout.Column = [1 3];
            % %
            comp.DataMatrixSizeLabel = uilabel(comp.GridLayout);
            comp.DataMatrixSizeLabel.HorizontalAlignment = 'center';
            comp.DataMatrixSizeLabel.Text = 'Data Matrix Size';
            comp.DataMatrixSizeLabel.WordWrap = 'on';
            comp.DataMatrixSizeLabel.Layout.Row = 5;
            comp.DataMatrixSizeLabel.Layout.Column = 1;
            %
            comp.DataMatrixSize = uieditfield(comp.GridLayout,"numeric");
            comp.DataMatrixSize.HorizontalAlignment = 'center';
            comp.DataMatrixSize.FontName = 'Hack';
            comp.DataMatrixSize.Placeholder = 'N/A';
            comp.DataMatrixSize.Layout.Row = 5;
            comp.DataMatrixSize.Layout.Column = [2 3];
            comp.DataMatrixSize.Editable = 'off';
            % %
            comp.RefineQuadratureButton = uibutton(comp.GridLayout);
            comp.RefineQuadratureButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @RefineQuadratureButtonPushed, true);
            comp.RefineQuadratureButton.Text = 'Refine Quadrature';
            comp.RefineQuadratureButton.Layout.Row = 6;
            comp.RefineQuadratureButton.Layout.Column = [1 3];
        
        end

    end

end

