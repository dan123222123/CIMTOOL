classdef CIMTOOL < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        FileMenu                       matlab.ui.container.Menu
        ImportNLEVPMenu                matlab.ui.container.Menu
        WorkspaceMenu                  matlab.ui.container.Menu
        ImportNLEVPFileMenu            matlab.ui.container.Menu
        NLEVPPackMenu                  matlab.ui.container.Menu
        ExportMenu                     matlab.ui.container.Menu
        EigenvaluesMenu                matlab.ui.container.Menu
        MomentsMenu                    matlab.ui.container.Menu
        FigureMenu                     matlab.ui.container.Menu
        PreferencesMenu                matlab.ui.container.Menu
        ShiftPatternMenu               matlab.ui.container.Menu
        equispacedMenu                 matlab.ui.container.Menu
        randomMenu                     matlab.ui.container.Menu
        PlottingAttributesMenu         matlab.ui.container.Menu
        ComputationMenu                matlab.ui.container.Menu
        AppGridLayout                  matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        QuadNodesEditField             matlab.ui.control.NumericEditField
        QuadNodesEditFieldLabel        matlab.ui.control.Label
        IMINEditField                  matlab.ui.control.NumericEditField
        IMINEditFieldLabel             matlab.ui.control.Label
        RMAXEditField                  matlab.ui.control.NumericEditField
        RMAXEditFieldLabel             matlab.ui.control.Label
        RMINEditField                  matlab.ui.control.NumericEditField
        RMINEditFieldLabel             matlab.ui.control.Label
        IMAXEditField                  matlab.ui.control.NumericEditField
        IMAXEditFieldLabel             matlab.ui.control.Label
        PROBLEMLOADEDTextArea          matlab.ui.control.TextArea
        PROBLEMLOADEDTextAreaLabel     matlab.ui.control.Label
        ShiftsButton                   matlab.ui.control.Button
        ComputeButton                  matlab.ui.control.Button
        ComputationalModeButtonGroup   matlab.ui.container.ButtonGroup
        MPLoewnerButton                matlab.ui.control.ToggleButton
        SPLoewnerButton                matlab.ui.control.ToggleButton
        HankelButton                   matlab.ui.control.ToggleButton
        RightPanel                     matlab.ui.container.Panel
        RightPanelGridLayout           matlab.ui.container.GridLayout
        ParameterTabGroup              matlab.ui.container.TabGroup
        NLEVPInformationTab            matlab.ui.container.Tab
        NLEVPHelpTextArea              matlab.ui.control.TextArea
        MethodTab                      matlab.ui.container.Tab
        MethodTabGridLayout            matlab.ui.container.GridLayout
        MethodDataParameterGridLayout  matlab.ui.container.GridLayout
        MaxMomentsEditField            matlab.ui.control.NumericEditField
        MaxMomentsEditFieldLabel       matlab.ui.control.Label
        EigSearchEditField             matlab.ui.control.NumericEditField
        EigSearchEditFieldLabel        matlab.ui.control.Label
        ProbingGridLayout              matlab.ui.container.GridLayout
        RightProbingSizeEditField      matlab.ui.control.NumericEditField
        RightProbingSizeEditFieldLabel matlab.ui.control.Label
        LeftProbingSizeEditField       matlab.ui.control.NumericEditField
        LeftProbingSizeEditFieldLabel  matlab.ui.control.Label        
        ContourTab                     matlab.ui.container.Tab
        ContourTabGridLayout           matlab.ui.container.GridLayout
        contourparameters              ContourComponentInterface
        ContourTypeButtonGroup         matlab.ui.container.ButtonGroup
        RectangleButton                matlab.ui.control.RadioButton
        EllipseButton                  matlab.ui.control.RadioButton
        CircleButton                   matlab.ui.control.RadioButton
        ShiftsTab                      matlab.ui.container.Tab
        ShiftsTabGridLayout            matlab.ui.container.GridLayout
        ShiftsTable                    matlab.ui.control.Table
        EigenvaluesTab                 matlab.ui.container.Tab
        EigenvaluesTabGridLayout       matlab.ui.container.GridLayout
        EigenvaluesTable               matlab.ui.control.Table
        PlotTabGroup                   matlab.ui.container.TabGroup

    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    properties (Access = public)
        idxKey
    end

    % observable data properties -- easier than separate events, can
    % probably switch over to make the code simpler
    properties (SetObservable,AbortSet)
        ViewPortDimensions % [xmin, xmax, ymin, ymax]
        NumQuadNodes
        NumEigSearch
        NumMaxMoments
        tol = NaN
    end

    % Plot handles
    properties (Access = public)
        NLEVPPlotHandles
        ContourPlotHandles
        InterpolationDataPlotHandles
        ResultDataPlotHandles
        swPlotHandles
    end

    events
        ContourDataChanged
        NLEVPDataChanged
        ResultDataChanged
        InterpolationDataChanged
    end
    
    % CIM computation
    methods (Access = public)

        function recordKey(app,src,event)
            app.idxKey = [contains(event.Key,'control'), contains(event.Key,'shift')];
            if any(app.idxKey)
                set(app.MainPlotAxes.Title,'String','MOD');
            end
            set(app.UIFigure,'WindowButtonDownFcn',@app.MainPlotAxesWindowButtonDownFcn);
            app.MainPlotAxes.Interactions = dataTipInteraction('SnapToDataVertex','on');
            app.MainPlotAxes.PickableParts = "all";
        end

        function releaseKey(app,src,event)
            set(app.MainPlotAxes.Title,'String','NORMAL');
            app.idxKey = [false false];
            set(app.UIFigure,'WindowButtonDownFcn','');
            set(app.UIFigure,'WindowButtonMotionFcn','');
            set(app.UIFigure,'WindowButtonUpFcn','');
            app.MainPlotAxes.Interactions = [panInteraction('Dimensions','xy') zoomInteraction('Dimensions','xy')];
        end

        % this callback will be set when CTRL/SHIFT is pressed
        % should allow for axes interactivity when not selected, while
        % allowing the user to affect CIM parameters when desired
        function MainPlotAxesWindowButtonDownFcn(app,handle,event)
            cf = gco(app.UIFigure);
            switch(cf.Tag)
                case "contour_center"
                    set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_center);
                    set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_center);
                case "contour"
                    set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_radius);
                    set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_radius);
            end
        end

        function drag_center(app,handle,event)
            cp = app.MainPlotAxes.CurrentPoint;
            onc = findobj(app.MainPlotAxes,'Tag','new_contour_center');
            if ~isempty(onc)
                delete(onc)
            end
            scatter(app.MainPlotAxes,cp(1,1),cp(1,2),200,"red",'filled','Tag',"new_contour_center");
        end

        function set_new_center(app,handle,event)
            cp = app.MainPlotAxes.CurrentPoint;
            cp = cp(1,1) + cp(1,2)*1i;
            delete(findobj(app.MainPlotAxes,'Tag','new_contour_center'));
            app.contourparameters.center = cp;
            app.releaseKey(handle,event);
        end

        function drag_radius(app,handle,event)
            cp = app.MainPlotAxes.CurrentPoint;
            cp = cp(1,1) + cp(1,2)*1i;
            center = app.contourparameters.center;
            radius = sqrt((real(center) - real(cp))^2 + (imag(center) - imag(cp))^2);
            onc = findobj(app.MainPlotAxes,'Tag','new_contour');
            if ~isempty(onc)
                delete(onc)
            end
            zc = circle_trapezoid(256,center,radius);
            zc = [center + radius, zc, center + radius];
            plot(app.MainPlotAxes,real(zc),imag(zc),"red",'LineWidth',5,'Tag',"new_contour");
        end

        function set_new_radius(app,handle,event)
            cp = app.MainPlotAxes.CurrentPoint;
            cp = cp(1,1) + cp(1,2)*1i;
            center = app.contourparameters.center;
            radius = sqrt((real(center) - real(cp))^2 + (imag(center) - imag(cp))^2);
            delete(findobj(app.MainPlotAxes,'Tag','new_contour'));
            app.contourparameters.radius = radius;
            app.releaseKey(handle,event);
        end

        % compute only "dirty" data -- enables rapid system
        % realization when only interpolation data changes
        function compute(app)
            if ~app.NLEVPData.loaded
                uialert(app.UIFigure,'NLEVP not loaded.','Compute Error');
                return
            end
            if app.NumEigSearch <= 0
                uialert(app.UIFigure,sprintf("Are you sure you want to search for %d eigenvalues?",app.NumEigSearch),"Compute Error");
                return
            end
            if app.DataDirtiness > 1
                try
                    app.computeSampleData();
                    app.DataDirtiness = 1;
                catch SDE
                    uialert(app.UIFigure,'Could not re-sample quadrature.','Quad Sampling Error');
                end
            end
            if app.DataDirtiness > 0
                try
                    app.computeResultData();
                    app.DataDirtiness = 0;
                catch RDE
                    uialert(app.UIFigure,'Could not realize system.','Realization Error');
                    rethrow(RDE);
                end
            end
        end
        
        % "heavy" sampling data computation
        function computeSampleData(app)
            [app.SampleData.Ql,app.SampleData.Qr,app.SampleData.Qlr] ...
                = samplequadrature( ...
                app.NLEVPData.T, ...
                app.SampleParameters.L, ...
                app.SampleParameters.R,...
                app.QuadData.z ...
                );
        end
        
        % "light" system system identification
        function computeResultData(app)
            switch(app.ComputationalMode)
                case {"Hankel","SPLoewner"}
                    [ew,sw] = sploewner( ...
                        app.SampleData.Qlr, ...
                        app.RealizationData.sigma(1), ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.NumEigSearch, ...
                        app.NumMaxMoments, ...
                        app.tol ...
                    );
                case "MPLoewner"
                    [ew,sw] = mploewner( ...
                        app.SampleData.Ql, ...
                        app.SampleData.Qr, ...
                        app.RealizationData.theta, ...
                        app.RealizationData.sigma, ...
                        app.SampleParameters.L, ...
                        app.SampleParameters.R, ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.NumEigSearch, ...
                        app.tol ...
                    );
            end
            app.ResultData.ew = ew;
            app.ResultData.sw = sw;
        end

    end

    % GUI callbacks
    methods (Access = private)

        % prompt for a problem name and comma-separated list of arguments
        function NLEVPPackMenuSelected(app, event)
            app.NLEVPPackMenu.Enable = "off";
            app.NLEVPData.loaded=false;
            app.NLEVPReferenceData.loaded = false;
            prompt = {"problem","arglist (comma-separated list)"};
            answer = inputdlg(prompt,"NLEVP pack import");
            probstr = answer{1};
            % check first if the passed problem exists in the NLEVP pack
            try
                nlevp(probstr);
            catch PE
                uialert(app.UIFigure,'Given problem name not found in the NLEVP pack. Check spelling/NLEVP pack version and try again.','Error Setting NLEVP');
                app.PROBLEMLOADEDTextArea.BackgroundColor="r";
                app.NLEVPPackMenu.Enable="on";
                rethrow(PE)
            end
            % if the problem exists, print its help-string before anything
            % else for user reference
            nlevp_home = which('nlevp');
            nlevp_home = strrep(nlevp_home, 'nlevp.m', '');
            if ispc
                app.NLEVPHelpTextArea.Value=help(sprintf('%sprivate\\%s', nlevp_home, probstr));
            else
                app.NLEVPHelpTextArea.Value=help(sprintf('%sprivate/%s', nlevp_home, probstr));
            end
            % now deal with any NLEVP parameters
            strarglist = split(answer{2},",");
            allfinite=true;
            if (strarglist=="")
                % the problem exists, so this should run without error
                app.NLEVPData.arglist=missing;
                app.PROBLEMLOADEDTextArea.Value=sprintf("%s",probstr);
                [app.NLEVPData.coeffs,app.NLEVPData.fun,app.NLEVPData.T] = nlevp(probstr);
            else
                numarglist=num2cell(str2double(strarglist));
                % check that there isn't something like an extra comma,
                % which could incorrectly set an NLEVP parameter
                for i=1:length(numarglist)
                    if ~isfinite(numarglist{i})
                        allfinite=false;
                        warning("Passed parameter %d is not finite.", i)
                    end
                end
                if ~allfinite
                    warndlg("One or more of passed NLEVP parameters is not finite. Please ensure that the passed argument list is correct!")
                    app.PROBLEMLOADEDTextArea.BackgroundColor="y";
                end
                app.PROBLEMLOADEDTextArea.Value=sprintf("%s(%s)",probstr,strjoin(strarglist,","));
                % as far as I can tell, there is no simple way to check
                % that arglist doesn't contain MORE parameters than the
                % nlevp uses...the help string for each nlevp shows the
                % calling convention, but there is no "number" to check
                % against...
                try
                    [app.NLEVPData.coeffs,app.NLEVPData.fun,app.NLEVPData.T] = nlevp(probstr,numarglist{:});
                catch AE
                    uialert(app.UIFigure,'NLEVP exists, but passed argument list caused an error. Check NLEVP help string and try again.','Error Setting NLEVP');
                    app.PROBLEMLOADEDTextArea.BackgroundColor="r";
                    app.NLEVPPackMenu.Enable="on";
                    rethrow(AE)
                end
                app.NLEVPData.arglist = numarglist;
            end
            app.NLEVPData.name = probstr;
            if allfinite
                app.PROBLEMLOADEDTextArea.BackgroundColor="g";
            end
            app.NLEVPData.n = length(app.NLEVPData.T(0));
            app.NumEigSearch = app.NLEVPData.n;
            app.NumMaxMoments = app.NLEVPData.n;
            app.NLEVPData.loaded=true;
            notify(app,'NLEVPDataChanged');
            app.NLEVPPackMenu.Enable="on";
        end

        % change the current contour type
        function ContourTypeButtonGroupSelectionChanged(app, event)
            selectedButton = app.ContourTypeButtonGroup.SelectedObject;
            switch(selectedButton.Text)
                case "Circle"
                    app.contourparameters = CircleComponent(app.ContourTabGridLayout);
                case "Ellipse"
                    app.contourparameters = EllipseComponent(app.ContourTabGridLayout);
                case "Rectangle"
                    app.contourparameters = CircleComponent(app.ContourTabGridLayout);
            end
            app.QuadType = selectedButton.Text;
            app.contourparameters.Layout.Row = 1;
            app.contourparameters.Layout.Column = 2;
        end

        % change the current computational mode
        function ComputationalModeButtonGroupSelectionChangedFcn(app, event)
            % change editability of ShiftsTable based on what shift changes
            % make sense for the selected ComputationalMode
            switch(app.ComputationalModeButtonGroup.SelectedObject.Text)
                case "Hankel"
                    app.ShiftsTable.ColumnEditable = [false false];
                    app.NumMaxMoments = ceil(app.NumEigSearch/min(app.SampleParameters.ell,app.SampleParameters.r));
                    app.MaxMomentsEditField.Editable = "on";
                case "SPLoewner"
                    app.ShiftsTable.ColumnEditable = [false true];
                    app.NumMaxMoments = ceil(app.NumEigSearch/min(app.SampleParameters.ell,app.SampleParameters.r));
                    app.MaxMomentsEditField.Editable = "on";
                case "MPLoewner"
                    app.ShiftsTable.ColumnEditable = true;
                    app.NumMaxMoments = 0;
                    app.MaxMomentsEditField.Editable = "off";
            end
            app.ComputationalMode = app.ComputationalModeButtonGroup.SelectedObject.Text;
            app.cleanhandles(app.ResultDataPlotHandles);
            if app.NLEVPData.loaded
                app.defaultshifts();
            end
            if app.DataDirtiness == 0
                app.DataDirtiness = 1;
            end
        end

        % link ComputeButton to compute(app)
        function ComputeButtonPushed(app, event)
            app.compute();
        end
        
        % link InterpolationData with ShiftsTable.Data
        function ShiftsTableCellEdit(app, event)
            app.RealizationData.sigma = event.Source.Data.sigma;
            app.RealizationData.theta = event.Source.Data.theta;
            %app.InterpolationData = event.Source.Data;
            notify(app,'InterpolationDataChanged')
        end

        % link NumEigSearch to EigSearchEditField
        function EigSearchEditFieldValueChanged(app, event)
            app.NumEigSearch = app.EigSearchEditField.Value;
            if ~app.DataDirtiness % if DataDirtiness != 0
                app.DataDirtiness = 1;
            end
        end

        % link NumMaxMoments to MaxMomentsEditField
        function MaxMomentsEditFieldValueChanged(app, event)
            app.NumMaxMoments = event.Value;
            if ~app.DataDirtiness % if DataDirtiness != 0
                app.DataDirtiness = 1;
            end
        end

        % link NumQuadNodes to QuadNodesEditField
        function QuadNodesEditFieldValueChanged(app, event)
            app.NumQuadNodes = app.QuadNodesEditField.Value;
            app.DataDirtiness = 2;
        end

        function M = sampleNormalRandomMatrix(~,n,d)
            M = randn(n,d);
        end

        % link app.SampleParameters.ell/L to LeftProbingSizeEditField
        function LeftProbingSizeEditFieldChangedFcn(app, event)
            app.SampleParameters.ell = app.LeftProbingSizeEditField.Value;
            if app.NLEVPData.loaded
                app.SampleParameters.L = app.sampleNormalRandomMatrix(app.NLEVPData.n,app.SampleParameters.ell);
            end
            if app.ComputationalMode == "MPLoewner"
                app.updateshifts();
            end
        end

        % link app.SampleParameters.r/R to RightProbingSizeEditField
        function RightProbingSizeEditFieldChangedFcn(app, event)
            app.SampleParameters.r = app.RightProbingSizeEditField.Value;
            if app.NLEVPData.loaded
                app.SampleParameters.R = app.sampleNormalRandomMatrix(app.NLEVPData.n,app.SampleParameters.r);
            end
            if app.ComputationalMode == "MPLoewner"
                app.updateshifts();
            end
        end

        % link app.IMAX/IMIN/RMAX/RMINEditField to
        % app.MainPlotAxes.Ylim/XLim
        function MainPlotAxesWindowChangedFcn(app, event)
            OldXLim = app.MainPlotAxes.XLim;
            OldYLim = app.MainPlotAxes.YLim;
            NewXLim = [app.RMINEditField.Value; app.RMAXEditField.Value];
            NewYLim = [app.IMINEditField.Value; app.IMAXEditField.Value];
            try
                app.MainPlotAxes.XLim = NewXLim;
                app.MainPlotAxes.YLim = NewYLim;
            catch PLE
                event.Source.Value = event.PreviousValue;
                app.MainPlotAxes.XLim = OldXLim;
                app.MainPlotAxes.YLim = OldYLim;
                uialert(app.UIFigure,'Please ensure that IMIN < IMAX and RMIN < RMAX.','MainPlotAxes Error');
                %rethrow(PLE)
                return
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.AppGridLayout.RowHeight = {483, 483};
                app.AppGridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.AppGridLayout.RowHeight = {'1x'};
                app.AppGridLayout.ColumnWidth = {212, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
        end

    end

    % event listeners
    methods (Access = private)

        % listener for XLim of the MainPlot window
        function MainPlotWindowXLimChangedFcn(app, src, event)
            app.RMINEditField.Value = app.MainPlotAxes.XLim(1);
            app.RMAXEditField.Value = app.MainPlotAxes.XLim(2);
        end

        % listener for YLim of the MainPlot window
        function MainPlotWindowYLimChangedFcn(app, src, event)
            app.IMINEditField.Value = app.MainPlotAxes.YLim(1);
            app.IMAXEditField.Value = app.MainPlotAxes.YLim(2);
        end

        % listener for ContourDataChanged -- DataDirtyness=2
        function ContourDataChangedChangedFcn(app, src, event)
            [app.QuadData.z,app.QuadData.w] = app.contourparameters.getNodesWeights(app.NumQuadNodes);
            app.cleanhandles(app.ContourPlotHandles);
            app.ContourPlotHandles = app.contourparameters.plot(app.MainPlotAxes,app.QuadData.z);
            app.updateshifts();
            app.DataDirtiness = 2;
        end

        % listener for NLEVPDataChanged -- DataDirtyness=2
        function NLEVPDataChangedFcn(app, src, event)
            % update probing data
            [app.SampleParameters.ell,app.SampleParameters.r] = size(app.NLEVPData.T(0));
            app.SampleParameters.L = app.sampleNormalRandomMatrix(app.NLEVPData.n,app.SampleParameters.ell);
            app.SampleParameters.R = app.sampleNormalRandomMatrix(app.NLEVPData.n,app.SampleParameters.r);
            % update shifts
            app.defaultshifts();
            % optionally compute/display reference eigenvalues
            if app.NLEVPReferenceData.compute
                app.NLEVPReferenceData.ew = polyeig(app.NLEVPData.coeffs{:});
                app.NLEVPReferenceData.loaded = true;
            end
            if app.NLEVPReferenceData.loaded
                app.plotNLEVPeigref();
            end
            app.DataDirtiness = 2;
        end

        % listener for InterpolationDataChanged -- DataDirtyness+1
        function InterpolationDataChangedFcn(app, src, event)
            app.cleanhandles(app.InterpolationDataPlotHandles);
            app.InterpolationDataPlotHandles = {};
            if ~any(ismissing(app.RealizationData.sigma))% && all(isfinite(rmmissing(app.InterpolationData.sigma)))
                app.InterpolationDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.RealizationData.sigma),imag(app.RealizationData.sigma),"blue","square",'LineWidth',2);
            end
            if ~any(ismissing(app.RealizationData.theta))
                app.InterpolationDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.RealizationData.theta),imag(app.RealizationData.theta),"red","square",'LineWidth',2);
            end
            mil = max(length(app.RealizationData.theta),length(app.RealizationData.sigma));
            thetapadsize = mil - length(app.RealizationData.theta);
            sigmapadsize = mil - length(app.RealizationData.sigma);
            app.ShiftsTable.Data = table(padarray(app.RealizationData.theta,thetapadsize,NaN,'post'),padarray(app.RealizationData.sigma,sigmapadsize,NaN,'post'),'VariableNames',["theta","sigma"]);
            if app.DataDirtiness == 0
                app.DataDirtiness = 1;
            end
        end

        % listener for ResultDataChanged -- DataDirtyness+0
        function ResultDataChangedFcn(app, src, event)
            if ~ismissing(app.ResultData.ew)
                app.cleanhandles(app.ResultDataPlotHandles);
                app.ResultDataPlotHandles = {};
                app.ResultDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.ResultData.ew),imag(app.ResultData.ew),50,'r','LineWidth',2);
                app.EigenvaluesTable.Data = table(app.ResultData.ew,repelem(NaN,length(app.ResultData.ew)).','VariableNames',["ew","tnr"]);
            end
            if ~ismissing(app.ResultData.sw)
                app.cleanhandles(app.swPlotHandles);
                app.swPlotHandles = {};
                app.swPlotHandles{end+1} = semilogy(app.HSVAxes,1:length(app.ResultData.sw),app.ResultData.sw,"->","MarkerSize",10);
                app.HSVAxes.XLim = [0,length(app.ResultData.sw)+1];
            end
        end

        % listener for DataDirtinessChanged, updates color of ComputeButton
        function DataDirtinessChangedFcn(app, src, event)
            if app.DataDirtiness == 0
                app.ComputeButton.BackgroundColor = "g";
            elseif app.DataDirtiness == 1
                app.ComputeButton.BackgroundColor = "#EDB120";
            else
                app.ComputeButton.BackgroundColor = "r";
            end
        end

        % listener for SamplingData
        function SampleParametersChangedFcn(app, src, event)
            if isfinite(app.SampleParameters.ell)
                app.LeftProbingSizeEditField.Value = app.SampleParameters.ell;
            end
            if isfinite(app.SampleParameters.r)
                app.RightProbingSizeEditField.Value = app.SampleParameters.r;
            end
            app.DataDirtiness = 2;
        end

        % listener for NumQuadNodes
        function NumQuadNodesChangedFcn(app, src, event)
            app.QuadNodesEditField.Value = app.NumQuadNodes;
            notify(app,"ContourDataChanged");
        end

        % listener for NumEigSearch
        function NumEigSearchChangedFcn(app, src, event)
            app.EigSearchEditField.Value = app.NumEigSearch;
             if app.ComputationalMode == "MPLoewner"
                app.updateshifts();
            end
        end

        % listener for NumMaxMoments
        function NumMaxMomentsChangedFcn(app, src, event)
            app.MaxMomentsEditField.Value = app.NumMaxMoments;
        end

    end
 
    methods (Access = private)

        % clears all plot handles in the given cell-array
        % used when re-plotting a portion of data fields in app.MainPlotAxes
        function cleanhandles(app,handles)
            for i=1:length(handles)
                delete(handles{i});
            end
        end

        function plotNLEVPeigref(app)
            app.cleanhandles(app.NLEVPPlotHandles);
            app.NLEVPPlotHandles = {};
            app.NLEVPPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.NLEVPReferenceData.ew),imag(app.NLEVPReferenceData.ew),"blue","diamond",'LineWidth',2);
        end

        % simple heuristic to find a random complex number a set distance
        % outside of the circumcircle given by QuadData.z 
        function s = FindRandomShift(app)
            c = sum(app.QuadData.z)/length(app.QuadData.z);
            d = max(abs(c - app.QuadData.z))*app.RealizationData.ShiftScale;
            r = randn(1,"like",1i); r = r/norm(r);
            s = c + r*d;
        end

        % using the underlying quadrature
        % determine the geometric center and the maximum distance
        % between the center and a quadrature node.
        % then scale that distance and interleve the nodes on a 
        % circle with geo center and max_dist*scale
        function [theta,sigma] = InterlevedMPLoewnerShifts(app,m)
            % get the geometric center
            c = sum(app.QuadData.z)/length(app.QuadData.z);
            % get the maximum distance between c and quad nodes
            r = max(abs(c - app.QuadData.z));
            % nodes on a circle around the current quad nodes
            z = circle_trapezoid(4*m,c,r*app.RealizationData.ShiftScale);
            theta = double.empty();
            sigma = double.empty();
            for i=1:length(z)
                if mod(i,2) == 1
                    theta(end+1) = z(i);
                else
                    sigma(end+1) = z(i);
                end
            end
            theta = theta.';
            sigma = sigma.';
        end

        % set default QuadData for the current ComputationalMode
        % assumes that app.NLEVP.n exists, TODO
        function defaultshifts(app)
            switch(app.ComputationalMode)
                case "Hankel"
                    sigma = Inf;
                    theta = NaN;
                case "SPLoewner"
                    sigma = FindRandomShift(app);
                    theta = NaN;
                case "MPLoewner"
                    % without recomputing the existing SampleData, this is
                    % the maximum number of shifts allowed.
                    [theta,sigma] = app.InterlevedMPLoewnerShifts(app.NumEigSearch);
                    %sigma = zeros(app.NLEVPData.n,1);
                    %theta = zeros(app.NLEVPData.n,1);
                    %for i = 1:app.NLEVPData.n
                    %    sigma(i) = FindRandomShift(app);
                    %    theta(i) = FindRandomShift(app);
                    %end
                otherwise
                    uialert(app.UIFigure,'Could not set shifts.','Interpolation Data Error');
            end
            app.RealizationData.theta = theta;
            app.RealizationData.sigma = sigma;
            notify(app,'InterpolationDataChanged');
        end

        function updateshifts(app)
            app.defaultshifts();
        end

        function set_default_properties(app)
            app.DataDirtiness = 2;
            app.NLEVPData = struct('loaded',false,'T',missing);
            app.NLEVPReferenceData = struct('loaded',false,'compute',false,'ew',NaN);
            app.SampleParameters = struct('L',NaN,'ell',NaN,'R',NaN,'r',NaN);
            app.RealizationData = struct('loaded',false,'theta',NaN,'sigma',NaN,'ShiftScale',1.2);
            app.ResultData = struct('loaded',false,'ew',NaN,'ev',NaN,'sw',NaN,'sv',NaN);
            app.NumQuadNodes = 8;
            app.NumEigSearch = 0;
            app.NumMaxMoments = 0;
            % set data structs/properties
            %app.InterpolationData = table(missing, missing,'VariableNames',["theta","sigma"]);
            %app.ResultData = table(missing, missing,'VariableNames',["eigs","tnr"]);
            % plot handles
            app.NLEVPPlotHandles = {};
            app.ContourPlotHandles = {};
            app.InterpolationDataPlotHandles = {};
            app.ResultDataPlotHandles = {};
            app.swPlotHandles = {};
        end

        function set_listeners(app)
            addlistener(app,'DataDirtiness','PostSet',@app.DataDirtinessChangedFcn);
            addlistener(app,'ContourDataChanged',@app.ContourDataChangedChangedFcn);
            addlistener(app,'NLEVPDataChanged',@app.NLEVPDataChangedFcn);
            addlistener(app,'InterpolationDataChanged',@app.InterpolationDataChangedFcn);
            addlistener(app,'NumQuadNodes','PostSet',@app.NumQuadNodesChangedFcn);
            addlistener(app,'NumEigSearch','PostSet',@app.NumEigSearchChangedFcn);
            addlistener(app,'NumMaxMoments','PostSet',@app.NumMaxMomentsChangedFcn);
            addlistener(app,'SampleParameters','PostSet',@app.SampleParametersChangedFcn);
            addlistener(app,'ResultData','PostSet',@app.ResultDataChangedFcn);
            addlistener(app.MainPlotAxes,'XLim','PostSet',@(src,event)app.MainPlotWindowXLimChangedFcn);
            addlistener(app.MainPlotAxes,'YLim','PostSet',@(src,event)app.MainPlotWindowYLimChangedFcn);
        end

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off','WindowKeyPressFcn',@app.recordKey,'WindowKeyReleaseFcn',@app.releaseKey);
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 752 483];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.AppGridLayout = uigridlayout(app.UIFigure);
            app.AppGridLayout.ColumnWidth = {212, '1x'};
            app.AppGridLayout.RowHeight = {'1x'};
            app.AppGridLayout.ColumnSpacing = 0;
            app.AppGridLayout.RowSpacing = 0;
            app.AppGridLayout.Padding = [0 0 0 0];
            app.AppGridLayout.Scrollable = 'on';

            % Create RightPanel
            app.RightPanel = uipanel(app.AppGridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create TabGroup
            app.ParameterTabGroup = uitabgroup(app.RightPanelGridLayout);
            app.ParameterTabGroup.Layout.Row = 2;
            app.ParameterTabGroup.Layout.Column = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CIMTOOL

            % set default properties
            app.set_default_properties();

            % Create UIFigure and components
            app.createComponents();

            % set event listeners
            app.set_listeners();

            if nargout == 0
                clear app
            end
        end

        % Delete app
        function delete(app)
            delete(app.UIFigure)
        end

    end

end