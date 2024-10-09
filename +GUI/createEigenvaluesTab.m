function createEigenvaluesTab(app)
    % EigenvaluesTab
    app.EigenvaluesTab = uitab(app.ParameterTabGroup);
    app.EigenvaluesTab.Title = 'Eigenvalue Information';

    % EigenvalueInformationGridLayout
    app.EigenvaluesTabGridLayout = uigridlayout(app.EigenvaluesTab);
    app.EigenvaluesTabGridLayout.ColumnWidth = {'1x'};
    app.EigenvaluesTabGridLayout.RowHeight = { '1x'};
    app.EigenvaluesTabGridLayout.Padding = [10 10 10 10];

    % EigenvalueInformationTable
    app.EigenvaluesTable = uitable(app.EigenvaluesTabGridLayout);
    app.EigenvaluesTable.ColumnName = {'ew','tnr'};
    app.EigenvaluesTable.RowName = {};
    app.EigenvaluesTable.CellEditCallback = createCallbackFcn(app, @EigenvaluesTableCellEdit, true);
    app.EigenvaluesTable.Layout.Row = 1;
    app.EigenvaluesTable.Layout.Column = 1;
end