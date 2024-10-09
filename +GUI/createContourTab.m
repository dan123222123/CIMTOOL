function createContourTab(app)
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
end