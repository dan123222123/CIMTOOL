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
        AxisEqualCheckBox              matlab.ui.control.CheckBox
        RESETVIEWPORTButton            matlab.ui.control.Button
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
        MainPlotTab                    matlab.ui.container.Tab
        MainPlotAxes                   matlab.ui.control.UIAxes
        HSVPlotTab                     matlab.ui.container.Tab
        HSVAxes                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    properties (Access = public)
        SampleData % Ql,Qr,Qlr
        QuadType % Circle, Ellipse, Rectangle, etc.
        NLEVPData % T, name, loaded, arglist, coeff, f
        NLEVPReferenceData % eigs, ews, etc. (if set)
    end

    % observable data properties -- easier than separate events, can
    % probably switch over to make the code simpler
    properties (SetObservable,AbortSet)
        ViewPortDimensions % [xmin, xmax, ymin, ymax]
        ComputationalMode
        DataDirtiness % 0,1, or 2 to denote what needs to be recomputed
        SampleParameters % L,R,ell,r
        QuadData % z,w
        NumQuadNodes
        NumEigSearch
        NumMaxMoments
        AbsTol = missing
        RelTol
        InterpolationData % table with variables sigma and theta
        ResultData % eigs, ews, metrics, etc.
        sv % singular values of base data matrix
    end

    % Plot handles
    properties (Access = public)
        NLEVPPlotHandles
        ContourPlotHandles
        InterpolationDataPlotHandles
        ResultDataPlotHandles
        svPlotHandles
    end

    events
        ContourDataChanged
        NLEVPDataChanged
        ResultDataChanged
    end
    
    % CIM computation
    methods (Access = public)

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
                    [eigs,app.sv] = sploewner( ...
                        app.SampleData.Qlr, ...
                        app.InterpolationData.sigma(1), ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.NumEigSearch, ...
                        app.NumMaxMoments, ...
                        app.AbsTol ...
                    );
                case "MPLoewner"
                    [eigs,app.sv] = mploewner( ...
                        app.SampleData.Ql, ...
                        app.SampleData.Qr, ...
                        app.InterpolationData.theta, ...
                        app.InterpolationData.sigma, ...
                        app.SampleParameters.L, ...
                        app.SampleParameters.R, ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.NumEigSearch ...
                    );
            end
            app.ResultData = table(eigs, repelem(missing,length(eigs))','VariableNames',["eigs","tnr"]);
        end

    end

    % GUI callbacks
    methods (Access = private)

        % prompt for a problem name and comma-separated list of arguments
        function NLEVPPackMenuSelected(app, event)
            app.NLEVPPackMenu.Enable = "off";
            app.NLEVPData.loaded=false;
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
                    app.NumMaxMoments = app.NLEVPData.n;
                    app.MaxMomentsEditField.Editable = "on";
                case "SPLoewner"
                    app.ShiftsTable.ColumnEditable = [false true];
                    app.NumMaxMoments = app.NLEVPData.n;
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
            app.DataDirtiness = 2;
        end

        % link ComputeButton to compute(app)
        function ComputeButtonPushed(app, event)
            app.compute();
        end
        
        % link InterpolationData with ShiftsTable.Data
        function ShiftsTableCellEdit(app, event)
            app.InterpolationData = event.Source.Data;
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

        function M = sampleNormalRandomComplexMatrix(~,n,d)
            M = rand(n,d,"like",1i);
        end

        % link app.SampleParameters.ell/L to LeftProbingSizeEditField
        function LeftProbingSizeEditFieldChangedFcn(app, event)
            app.SampleParameters.ell = app.LeftProbingSizeEditField.Value;
            if app.NLEVPData.loaded
                app.SampleParameters.L = app.sampleNormalRandomComplexMatrix(app.NLEVPData.n,app.SampleParameters.ell);
            end
            if app.ComputationalMode == "MPLoewner"
                app.updateMPLoewnershifts();
            end
        end

        % link app.SampleParameters.r/R to RightProbingSizeEditField
        function RightProbingSizeEditFieldChangedFcn(app, event)
            app.SampleParameters.r = app.RightProbingSizeEditField.Value;
            if app.NLEVPData.loaded
                app.SampleParameters.R = app.sampleNormalRandomComplexMatrix(app.NLEVPData.n,app.SampleParameters.r);
            end
            if app.ComputationalMode == "MPLoewner"
                app.updateMPLoewnershifts();
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
            app.DataDirtiness = 2;
        end

        % listener for NLEVPDataChanged -- DataDirtyness=2
        function NLEVPDataChangedFcn(app, src, event)
            % update probing data
            [app.SampleParameters.ell,app.SampleParameters.r] = size(app.NLEVPData.T(0));
            app.SampleParameters.L = eye(app.SampleParameters.ell);
            app.SampleParameters.R = eye(app.SampleParameters.r);
            % update shifts
            app.defaultshifts();
            % optionally compute/display reference eigenvalues
            if ~app.NLEVPReferenceData.loaded && app.NLEVPReferenceData.compute
                app.NLEVPReferenceData.eigs = polyeig(app.NLEVPData.coeffs{:});
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
            if ~any(ismissing(app.InterpolationData.sigma))% && all(isfinite(rmmissing(app.InterpolationData.sigma)))
                app.InterpolationDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.InterpolationData.sigma),imag(app.InterpolationData.sigma),"blue","square",'LineWidth',2);
            end
            if ~any(ismissing(app.InterpolationData.theta))
                app.InterpolationDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.InterpolationData.theta),imag(app.InterpolationData.theta),"red","square",'LineWidth',2);
            end
            app.ShiftsTable.Data = app.InterpolationData;
            if app.DataDirtiness == 0
                app.DataDirtiness = 1;
            end
        end

        % listener for ResultDataChanged -- DataDirtyness+0
        function ResultDataChangedFcn(app, src, event)
            if ~ismissing(app.ResultData.eigs)
                app.cleanhandles(app.ResultDataPlotHandles);
                app.ResultDataPlotHandles = {};
                app.ResultDataPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.ResultData.eigs),imag(app.ResultData.eigs),50,'r','LineWidth',2);
                app.EigenvaluesTable.Data = app.ResultData;
            end
            if ~ismissing(app.sv)
                app.cleanhandles(app.svPlotHandles);
                app.svPlotHandles = {};
                app.svPlotHandles{end+1} = semilogy(app.HSVAxes,1:length(app.sv),app.sv,"->","MarkerSize",10);
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
            app.LeftProbingSizeEditField.Value = app.SampleParameters.ell;
            app.RightProbingSizeEditField.Value = app.SampleParameters.r;
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
            app.NLEVPPlotHandles{end+1} = scatter(app.MainPlotAxes,real(app.NLEVPReferenceData.eigs),imag(app.NLEVPReferenceData.eigs),"blue","diamond",'LineWidth',2);
        end

        % simple heuristic to find a random complex number a set distance
        % outside of the circumcircle given by QuadData.z 
        function s = FindRandomShift(app)
            c = sum(app.QuadData.z)/length(app.QuadData.z);
            d = max(abs(c - app.QuadData.z))*1.1;
            r = randn(1,"like",1i); r = r/norm(r);
            s = c + r*d;
        end

        % set default QuadData for the current ComputationalMode
        % assumes that app.NLEVP.n exists, TODO
        function defaultshifts(app)
            switch(app.ComputationalMode)
                case "Hankel"
                    sigma = Inf;
                    theta = missing;
                case "SPLoewner"
                    sigma = FindRandomShift(app);
                    theta = missing;
                case "MPLoewner"
                    sigma = zeros(app.NLEVPData.n,1);
                    theta = zeros(app.NLEVPData.n,1);
                    for i = 1:app.NLEVPData.n
                        sigma(i) = FindRandomShift(app);
                        theta(i) = FindRandomShift(app);
                    end
                otherwise
                    uialert(app.UIFigure,'Could not set shifts.','Interpolation Data Error');
            end
            app.InterpolationData = table(theta, sigma,'VariableNames',["theta","sigma"]);
        end

        function updateMPLoewnershifts(app)
            ellold = length(app.InterpolationData.theta);
            rold = length(app.InterpolationData.sigma);
            ellnew = app.SampleParameters.ell;
            rnew = app.SampleParameters.r;
            ellrnewmax = max(ellnew,rnew);

            % new theta and sigma, fill with missings if unavailable
            thetanew = repelem(NaN,ellrnewmax);
            sigmanew = repelem(NaN,ellrnewmax);

            % fill with old shifts to preserve past user input and fill
            % with new random shifts where necessary
            for i=1:min(ellold,ellnew)
                thetanew(i) = app.InterpolationData.theta(i);
            end
            for j = ellold:ellnew
                thetanew(j) = app.FindRandomShift();
            end
            for i=1:min(rold,rnew)
                sigmanew(i) = app.InterpolationData.sigma(i);
            end
            for j = rold:rnew
                sigmanew(j) = app.FindRandomShift();
            end

            app.InterpolationData = table(thetanew', sigmanew','VariableNames',["theta","sigma"]);

        end

        function setdefaults(app)
            app.DataDirtiness = 2;
            addlistener(app,'DataDirtiness','PostSet',@app.DataDirtinessChangedFcn);
            app.NumQuadNodes = 8;
            app.NumEigSearch = 0;
            app.NumMaxMoments = 0;
            % default observable properties
            app.SampleParameters.L = 0;
            app.SampleParameters.R = 0;
            app.SampleParameters.ell = 0;
            app.SampleParameters.r = 0;
            % NLEVPData
            app.NLEVPData.loaded = false;
            % NLEVPReferenceData
            app.NLEVPReferenceData.loaded = false;
            app.NLEVPReferenceData.compute = true;
            % listeners
            addlistener(app,'ContourDataChanged',@app.ContourDataChangedChangedFcn);
            %addlistener(app,'QuadData','PostSet',@app.QuadDataChangedFcn);
            addlistener(app,'NLEVPDataChanged',@app.NLEVPDataChangedFcn);
            addlistener(app,'InterpolationData','PostSet',@app.InterpolationDataChangedFcn);
            app.ResultData.loaded = false;
            addlistener(app,'NumQuadNodes','PostSet',@app.NumQuadNodesChangedFcn);
            addlistener(app,'NumEigSearch','PostSet',@app.NumEigSearchChangedFcn);
            addlistener(app,'NumMaxMoments','PostSet',@app.NumMaxMomentsChangedFcn);
            addlistener(app,'SampleParameters','PostSet',@app.SampleParametersChangedFcn);
            addlistener(app,'ResultData','PostSet',@app.ResultDataChangedFcn);
            addlistener(app.MainPlotAxes,'XLim','PostSet',@(src,event)app.MainPlotWindowXLimChangedFcn);
            addlistener(app.MainPlotAxes,'YLim','PostSet',@(src,event)app.MainPlotWindowYLimChangedFcn);
            % set data structs/properties
            app.InterpolationData = table(missing, missing,'VariableNames',["theta","sigma"]);
            app.ResultData = table(missing, missing,'VariableNames',["eigs","tnr"]);
            % plot handles
            app.NLEVPPlotHandles = {};
            app.ContourPlotHandles = {};
            app.InterpolationDataPlotHandles = {};
            app.ResultDataPlotHandles = {};
            app.svPlotHandles = {};
        end

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 752 483];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create ImportNLEVPMenu
            app.ImportNLEVPMenu = uimenu(app.FileMenu);
            app.ImportNLEVPMenu.Text = 'Import NLEVP';

            % Create WorkspaceMenu
            app.WorkspaceMenu = uimenu(app.ImportNLEVPMenu);
            app.WorkspaceMenu.Enable = 'off';
            app.WorkspaceMenu.Text = 'Workspace';

            % Create ImportNLEVPFile
            app.ImportNLEVPFileMenu = uimenu(app.ImportNLEVPMenu);
            app.ImportNLEVPFileMenu.Enable = 'off';
            app.ImportNLEVPFileMenu.Text = 'File';

            % Create NLEVPPackMenu
            app.NLEVPPackMenu = uimenu(app.ImportNLEVPMenu);
            app.NLEVPPackMenu.MenuSelectedFcn = createCallbackFcn(app, @NLEVPPackMenuSelected, true);
            app.NLEVPPackMenu.Text = 'NLEVP Pack';

            % Create ExportMenu
            app.ExportMenu = uimenu(app.FileMenu);
            app.ExportMenu.Text = 'Export...';
            app.ExportMenu.Enable = "off";

            % Create EigenvaluesMenu
            app.EigenvaluesMenu = uimenu(app.ExportMenu);
            app.EigenvaluesMenu.Text = 'Eigenvalues';

            % Create MomentsMenu
            app.MomentsMenu = uimenu(app.ExportMenu);
            app.MomentsMenu.Text = 'Moments';

            % Create FigureMenu
            app.FigureMenu = uimenu(app.ExportMenu);
            app.FigureMenu.Text = 'Figure';

            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.UIFigure);
            app.PreferencesMenu.Text = 'Preferences';
            app.PreferencesMenu.Enable = 'off';

            % Create ShiftPatternMenu
            app.ShiftPatternMenu = uimenu(app.PreferencesMenu);
            app.ShiftPatternMenu.Text = 'Shift Pattern';

            % Create equispacedMenu
            app.equispacedMenu = uimenu(app.ShiftPatternMenu);
            app.equispacedMenu.Enable = 'off';
            app.equispacedMenu.Text = 'equispaced';

            % Create randomMenu
            app.randomMenu = uimenu(app.ShiftPatternMenu);
            app.randomMenu.Enable = 'off';
            app.randomMenu.Text = 'random';

            % Create PlottingAttributesMenu
            app.PlottingAttributesMenu = uimenu(app.PreferencesMenu);
            app.PlottingAttributesMenu.Enable = 'off';
            app.PlottingAttributesMenu.Text = 'Plotting Attributes';

            % Create ComputationMenu
            app.ComputationMenu = uimenu(app.PreferencesMenu);
            app.ComputationMenu.Enable = 'off';
            app.ComputationMenu.Text = 'Computation';

            % Create GridLayout
            app.AppGridLayout = uigridlayout(app.UIFigure);
            app.AppGridLayout.ColumnWidth = {212, '1x'};
            app.AppGridLayout.RowHeight = {'1x'};
            app.AppGridLayout.ColumnSpacing = 0;
            app.AppGridLayout.RowSpacing = 0;
            app.AppGridLayout.Padding = [0 0 0 0];
            app.AppGridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.AppGridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create ComputationalModeButtonGroup
            app.ComputationalModeButtonGroup = uibuttongroup(app.LeftPanel);
            app.ComputationalModeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ComputationalModeButtonGroupSelectionChangedFcn, true);
            app.ComputationalModeButtonGroup.TitlePosition = 'centertop';
            app.ComputationalModeButtonGroup.Title = 'Computational Mode';
            app.ComputationalModeButtonGroup.Position = [17 233 183 122];

            % Create HankelButton
            app.HankelButton = uitogglebutton(app.ComputationalModeButtonGroup);
            app.HankelButton.Text = 'Hankel';
            app.HankelButton.Position = [10 67 163 23];
            app.HankelButton.Value = true;

            % Create SPLoewnerButton
            app.SPLoewnerButton = uitogglebutton(app.ComputationalModeButtonGroup);
            app.SPLoewnerButton.Text = 'SPLoewner';
            app.SPLoewnerButton.Position = [11 38 162 23];

            % Create MPLoewnerButton
            app.MPLoewnerButton = uitogglebutton(app.ComputationalModeButtonGroup);
            app.MPLoewnerButton.Text = 'MPLoewner';
            app.MPLoewnerButton.Position = [11 11 162 23];

            % Default Computational Mode
            app.ComputationalMode = app.ComputationalModeButtonGroup.SelectedObject.Text;

            % Create ComputeButton
            app.ComputeButton = uibutton(app.LeftPanel, 'push');
            app.ComputeButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeButtonPushed, true);
            app.ComputeButton.WordWrap = 'on';
            app.ComputeButton.Position = [49 184 115 32];
            app.ComputeButton.Text = 'COMPUTE';

            % Create RESETVIEWPORTButton
            app.RESETVIEWPORTButton = uibutton(app.LeftPanel, 'push');
            app.RESETVIEWPORTButton.WordWrap = 'on';
            app.RESETVIEWPORTButton.Position = [49 147 115 38];
            app.RESETVIEWPORTButton.Text = 'RESET VIEWPORT';
            app.RESETVIEWPORTButton.Enable = "off";

            % Create AxisEqualCheckBox
            app.AxisEqualCheckBox = uicheckbox(app.LeftPanel);
            app.AxisEqualCheckBox.Text = 'Axis Equal';
            app.AxisEqualCheckBox.Position = [67 19 79 22];
            app.AxisEqualCheckBox.Enable = "off";

            % Create PROBLEMLOADEDTextAreaLabel
            app.PROBLEMLOADEDTextAreaLabel = uilabel(app.LeftPanel);
            app.PROBLEMLOADEDTextAreaLabel.HorizontalAlignment = 'center';
            app.PROBLEMLOADEDTextAreaLabel.WordWrap = 'on';
            app.PROBLEMLOADEDTextAreaLabel.Position = [17 444 70 29];
            app.PROBLEMLOADEDTextAreaLabel.Text = 'PROBLEM LOADED';

            % Create PROBLEMLOADEDTextArea
            app.PROBLEMLOADEDTextArea = uitextarea(app.LeftPanel);
            app.PROBLEMLOADEDTextArea.Editable = 'off';
            app.PROBLEMLOADEDTextArea.HorizontalAlignment = 'center';
            app.PROBLEMLOADEDTextArea.WordWrap = 'off';
            app.PROBLEMLOADEDTextArea.FontName = 'Hack';
            app.PROBLEMLOADEDTextArea.Placeholder = 'None';
            app.PROBLEMLOADEDTextArea.Position = [87 444 108 29];

            % Create IMAXEditFieldLabel
            app.IMAXEditFieldLabel = uilabel(app.LeftPanel);
            app.IMAXEditFieldLabel.HorizontalAlignment = 'center';
            app.IMAXEditFieldLabel.Position = [90 122 34 22];
            app.IMAXEditFieldLabel.Text = 'IMAX';

            % Create IMAXEditField
            app.IMAXEditField = uieditfield(app.LeftPanel, 'numeric');
            app.IMAXEditField.HorizontalAlignment = 'center';
            app.IMAXEditField.ValueChangedFcn = createCallbackFcn(app, @MainPlotAxesWindowChangedFcn, true);
            app.IMAXEditField.Placeholder = '1';
            app.IMAXEditField.Value = 1;
            app.IMAXEditField.Position = [88 101 36 22];
            %app.IMAXEditField.Enable = "off";

            % Create RMINEditFieldLabel
            app.RMINEditFieldLabel = uilabel(app.LeftPanel);
            app.RMINEditFieldLabel.HorizontalAlignment = 'right';
            app.RMINEditFieldLabel.Position = [12 80 36 22];
            app.RMINEditFieldLabel.Text = 'RMIN';

            % Create RMINEditField
            app.RMINEditField = uieditfield(app.LeftPanel, 'numeric');
            app.RMINEditField.HorizontalAlignment = 'center';
            app.RMINEditField.ValueChangedFcn = createCallbackFcn(app, @MainPlotAxesWindowChangedFcn, true);
            app.RMINEditField.Placeholder = '1';
            app.RMINEditField.Value = -1;
            app.RMINEditField.Position = [48 80 31 22];
            %app.RMINEditField.Enable = "off";

            % Create RMAXEditFieldLabel
            app.RMAXEditFieldLabel = uilabel(app.LeftPanel);
            app.RMAXEditFieldLabel.HorizontalAlignment = 'right';
            app.RMAXEditFieldLabel.Position = [162 80 40 22];
            app.RMAXEditFieldLabel.Text = 'RMAX';

            % Create RMAXEditField
            app.RMAXEditField = uieditfield(app.LeftPanel, 'numeric');
            app.RMAXEditField.HorizontalAlignment = 'center';
            app.RMAXEditField.ValueChangedFcn = createCallbackFcn(app, @MainPlotAxesWindowChangedFcn, true);
            app.RMAXEditField.Placeholder = '1';
            app.RMAXEditField.Value = 1;
            app.RMAXEditField.Position = [132 80 31 22];
            %app.RMAXEditField.Enable = "off";

            % Create IMINEditFieldLabel
            app.IMINEditFieldLabel = uilabel(app.LeftPanel);
            app.IMINEditFieldLabel.HorizontalAlignment = 'center';
            app.IMINEditFieldLabel.Position = [92 40 30 22];
            app.IMINEditFieldLabel.Text = 'IMIN';

            % Create IMINEditField
            app.IMINEditField = uieditfield(app.LeftPanel, 'numeric');
            app.IMINEditField.HorizontalAlignment = 'center';
            app.IMINEditField.ValueChangedFcn = createCallbackFcn(app, @MainPlotAxesWindowChangedFcn, true);
            app.IMINEditField.Value = -1;
            app.IMINEditField.Position = [88 61 36 22];

            % Create QuadNodesEditFieldLabel
            app.QuadNodesEditFieldLabel = uilabel(app.LeftPanel);
            app.QuadNodesEditFieldLabel.HorizontalAlignment = 'center';
            app.QuadNodesEditFieldLabel.WordWrap = 'on';
            app.QuadNodesEditFieldLabel.Position = [19 368 68 30];
            app.QuadNodesEditFieldLabel.Text = '# Quad Nodes';

            % Create QuadNodesEditField
            app.QuadNodesEditField = uieditfield(app.LeftPanel, 'numeric');
            app.QuadNodesEditField.Limits = [0 Inf];
            app.QuadNodesEditField.ValueDisplayFormat = '%.0f';
            app.QuadNodesEditField.HorizontalAlignment = 'center';
            app.QuadNodesEditField.Position = [86 368 109 30];
            app.QuadNodesEditField.ValueChangedFcn = createCallbackFcn(app, @QuadNodesEditFieldValueChanged, true);
            app.QuadNodesEditField.Value = 8;
            app.NumQuadNodes = app.QuadNodesEditField.Value;

            % Create RightPanel
            app.RightPanel = uipanel(app.AppGridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create GridLayout2
            app.RightPanelGridLayout = uigridlayout(app.RightPanel);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'1.83x', '1x'};
            app.RightPanelGridLayout.RowSpacing = 7.33333333333333;
            app.RightPanelGridLayout.Padding = [6 7.33333333333333 6 7.33333333333333];

            % Create PlotTabGroup
            app.PlotTabGroup = uitabgroup(app.RightPanelGridLayout);
            app.PlotTabGroup.Layout.Row = 1;
            app.PlotTabGroup.Layout.Column = 1;

            % Create MainPlotTab
            app.MainPlotTab = uitab(app.PlotTabGroup);
            app.MainPlotTab.Title = 'Main';

            % Create MainPlotAxes
            app.MainPlotAxes = uiaxes(app.MainPlotTab);
            app.MainPlotAxes.Layer = 'top';
            app.MainPlotAxes.XGrid = 'on';
            app.MainPlotAxes.XMinorGrid = 'on';
            app.MainPlotAxes.YGrid = 'on';
            app.MainPlotAxes.YMinorGrid = 'on';
            app.MainPlotAxes.ZMinorGrid = 'on';
            hold(app.MainPlotAxes,"on");

            % Create HSVPlotTab
            app.HSVPlotTab = uitab(app.PlotTabGroup);
            app.HSVPlotTab.Title = 'HSV(s)';

            % Create HSVAxes
            app.HSVAxes = uiaxes(app.HSVPlotTab);
            app.HSVAxes.Layer = 'top';
            app.HSVAxes.XGrid = 'on';
            app.HSVAxes.XMinorGrid = 'off';
            app.HSVAxes.YGrid = 'on';
            app.HSVAxes.YMinorGrid = 'on';
            app.HSVAxes.ZMinorGrid = 'off';

            % Create TabGroup
            app.ParameterTabGroup = uitabgroup(app.RightPanelGridLayout);
            app.ParameterTabGroup.Layout.Row = 2;
            app.ParameterTabGroup.Layout.Column = 1;

            % Create NLEVPInformationTab
            app.NLEVPInformationTab = uitab(app.ParameterTabGroup);
            app.NLEVPInformationTab.Title = 'NLEVP Information';

            % Create NLEVPHelpTextArea
            app.NLEVPHelpTextArea = uitextarea(app.NLEVPInformationTab);
            app.NLEVPHelpTextArea.Editable = 'off';
            app.NLEVPHelpTextArea.HorizontalAlignment = 'center';
            app.NLEVPHelpTextArea.BackgroundColor = [0.8 0.8 0.8];
            app.NLEVPHelpTextArea.Position = [15 13 501 117];
            app.NLEVPHelpTextArea.Value = {'No NLEVP Loaded.'};

            % Create MethodTab
            app.MethodTab = uitab(app.ParameterTabGroup);
            app.MethodTab.Title = 'Method';

            % Create MethodLayout
            app.MethodTabGridLayout = uigridlayout(app.MethodTab);
            app.MethodTabGridLayout.ColumnWidth = {'1x', '2x'};
            app.MethodTabGridLayout.RowHeight = {'1x'};

            % Create ProbingLayout
            app.ProbingGridLayout = uigridlayout(app.MethodTabGridLayout);
            app.ProbingGridLayout.Layout.Row = 1;
            app.ProbingGridLayout.Layout.Column = 2;

            % Create LeftProbingSizeEditFieldLabel
            app.LeftProbingSizeEditFieldLabel = uilabel(app.ProbingGridLayout);
            app.LeftProbingSizeEditFieldLabel.HorizontalAlignment = 'center';
            app.LeftProbingSizeEditFieldLabel.WordWrap = 'on';
            app.LeftProbingSizeEditFieldLabel.Layout.Row = 1;
            app.LeftProbingSizeEditFieldLabel.Layout.Column = 1;
            app.LeftProbingSizeEditFieldLabel.Text = 'Left Probing Size';

            % Create LeftProbingSizeEditField
            app.LeftProbingSizeEditField = uieditfield(app.ProbingGridLayout, 'numeric');
            app.LeftProbingSizeEditField.Limits = [0 Inf];
            app.LeftProbingSizeEditField.HorizontalAlignment = 'center';
            app.LeftProbingSizeEditField.ValueChangedFcn = createCallbackFcn(app, @LeftProbingSizeEditFieldChangedFcn, true);
            app.LeftProbingSizeEditField.Layout.Row = 2;
            app.LeftProbingSizeEditField.Layout.Column = 1;

            % Create RightProbingSizeEditFieldLabel
            app.RightProbingSizeEditFieldLabel = uilabel(app.ProbingGridLayout);
            app.RightProbingSizeEditFieldLabel.HorizontalAlignment = 'center';
            app.RightProbingSizeEditFieldLabel.WordWrap = 'on';
            app.RightProbingSizeEditFieldLabel.Layout.Row = 1;
            app.RightProbingSizeEditFieldLabel.Layout.Column = 2;
            app.RightProbingSizeEditFieldLabel.Text = 'Right Probing Size';

            % Create RightProbingSizeEditField
            app.RightProbingSizeEditField = uieditfield(app.ProbingGridLayout, 'numeric');
            app.RightProbingSizeEditField.Limits = [0 Inf];
            app.RightProbingSizeEditField.HorizontalAlignment = 'center';
            app.RightProbingSizeEditField.ValueChangedFcn = createCallbackFcn(app, @RightProbingSizeEditFieldChangedFcn, true);
            app.RightProbingSizeEditField.Layout.Row = 2;
            app.RightProbingSizeEditField.Layout.Column = 2;

            % Create MethodDataParameterLayout
            app.MethodDataParameterGridLayout = uigridlayout(app.MethodTabGridLayout);
            app.MethodDataParameterGridLayout.ColumnWidth = {'1x'};
            app.MethodDataParameterGridLayout.RowHeight = {'1x', '1x', '1x', '1x'};
            app.MethodDataParameterGridLayout.Layout.Row = 1;
            app.MethodDataParameterGridLayout.Layout.Column = 1;

            % Create EigSearchEditFieldLabel
            app.EigSearchEditFieldLabel = uilabel(app.MethodDataParameterGridLayout);
            app.EigSearchEditFieldLabel.HorizontalAlignment = 'center';
            app.EigSearchEditFieldLabel.WordWrap = 'on';
            app.EigSearchEditFieldLabel.Layout.Row = 1;
            app.EigSearchEditFieldLabel.Layout.Column = 1;
            app.EigSearchEditFieldLabel.Text = '# Eig Search';

            % Create EigSearchEditField
            app.EigSearchEditField = uieditfield(app.MethodDataParameterGridLayout, 'numeric');
            app.EigSearchEditField.Limits = [0 Inf];
            app.EigSearchEditField.HorizontalAlignment = 'center';
            app.EigSearchEditField.ValueChangedFcn = createCallbackFcn(app, @EigSearchEditFieldValueChanged, true);
            app.EigSearchEditField.Value = 0;
            app.EigSearchEditField.Layout.Row = 2;
            app.EigSearchEditField.Layout.Column = 1;

            % Create MaxMomentsEditFieldLabel
            app.MaxMomentsEditFieldLabel = uilabel(app.MethodDataParameterGridLayout);
            app.MaxMomentsEditFieldLabel.HorizontalAlignment = 'center';
            app.MaxMomentsEditFieldLabel.WordWrap = 'on';
            app.MaxMomentsEditFieldLabel.Layout.Row = 3;
            app.MaxMomentsEditFieldLabel.Layout.Column = 1;
            app.MaxMomentsEditFieldLabel.Text = 'Max # Moments';

            % Create MaxMomentsEditField
            app.MaxMomentsEditField = uieditfield(app.MethodDataParameterGridLayout, 'numeric');
            app.MaxMomentsEditField.Limits = [0 Inf];
            app.MaxMomentsEditField.HorizontalAlignment = 'center';
            app.MaxMomentsEditField.ValueChangedFcn = createCallbackFcn(app, @MaxMomentsEditFieldValueChanged, true);
            app.MaxMomentsEditField.Layout.Row = 4;
            app.MaxMomentsEditField.Layout.Column = 1;

            % Create ContourTab
            app.ContourTab = uitab(app.ParameterTabGroup);
            app.ContourTab.Title = 'Contour';

            % Create ContourParameterLayout
            app.ContourTabGridLayout = uigridlayout(app.ContourTab);
            app.ContourTabGridLayout.ColumnWidth = {100, '1x'};
            app.ContourTabGridLayout.RowHeight = {114};

            % Create ContourTypeButtonGroup
            app.ContourTypeButtonGroup = uibuttongroup(app.ContourTabGridLayout);
            app.ContourTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ContourTypeButtonGroupSelectionChanged, true);
            app.ContourTypeButtonGroup.TitlePosition = 'centertop';
            app.ContourTypeButtonGroup.Title = 'Type';
            app.ContourTypeButtonGroup.Layout.Row = 1;
            app.ContourTypeButtonGroup.Layout.Column = 1;

            % Create CircleButton
            app.CircleButton = uiradiobutton(app.ContourTypeButtonGroup);
            app.CircleButton.Text = 'Circle';
            app.CircleButton.Position = [11 68 58 22];
            app.CircleButton.Value = true;

            % Create EllipseButton
            app.EllipseButton = uiradiobutton(app.ContourTypeButtonGroup);
            app.EllipseButton.Enable = 'off';
            app.EllipseButton.Text = 'Ellipse';
            app.EllipseButton.Position = [11 46 65 22];

            % Create RectangleButton
            app.RectangleButton = uiradiobutton(app.ContourTypeButtonGroup);
            app.RectangleButton.Enable = 'off';
            app.RectangleButton.Text = 'Rectangle';
            app.RectangleButton.Position = [11 24 76 22];

            % Create contourparameters
            app.contourparameters = CircleComponent(app.ContourTabGridLayout,'MainApp',app);
            app.contourparameters.Layout.Row = 1;
            app.contourparameters.Layout.Column = 2;

            %% ShiftsTab
            app.ShiftsTab = uitab(app.ParameterTabGroup);
            app.ShiftsTab.Title = 'Shift(s)';

            % Shift(s) tab gridlayout
            app.ShiftsTabGridLayout = uigridlayout(app.ShiftsTab);
            app.ShiftsTabGridLayout.ColumnWidth = {'1x'};
            app.ShiftsTabGridLayout.RowHeight = { '1x'};
            app.ShiftsTabGridLayout.Padding = [10 10 10 10];

            % table of shifts
            app.ShiftsTable = uitable(app.ShiftsTabGridLayout);
            app.ShiftsTable.ColumnName = {'theta','sigma'};
            app.ShiftsTable.RowName = {};
            app.ShiftsTable.CellEditCallback = createCallbackFcn(app, @ShiftsTableCellEdit, true);
            app.ShiftsTable.Layout.Row = 1;
            app.ShiftsTable.Layout.Column = 1;
            app.ShiftsTable.Data = app.InterpolationData;

            %% EigenvaluesTab
            app.EigenvaluesTab = uitab(app.ParameterTabGroup);
            app.EigenvaluesTab.Title = 'Eigenvalue Information';

            % EigenvalueInformationGridLayout
            app.EigenvaluesTabGridLayout = uigridlayout(app.EigenvaluesTab);
            app.EigenvaluesTabGridLayout.ColumnWidth = {'1x'};
            app.EigenvaluesTabGridLayout.RowHeight = { '1x'};
            app.EigenvaluesTabGridLayout.Padding = [10 10 10 10];

            % EigenvalueInformationTable
            app.EigenvaluesTable = uitable(app.EigenvaluesTabGridLayout);
            app.EigenvaluesTable.ColumnName = {'eigs','tnr'};
            app.EigenvaluesTable.RowName = {};
            app.EigenvaluesTable.CellEditCallback = createCallbackFcn(app, @EigenvaluesTableCellEdit, true);
            app.EigenvaluesTable.Layout.Row = 1;
            app.EigenvaluesTable.Layout.Column = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CIMTOOL

            % Create UIFigure and components
            app.createComponents();

            % set default properties, event listeners, etc.
            app.setdefaults();

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