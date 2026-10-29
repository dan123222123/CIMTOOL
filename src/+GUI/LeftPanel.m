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
        ReferenceStatusLayout
        ReferenceStatusLabel
        ReferenceCancelButton
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

    properties (Access = private)
        % Store listener handles for cleanup
        listeners = []
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
            comp.PlotViewportControl.Layout.Row = 8;
            comp.PlotViewportControl.Layout.Column = [1 3];    
        end

        function setDefaults(comp)
            CIM = comp.CIMData;
            comp.OperatorDataChangedFcn(missing);
            comp.ReferenceStatusChangedFcn(missing);
            comp.DataDirtinessChangedFcn(missing);
            comp.DataMatrixSizeChangedFcn(missing);
            comp.QuadratureChangedFcn(missing);
            % comp.AutoSampleCheckBox.Value = CIM.auto_compute_samples;
            % comp.AutoRealizationCheckBox.Value = CIM.auto_compute_realization;
        end

        function addListeners(comp)
            % Store listener handles so they can be deleted when component is destroyed;
            % each follows its object when the CIM's parts are replaced (GUI.SubObjectListener)
            cim = comp.CIMData;
            comp.listeners = [
                GUI.SubObjectListener(cim,"SampleData.OperatorData",'loaded',@(~,~)comp.OperatorDataChangedFcn([]))
                GUI.SubObjectListener(cim,"SampleData.OperatorData",'ReferenceStatus',@(~,~)comp.ReferenceStatusChangedFcn([]))
                GUI.SubObjectListener(cim,"SampleData.Contour",'N',@(~,~)comp.QuadratureChangedFcn([]))
                GUI.SubObjectListener(cim,"ResultData",'Db',@(~,~)comp.DataMatrixSizeChangedFcn([]))
                GUI.SubObjectListener(cim,"",'DataDirtiness',@(~,~)comp.DataDirtinessChangedFcn([]))
                GUI.SubObjectListener(comp.MainApp,"",'FontSize',@(~,~)comp.updateFontSize([]))
            ];
        end

        function updateFontSize(comp,~)
            fontsize(comp.GridLayout.Children,comp.MainApp.FontSize,"points");
            comp.PlotViewportControl.updateFontSize(comp.MainApp.FontSize);
        end

    end

    methods % CIM -> GUI
        
        function OperatorDataChangedFcn(comp,~)
            CIM = comp.CIMData;
            if CIM.SampleData.OperatorData.loaded
                if all(ismissing(CIM.SampleData.OperatorData.name))
                    comp.ProblemName.Value = "";
                else
                    comp.ProblemName.Value = CIM.SampleData.OperatorData.name;
                end
                comp.ProblemSize.Value = CIM.SampleData.OperatorData.n;
            else
                comp.ProblemName.Value = "Not Loaded";
                comp.ProblemSize.Value = CIM.SampleData.OperatorData.n;
            end
        end

        function ReferenceStatusChangedFcn(comp,~)
            % the operator's reference computation; the row collapses when there is none, and x shows while computing
            op = comp.CIMData.SampleData.OperatorData;
            switch op.ReferenceStatus
                case "computing"
                    comp.ReferenceStatusLabel.Text = 'Reference eigenvalues: computing...';
                case "skipped"
                    comp.ReferenceStatusLabel.Text = sprintf('Reference eigenvalues: skipped (n*d > %g)',op.MaxReferenceSize);
                otherwise
                    comp.ReferenceStatusLabel.Text = 'Reference eigenvalues: ' + op.ReferenceStatus;
            end
            computing = op.ReferenceStatus == "computing";
            comp.ReferenceCancelButton.Visible = computing;
            if op.ReferenceStatus == "none"
                comp.GridLayout.RowHeight{3} = 0;
            else
                comp.GridLayout.RowHeight{3} = '0.5x';
            end
        end

        function QuadratureChangedFcn(comp,~)
            contour = comp.CIMData.SampleData.Contour;
            if isempty(contour)   % none chosen yet: the placeholder
                comp.NumQuadNodes.Value = '';
            elseif isprop(contour, 'N')
                comp.NumQuadNodes.Value = num2str(contour.N);
            else   % a plain Quad: its node count
                comp.NumQuadNodes.Value = num2str(numel(contour.z));
            end
        end

        function DataMatrixSizeChangedFcn(comp,~)
            comp.DataMatrixSize.Value = size(comp.CIMData.ResultData.Db,1);
        end

        function DataDirtinessChangedFcn(comp,~)
            CIM = comp.CIMData;
            if CIM.DataDirtiness == 2
                comp.ComputeButton.BackgroundColor = [0.4 0.75 0.45];
                comp.ComputeButton.FontColor = [1 1 1];
            elseif CIM.DataDirtiness == 1
                comp.ComputeButton.BackgroundColor = [0.9 0.75 0.3];
                comp.ComputeButton.FontColor = [0 0 0];
            else
                comp.ComputeButton.BackgroundColor = [0.96 0.96 0.96];
                comp.ComputeButton.FontColor = [0 0 0];
            end
        end
            
    end

    methods % GUI -> CIM

        function ComputeButtonPushed(comp,~)
            try
                comp.CIMData.compute();
            catch e
                comp.ComputeButton.BackgroundColor = [0.85 0.35 0.35];
                comp.ComputeButton.FontColor = [1 1 1];
                uialert(comp.MainApp.UIFigure,e.message,"Compute Error","Interpreter","html");
                % rethrow(e);
                return;
            end
            comp.confirmWeakGap();
        end

        function RefineQuadratureButtonPushed(comp,~)
            try
                comp.CIMData.refineQuadrature();
            catch e
                comp.ComputeButton.BackgroundColor = [0.85 0.35 0.35];
                comp.ComputeButton.FontColor = [1 1 1];
                uialert(comp.MainApp.UIFigure,e.message,"Refine Quadrature Error","Interpreter","html");
                return;
            end
            comp.confirmWeakGap();
        end

        function confirmWeakGap(comp)
            % after a compute from the GUI: a weak gap under the Gap rule (GapRatio is NaN under any other choice of m)
            % offers to keep its m as a manual m; scripts keep AutoRank
            cim = comp.CIMData;
            ratio = cim.ResultData.GapRatio;
            gapmin = 1e3;
            if isfield(cim.options,"GapMin"); gapmin = cim.options.GapMin; end
            if ~(ratio < gapmin)
                return;
            end
            m = cim.ResultData.m;
            msg = sprintf("The largest singular-value gap, &sigma;<sub>%d</sub>/&sigma;<sub>%d</sub> = %.3g, is below GapMin = %g, " + ...
                "and the realization uses m = %d. Refining the quadrature, or raising K, may open a gap.", m, m + 1, ratio, gapmin, m);
            uiconfirm(comp.MainApp.UIFigure,msg,"Weak Singular-Value Gap","Interpreter","html","Icon","warning", ...
                "Options",{sprintf('Switch to manual (m = %d)',m),'Keep automatic'},"DefaultOption",1,"CancelOption",2, ...
                "CloseFcn",@(~,event)comp.weakGapClosed(event,m));
        end

        function weakGapClosed(comp,event,m)
            % the first option fixes m and unticks Auto, so the m field is editable at that value
            if event.SelectedOptionIndex == 1
                rd = comp.CIMData.RealizationData;
                [theta,sigma] = rd.getThetaSigma();
                rd.RealizationSize.m = m;
                rd.AutoRank = false;
                % the realization on screen is the manual one at m, unless the switch moved the interpolation points
                [theta1,sigma1] = rd.getThetaSigma();
                if comp.CIMData.SampleData.loaded && isequal(theta,theta1) && isequal(sigma,sigma1)
                    comp.CIMData.ResultData.GapRatio = NaN;
                    rd.loaded = true;
                end
            end
        end

        function ReferenceCancelButtonPushed(comp,~)
            comp.CIMData.SampleData.OperatorData.cancelReference();
        end

        function NumQuadNodesChanged(comp,~)
            contour = comp.CIMData.SampleData.Contour;
            if isempty(contour) || ~isprop(contour, 'N')   % no contour yet, or a plain Quad with fixed nodes
                comp.QuadratureChangedFcn(missing);
                return;
            end
            contour.N = str2num(comp.NumQuadNodes.Value);
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
            comp.GridLayout.RowHeight = {'0.5x','0.5x',0,'0.5x','0.5x','0.5x','0.5x','2x'};
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
            % % the reference eigenvalue status; row 3 collapses while there is none
            comp.ReferenceStatusLayout = uigridlayout(comp.GridLayout,[3 2]);
            comp.ReferenceStatusLayout.ColumnWidth = {'1x','fit'};
            comp.ReferenceStatusLayout.RowHeight = {'1x','fit','1x'};
            comp.ReferenceStatusLayout.RowSpacing = 0;
            comp.ReferenceStatusLayout.Padding = [0 0 0 0];
            comp.ReferenceStatusLayout.Layout.Row = 3;
            comp.ReferenceStatusLayout.Layout.Column = [1 3];
            %
            comp.ReferenceStatusLabel = uilabel(comp.ReferenceStatusLayout);
            comp.ReferenceStatusLabel.HorizontalAlignment = 'center';
            comp.ReferenceStatusLabel.WordWrap = 'on';
            comp.ReferenceStatusLabel.Text = '';
            comp.ReferenceStatusLabel.Layout.Row = [1 3];
            comp.ReferenceStatusLabel.Layout.Column = 1;
            %
            comp.ReferenceCancelButton = uibutton(comp.ReferenceStatusLayout);
            comp.ReferenceCancelButton.Layout.Row = 2;
            comp.ReferenceCancelButton.Layout.Column = 2;
            comp.ReferenceCancelButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @ReferenceCancelButtonPushed, true);
            comp.ReferenceCancelButton.Text = 'x';
            comp.ReferenceCancelButton.Tooltip = 'Cancel the reference eigenvalue computation';
            comp.ReferenceCancelButton.Visible = 'off';
            % %
            comp.NumQuadNodesLabel = uilabel(comp.GridLayout);
            comp.NumQuadNodesLabel.HorizontalAlignment = 'center';
            comp.NumQuadNodesLabel.Text = '# Quad Nodes';
            comp.NumQuadNodesLabel.WordWrap = 'on';
            comp.NumQuadNodesLabel.Layout.Row = 4;
            comp.NumQuadNodesLabel.Layout.Column = 1;
            %
            comp.NumQuadNodes = uieditfield(comp.GridLayout,"text");
            comp.NumQuadNodes.HorizontalAlignment = 'center';
            comp.NumQuadNodes.FontName = 'Hack';
            comp.NumQuadNodes.Placeholder = 'N/A';
            comp.NumQuadNodes.Layout.Row = 4;
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
            comp.ComputeButton.FontWeight = 'bold';
            comp.ComputeButton.Layout.Row = 5;
            comp.ComputeButton.Layout.Column = [1 3];
            % %
            comp.DataMatrixSizeLabel = uilabel(comp.GridLayout);
            comp.DataMatrixSizeLabel.HorizontalAlignment = 'center';
            comp.DataMatrixSizeLabel.Text = 'Data Matrix Size';
            comp.DataMatrixSizeLabel.WordWrap = 'on';
            comp.DataMatrixSizeLabel.Layout.Row = 6;
            comp.DataMatrixSizeLabel.Layout.Column = 1;
            %
            comp.DataMatrixSize = uieditfield(comp.GridLayout,"numeric");
            comp.DataMatrixSize.HorizontalAlignment = 'center';
            comp.DataMatrixSize.FontName = 'Hack';
            comp.DataMatrixSize.Placeholder = 'N/A';
            comp.DataMatrixSize.Layout.Row = 6;
            comp.DataMatrixSize.Layout.Column = [2 3];
            comp.DataMatrixSize.Editable = 'off';
            % %
            comp.RefineQuadratureButton = uibutton(comp.GridLayout);
            comp.RefineQuadratureButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @RefineQuadratureButtonPushed, true);
            comp.RefineQuadratureButton.Text = 'Refine Quadrature';
            comp.RefineQuadratureButton.FontWeight = 'bold';
            comp.RefineQuadratureButton.Layout.Row = 7;
            comp.RefineQuadratureButton.Layout.Column = [1 3];
        
        end

        function delete(comp)
            Visual.deleteListeners(comp.listeners);
        end

    end

end

