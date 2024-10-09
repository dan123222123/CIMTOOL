function createPlotTabs(app)
    % Create MainPlotTab
    app.MainPlotTab = uitab(app.PlotTabGroup);
    app.MainPlotTab.Title = 'Main';

    % Create MainPlotTabGridLayout
    app.MainPlotTabGridLayout = uigridlayout(app.MainPlotTab);
    app.MainPlotTabGridLayout.ColumnWidth = {'1x'};
    app.MainPlotTabGridLayout.RowHeight = {'1x'};
    app.MainPlotTabGridLayout.RowSpacing = 0;
    app.MainPlotTabGridLayout.Padding = [0 0 0 0];

    % Create MainPlotAxes
    app.MainPlotAxes = uiaxes(app.MainPlotTabGridLayout);
    app.MainPlotAxes.Layer = 'top';
    app.MainPlotAxes.XGrid = 'on';
    app.MainPlotAxes.XMinorGrid = 'on';
    app.MainPlotAxes.YGrid = 'on';
    app.MainPlotAxes.YMinorGrid = 'on';
    app.MainPlotAxes.ZMinorGrid = 'on';
    app.MainPlotAxes.Title.String = 'NORMAL';
    app.MainPlotAxes.DataAspectRatioMode = "manual";
    app.MainPlotAxes.Layout.Row = 1;
    app.MainPlotAxes.Layout.Column = 1;
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
end