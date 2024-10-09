function createMethodTab(app)
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

end