classdef Menu < matlab.ui.componentcontainer.ComponentContainer 
    
    properties
        FileMenu
        %
        ImportNLEVP
        % %
        ImportNLEVPPack
        %
        EditMenu
        PreferencesItem
    end

    properties (Access = public)
        MainApp
        CIMData Numerics.CIM
    end

    methods

        function obj = Menu(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

        end

        function ImportNLEVPPackFcn(comp,event)
            prompt = {"problem","arglist (comma-separated list)"};
            answer = inputdlg(prompt,"NLEVP pack import");
            if isempty(answer)
                warndlg("No NLEVP entered...");
                return;
            end
            probstr = answer{1};
            strarg = answer{2};
            if isempty(strarg)
                strarg = [];
            end
            try
                comp.CIMData.SampleData.OperatorData.loadNLEVPPACK(probstr,strarg);
            catch e
                rethrow(e)
            end
        end

        function PreferencesFcn(comp,event)
            % Open preferences dialog
            dlg = GUI.PreferencesDialog(comp.MainApp.UIFigure, comp.MainApp, comp.CIMData);
        end

    end
    
    methods (Access = protected)

        function update(comp)
            %TODO
        end
        
        function setup(comp)
            import GUI.Menu.*

            comp.FileMenu = uimenu(comp.Parent);
            comp.FileMenu.Text = 'File';

            comp.ImportNLEVP = uimenu(comp.FileMenu);
            comp.ImportNLEVP.Text = 'Import NLEVP';

            comp.ImportNLEVPPack = uimenu(comp.ImportNLEVP);
            comp.ImportNLEVPPack.MenuSelectedFcn = @(src,event)comp.ImportNLEVPPackFcn;
            comp.ImportNLEVPPack.Text = 'From NLEVP Pack';

            % Edit menu
            comp.EditMenu = uimenu(comp.Parent);
            comp.EditMenu.Text = 'Edit';

            comp.PreferencesItem = uimenu(comp.EditMenu);
            comp.PreferencesItem.MenuSelectedFcn = @(src,event)comp.PreferencesFcn;
            comp.PreferencesItem.Text = 'Preferences...';
            comp.PreferencesItem.Accelerator = ',';  % Ctrl+, shortcut

        end

    end

end

