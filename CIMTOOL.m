classdef CIMTOOL < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        FileMenu                      matlab.ui.container.Menu
        ImportNLEVPMenu               matlab.ui.container.Menu
        WorkspaceMenu                 matlab.ui.container.Menu
        FileMenu_2                    matlab.ui.container.Menu
        NLEVPPackMenu                 matlab.ui.container.Menu
        ExportMenu                    matlab.ui.container.Menu
        EigenvaluesMenu               matlab.ui.container.Menu
        MomentsMenu                   matlab.ui.container.Menu
        FigureMenu                    matlab.ui.container.Menu
        PreferencesMenu               matlab.ui.container.Menu
        ShiftPatternMenu              matlab.ui.container.Menu
        equispacedMenu                matlab.ui.container.Menu
        randomMenu                    matlab.ui.container.Menu
        PlottingAttributesMenu        matlab.ui.container.Menu
        ComputationMenu               matlab.ui.container.Menu
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        QuadNodesEditField            matlab.ui.control.NumericEditField
        QuadNodesEditFieldLabel       matlab.ui.control.Label
        EigSearchEditField            matlab.ui.control.NumericEditField
        EigSearchEditFieldLabel       matlab.ui.control.Label
        IMINEditField                 matlab.ui.control.NumericEditField
        IMINEditFieldLabel            matlab.ui.control.Label
        RMAXEditField                 matlab.ui.control.NumericEditField
        RMAXEditFieldLabel            matlab.ui.control.Label
        RMINEditField                 matlab.ui.control.NumericEditField
        RMINEditFieldLabel            matlab.ui.control.Label
        IMAXEditField                 matlab.ui.control.NumericEditField
        IMAXEditFieldLabel            matlab.ui.control.Label
        PROBLEMLOADEDTextArea         matlab.ui.control.TextArea
        PROBLEMLOADEDTextAreaLabel    matlab.ui.control.Label
        ShiftsButton                  matlab.ui.control.Button
        AxisEqualCheckBox             matlab.ui.control.CheckBox
        RESETVIEWPORTButton           matlab.ui.control.Button
        COMPUTEButton                 matlab.ui.control.Button
        ComputationalModeButtonGroup  matlab.ui.container.ButtonGroup
        MPLoewnerButton               matlab.ui.control.ToggleButton
        SPLoewnerButton               matlab.ui.control.ToggleButton
        HankelButton                  matlab.ui.control.ToggleButton
        RightPanel                    matlab.ui.container.Panel
        GridLayout2                   matlab.ui.container.GridLayout
        TabGroup                      matlab.ui.container.TabGroup
        NLEVPInformationTab           matlab.ui.container.Tab
        TextArea_3                    matlab.ui.control.TextArea
        ContourTab                    matlab.ui.container.Tab
        GridLayout3                   matlab.ui.container.GridLayout
        contourparameters             ContourComponentInterface
        TypeButtonGroup               matlab.ui.container.ButtonGroup
        RectangleButton               matlab.ui.control.RadioButton
        EllipseButton                 matlab.ui.control.RadioButton
        CircleButton                  matlab.ui.control.RadioButton
        ShiftsTab                     matlab.ui.container.Tab
        EigenvalueInformationTab      matlab.ui.container.Tab
        TextArea                      matlab.ui.control.TextArea
        ErrorsWarningsTab             matlab.ui.container.Tab
        TextArea_2                    matlab.ui.control.TextArea
        UIAxes                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end
    
    properties (Access = public)
        QuadType % Circle, Ellipse, or Custom
        ComputationalMode % Hankel, SPLoewner, MPLoewner
        ViewPortDimensions % [xmin, xmax, ymin, ymax]
        NLEVP % structure array that contains NLEVP fields
        ProbingData % L,R,ell,r
        N % number of quadrature nodes
        m % number of quadrature nodes, specified by the user (for now)
        QuadData % z,w the quadrature nodes and weights
        SampleData % Ql,Qr,Qlr
        InterpolationData % mode, lshifts, rshifts 
        ResultData % eigs, ews, metrics, etc.
    end
    
    methods (Access = public)

        % assumed that we must recompute some/all (for now all) data
        % this method should be called after certain property updates.
        function computeData(app)
            [app.SampleData.Ql,app.SampleData.Qr,app.SampleData.Qlr] ...
                = samplequadrature( ...
                app.NLEVP.T, ...
                app.ProbingData.L, ...
                app.ProbingData.R,...
                app.QuadData.z ...
                );
            computeMethod(app);
        end
        
        % assumed that the data stays fixed, and we simply use it in the
        % method specified by app.ComputationalMode 
        function computeMethod(app)
            switch(app.InterpolationData.mode)
                case "Hankel"
                    [app.ResultData.eigs] = sploewner( ...
                        app.SampleData.Qlr, ...
                        app.InterpolationData.sigma(1), ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.m, ...
                        ceil(app.m/min(ell,r)) ...
                    );
                case "SPLoewner"
                    [app.ResultData.eigs] = sploewner( ...
                        app.SampleData.Qlr, ...
                        Inf, ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.m, ...
                        ceil(app.m/min(ell,r)) ...
                    );
                case "MPLoewner"
                    [app.ResultData.eigs] = mploewner( ...
                        app.SampleData.Ql, ...
                        app.SampleData.Qr, ...
                        app.InterpolationData.theta, ...
                        app.InterpolationData.sigma, ...
                        app.ProbingData.L, ...
                        app.ProbingData.R, ...
                        app.QuadData.z, ...
                        app.QuadData.w, ...
                        app.m ...
                    );
                otherwise
                    errordlg("no computational method selected")
            end
            
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: NLEVPPackMenu
        function NLEVPPackMenuSelected(app, event)
            % prompt the user for a problem name and comma-separated list
            % of arguments
            app.NLEVPPackMenu.Enable = "off";
            prompt = {"problem","arglist (comma-separated list)"};
            answer = inputdlg(prompt,"NLEVP pack import");
            probstr = answer{1};
            % check first if the passed problem exists in the NLEVP pack
            try
                nlevp(probstr);
            catch PE
                errordlg('Given problem name not found in the NLEVP pack. Check spelling/NLEVP pack version and try again.')
                app.PROBLEMLOADEDTextArea.BackgroundColor="r";
                app.NLEVPPackMenu.Enable="on";
                rethrow(PE)
            end
            % if the problem exists, print its help-string before anything
            % else for user reference
            nlevp_home = which('nlevp');
            nlevp_home = strrep(nlevp_home, 'nlevp.m', '');
            if ispc
                app.TextArea_3.Value=help(sprintf('%sprivate\\%s', nlevp_home, probstr));
            else
                app.TextArea_3.Value=help(sprintf('%sprivate/%s', nlevp_home, probstr));
            end
            % now deal with any NLEVP parameters
            strarglist = split(answer{2},",");
            allfinite=true;
            if (strarglist=="")
                % the problem exists, so this should run without error
                app.NLEVP.arglist=missing;
                app.PROBLEMLOADEDTextArea.Value=sprintf("%s",probstr);
                [app.NLEVP.coeffs,app.NLEVP.T,app.NLEVP.f] = nlevp(probstr);
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
                    [app.NLEVP.coeffs,app.NLEVP.T,app.NLEVP.f] = nlevp(probstr,numarglist{:});
                catch AE
                    errordlg('NLEVP exists, but passed argument list caused an error. Check NLEVP help string and try again.')
                    app.PROBLEMLOADEDTextArea.BackgroundColor="r";
                    app.NLEVPPackMenu.Enable="on";
                    rethrow(AE)
                end
                app.NLEVP.arglist = numarglist;
            end
            app.NLEVP.name = probstr;
            if allfinite
                app.PROBLEMLOADEDTextArea.BackgroundColor="g";
            end
            app.NLEVPPackMenu.Enable="on";
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
        end

        % Button pushed function: COMPUTEButton
        function COMPUTEButtonPushed(app, event)
            computeData(app);
        end

        % Selection changed function: TypeButtonGroup
        function TypeButtonGroupSelectionChanged(app, event)
            selectedButton = app.TypeButtonGroup.SelectedObject;
            switch(selectedButton.Text)
                case "Circle"
                    app.contourparameters = CircleComponent(app.GridLayout3);
                case "Ellipse"
                    app.contourparameters = EllipseComponent(app.GridLayout3);
                case "Rectangle"
                    app.contourparameters = CircleComponent(app.GridLayout3);
                otherwise
                    errordlg("no contour selected")
            end
            app.contourparameters.Layout.Row = 1;
            app.contourparameters.Layout.Column = 2;
        end

        % Selection changed function: ComputationalModeButtonGroup
        function ComputationalModeChanged(app, event)
            app.ComputationalMode = app.ComputationalModeButtonGroup.SelectedObject.Text;
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {483, 483};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {212, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Value changed function: m
        function mEditFieldValueChanged(app, event)
            try
                app.m = str2double(app.EigSearchEditField.Value);
            catch
                update(app);
                errordlg("Invalid m value.")
            end
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

            % Create FileMenu_2
            app.FileMenu_2 = uimenu(app.ImportNLEVPMenu);
            app.FileMenu_2.Enable = 'off';
            app.FileMenu_2.Text = 'File';

            % Create NLEVPPackMenu
            app.NLEVPPackMenu = uimenu(app.ImportNLEVPMenu);
            app.NLEVPPackMenu.MenuSelectedFcn = createCallbackFcn(app, @NLEVPPackMenuSelected, true);
            app.NLEVPPackMenu.Text = 'NLEVP Pack';

            % Create ExportMenu
            app.ExportMenu = uimenu(app.FileMenu);
            app.ExportMenu.Text = 'Export...';

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
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {212, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create COMPUTATIONALMODEButtonGroup
            app.ComputationalModeButtonGroup = uibuttongroup(app.LeftPanel);
            app.ComputationalModeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ComputationalModeChanged, true);
            app.ComputationalModeButtonGroup.TitlePosition = 'centertop';
            app.ComputationalModeButtonGroup.Title = 'COMPUTATIONAL MODE';
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

            % Create COMPUTEButton
            app.COMPUTEButton = uibutton(app.LeftPanel, 'push');
            app.COMPUTEButton.ButtonPushedFcn = createCallbackFcn(app, @COMPUTEButtonPushed, true);
            app.COMPUTEButton.WordWrap = 'on';
            app.COMPUTEButton.Position = [49 184 115 32];
            app.COMPUTEButton.Text = 'COMPUTE';

            % Create RESETVIEWPORTButton
            app.RESETVIEWPORTButton = uibutton(app.LeftPanel, 'push');
            app.RESETVIEWPORTButton.WordWrap = 'on';
            app.RESETVIEWPORTButton.Position = [49 147 115 38];
            app.RESETVIEWPORTButton.Text = 'RESET VIEWPORT';

            % Create AxisEqualCheckBox
            app.AxisEqualCheckBox = uicheckbox(app.LeftPanel);
            app.AxisEqualCheckBox.Text = 'Axis Equal';
            app.AxisEqualCheckBox.Position = [67 19 79 22];

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
            app.IMAXEditField.RoundFractionalValues = 'on';
            app.IMAXEditField.HorizontalAlignment = 'center';
            app.IMAXEditField.Placeholder = '1';
            app.IMAXEditField.Position = [88 101 36 22];

            % Create RMINEditFieldLabel
            app.RMINEditFieldLabel = uilabel(app.LeftPanel);
            app.RMINEditFieldLabel.HorizontalAlignment = 'right';
            app.RMINEditFieldLabel.Position = [12 80 36 22];
            app.RMINEditFieldLabel.Text = 'RMIN';

            % Create RMINEditField
            app.RMINEditField = uieditfield(app.LeftPanel, 'numeric');
            app.RMINEditField.RoundFractionalValues = 'on';
            app.RMINEditField.HorizontalAlignment = 'center';
            app.RMINEditField.Placeholder = '1';
            app.RMINEditField.Position = [48 80 31 22];

            % Create RMAXEditFieldLabel
            app.RMAXEditFieldLabel = uilabel(app.LeftPanel);
            app.RMAXEditFieldLabel.HorizontalAlignment = 'right';
            app.RMAXEditFieldLabel.Position = [162 80 40 22];
            app.RMAXEditFieldLabel.Text = 'RMAX';

            % Create RMAXEditField
            app.RMAXEditField = uieditfield(app.LeftPanel, 'numeric');
            app.RMAXEditField.RoundFractionalValues = 'on';
            app.RMAXEditField.HorizontalAlignment = 'center';
            app.RMAXEditField.Placeholder = '1';
            app.RMAXEditField.Position = [132 80 31 22];

            % Create IMINEditFieldLabel
            app.IMINEditFieldLabel = uilabel(app.LeftPanel);
            app.IMINEditFieldLabel.HorizontalAlignment = 'center';
            app.IMINEditFieldLabel.Position = [92 40 30 22];
            app.IMINEditFieldLabel.Text = 'IMIN';

            % Create IMINEditField
            app.IMINEditField = uieditfield(app.LeftPanel, 'numeric');
            app.IMINEditField.RoundFractionalValues = 'on';
            app.IMINEditField.HorizontalAlignment = 'center';
            app.IMINEditField.Placeholder = '1';
            app.IMINEditField.Position = [88 61 36 22];

            % Create EigSearchEditFieldLabel
            app.EigSearchEditFieldLabel = uilabel(app.LeftPanel);
            app.EigSearchEditFieldLabel.HorizontalAlignment = 'center';
            app.EigSearchEditFieldLabel.WordWrap = 'on';
            app.EigSearchEditFieldLabel.Position = [19 407 68 30];
            app.EigSearchEditFieldLabel.Text = '# Eig Search';

            % Create EigSearchEditField
            app.EigSearchEditField = uieditfield(app.LeftPanel, 'numeric');
            app.EigSearchEditField.Limits = [0 Inf];
            app.EigSearchEditField.ValueDisplayFormat = '%.0f';
            app.EigSearchEditField.HorizontalAlignment = 'center';
            app.EigSearchEditField.Position = [86 407 109 30];
            app.EigSearchEditField.ValueChangedFcn = createCallbackFcn(app, @mEditFieldValueChanged, true);

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

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.RightPanel);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1.83x', '1x'};
            app.GridLayout2.RowSpacing = 7.33333333333333;
            app.GridLayout2.Padding = [6 7.33333333333333 6 7.33333333333333];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout2);
            app.UIAxes.Layer = 'top';
            app.UIAxes.XGrid = 'on';
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.YMinorGrid = 'on';
            app.UIAxes.ZMinorGrid = 'on';
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout2);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 1;

            % Create NLEVPInformationTab
            app.NLEVPInformationTab = uitab(app.TabGroup);
            app.NLEVPInformationTab.Title = 'NLEVP Information';

            % Create TextArea_3
            app.TextArea_3 = uitextarea(app.NLEVPInformationTab);
            app.TextArea_3.Editable = 'off';
            app.TextArea_3.HorizontalAlignment = 'center';
            app.TextArea_3.BackgroundColor = [0.8 0.8 0.8];
            app.TextArea_3.Position = [15 13 501 117];
            app.TextArea_3.Value = {'Information about the loaded NLEVP (if taken from the NLEVP pack, say)'; 'Each problem has their own "documentation" in matlab comments, though I don''t know if there is a way to extract some relevant bits programatically.'};

            % Create ContourTab
            app.ContourTab = uitab(app.TabGroup);
            app.ContourTab.Title = 'Contour';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ContourTab);
            app.GridLayout3.ColumnWidth = {100, '1x'};
            app.GridLayout3.RowHeight = {114};

            % Create TypeButtonGroup
            app.TypeButtonGroup = uibuttongroup(app.GridLayout3);
            app.TypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @TypeButtonGroupSelectionChanged, true);
            app.TypeButtonGroup.TitlePosition = 'centertop';
            app.TypeButtonGroup.Title = 'Type';
            app.TypeButtonGroup.Layout.Row = 1;
            app.TypeButtonGroup.Layout.Column = 1;

            % Create CircleButton
            app.CircleButton = uiradiobutton(app.TypeButtonGroup);
            app.CircleButton.Text = 'Circle';
            app.CircleButton.Position = [11 68 58 22];
            app.CircleButton.Value = true;

            % Create EllipseButton
            app.EllipseButton = uiradiobutton(app.TypeButtonGroup);
            app.EllipseButton.Text = 'Ellipse';
            app.EllipseButton.Position = [11 46 65 22];

            % Create RectangleButton
            app.RectangleButton = uiradiobutton(app.TypeButtonGroup);
            app.RectangleButton.Enable = 'off';
            app.RectangleButton.Text = 'Rectangle';
            app.RectangleButton.Position = [11 24 76 22];

            % Create contourparameters
            app.contourparameters = CircleComponent(app.GridLayout3);
            app.contourparameters.Layout.Row = 1;
            app.contourparameters.Layout.Column = 2;

            % Create Shift(s) tab
            app.ShiftsTab = uitab(app.TabGroup);
            app.ShiftsTab.Title = 'Shift(s)';

            % Create EigenvalueInformationTab
            app.EigenvalueInformationTab = uitab(app.TabGroup);
            app.EigenvalueInformationTab.Title = 'Eigenvalue Information';

            % Create TextArea
            app.TextArea = uitextarea(app.EigenvalueInformationTab);
            app.TextArea.Editable = 'off';
            app.TextArea.BackgroundColor = [0.8 0.8 0.8];
            app.TextArea.Position = [15 13 501 117];
            app.TextArea.Value = {'List of Computed Eigenvalues'; 'Matching Distance to Reference (if provided)'};

            % Create ErrorsWarningsTab
            app.ErrorsWarningsTab = uitab(app.TabGroup);
            app.ErrorsWarningsTab.Title = 'Errors/Warnings';

            % Create TextArea_2
            app.TextArea_2 = uitextarea(app.ErrorsWarningsTab);
            app.TextArea_2.Editable = 'off';
            app.TextArea_2.BackgroundColor = [0.8 0.8 0.8];
            app.TextArea_2.Position = [15 13 501 117];
            app.TextArea_2.Value = {'Warnings/Errors'; 'numerical rank warnings during data matrix construction'; ''; 'When warnings present themselves, this tab should "light up red" or something like that.'; 'Maybe warnings in orange and errors in red?'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CIMTOOL

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end