classdef ParameterPanel < matlab.ui.componentcontainer.ComponentContainer

    properties (Access = private)
        ParameterTabGridLayout              matlab.ui.container.GridLayout
        ParameterTabGroup                   matlab.ui.container.TabGroup
        %
        NLEVPTab                            GUI.Parameter.NLEVPTab
        ContourTab                          GUI.Parameter.ContourTab
        MethodTab                           GUI.Parameter.MethodTab
        ShiftsTab                           GUI.Parameter.ShiftsTab
    end

    properties (Access = public)
        MainApp
        CIMData Numerics.CIM
    end

    methods (Access=public)

        function obj = ParameterPanel(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.createDynamicComponents();

        end

        function createDynamicComponents(comp)

            import GUI.Parameter.*
            
            comp.NLEVPTab = NLEVPTab(uitab(comp.ParameterTabGroup,'Title','NLEVP'),comp.CIMData);
            %
            comp.ContourTab = ContourTab(uitab(comp.ParameterTabGroup,'Title','Contour'),comp.CIMData);
            %
            comp.MethodTab = MethodTab(uitab(comp.ParameterTabGroup,'Title','Method'),comp.CIMData);
            %
            comp.ShiftsTab = ShiftsTab(uitab(comp.ParameterTabGroup,'Title','Shifts(s)'),comp.CIMData);
            
        end

    end
    
    % pure GUI construction
    methods (Access=protected)

        function update(comp)
            %TODO
        end

        function setup(comp)
            comp.ParameterTabGridLayout = uigridlayout(comp,[1, 1]);
            comp.ParameterTabGroup = uitabgroup(comp.ParameterTabGridLayout);
        end

    end

end