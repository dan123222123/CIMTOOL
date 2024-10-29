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
        CIMData
    end
    
    methods (Access = protected)

        function update(comp)
            %TODO
        end
        
        function setup(comp)

            comp.FileMenu = uimenu(comp.Parent);
            comp.FileMenu.Text = 'File';
        
            comp.ImportNLEVP = uimenu(comp.FileMenu);
            comp.ImportNLEVP.Text = 'Import NLEVP';

            comp.ImportNLEVPPack = uimenu(comp.ImportNLEVP);
            % comp.ImportNLEVPPack.MenuSelectedFcn = createCallbackFcn(comp, @NLEVPPackMenuSelected, true);
            comp.ImportNLEVPPack.Text = 'From NLEVP Pack';
            
        end

    end

end

