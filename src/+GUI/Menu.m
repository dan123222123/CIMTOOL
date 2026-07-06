classdef Menu < matlab.ui.componentcontainer.ComponentContainer 
    
    properties
        FileMenu
        %
        SaveStateItem
        LoadStateItem
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

        function SaveStateFcn(comp,event)
            % Serialize the full CIM session to a .mat file.
            [file,path] = uiputfile('*.mat','Save CIMTOOL Session');
            if isequal(file,0)
                return;  % user cancelled
            end
            try
                n = comp.CIMData.toNumerics();   % strip graphics handles first
                n.saveState(string(fullfile(path,file)));
            catch e
                uialert(comp.MainApp.UIFigure, ...
                    sprintf('Could not save session:\n%s',e.message),'Save Failed');
            end
        end

        function LoadStateFcn(comp,event)
            % Load a session and relaunch CIMTOOL in a fresh window. There is
            % no in-place panel-rebind path today (panels bind listeners to the
            % current CIM's sub-object instances), so we tear down and relaunch.
            % TODO: add an in-place refresh that rebinds panels/listeners to the
            % newly-loaded CIM instead of relaunching the window.
            [file,path] = uigetfile('*.mat','Load CIMTOOL Session');
            if isequal(file,0)
                return;  % user cancelled
            end
            % Capture what we need up front -- deleting the old app destroys comp.
            oldApp = comp.MainApp;
            sp = comp.CIMData.StylePreferences;
            try
                n = Numerics.CIM.loadState(string(fullfile(path,file)));
            catch e
                uialert(comp.MainApp.UIFigure, ...
                    sprintf('Could not load session:\n%s',e.message),'Load Failed');
                return;  % leave the current window intact
            end
            % Open the new window (CIMTOOL auto-upgrades a Numerics.CIM), then
            % close the old one. delete(oldApp) MUST be the final statement --
            % nothing may touch comp afterwards.
            CIMTOOL(n, sp);
            delete(oldApp);
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

            comp.SaveStateItem = uimenu(comp.FileMenu);
            comp.SaveStateItem.MenuSelectedFcn = @(src,event)comp.SaveStateFcn;
            comp.SaveStateItem.Text = 'Save State...';
            comp.SaveStateItem.Accelerator = 's';  % Ctrl+S

            comp.LoadStateItem = uimenu(comp.FileMenu);
            comp.LoadStateItem.MenuSelectedFcn = @(src,event)comp.LoadStateFcn;
            comp.LoadStateItem.Text = 'Load State...';
            comp.LoadStateItem.Accelerator = 'o';  % Ctrl+O

            comp.ImportNLEVP = uimenu(comp.FileMenu);
            comp.ImportNLEVP.Text = 'Import NLEVP';
            comp.ImportNLEVP.Separator = 'on';

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

