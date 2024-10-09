function createNLEVPTab(app)
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
end