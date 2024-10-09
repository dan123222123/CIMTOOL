function createLeftPanel(app)
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
end