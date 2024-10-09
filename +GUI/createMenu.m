function createMenu(app)            
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
end