function createShiftsTab(app)
    % ShiftsTab
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
end