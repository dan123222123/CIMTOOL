classdef Menu < matlab.ui.componentcontainer.ComponentContainer 
    
    properties
        FileMenu
        %
        ImportNLEVP
        % %
        ImportNLEVPPack
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
                strarg = missing;
            end
            try
                comp.CIMData.SampleData.NLEVP.loadNLEVPpack(probstr,strarg);
            catch e
                rethrow(e)
            end
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
            
        end

    end

end

