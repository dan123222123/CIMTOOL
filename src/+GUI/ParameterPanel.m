classdef ParameterPanel < matlab.ui.componentcontainer.ComponentContainer

    properties (Access = public)
        ParameterTabGridLayout              matlab.ui.container.GridLayout
        ParameterTabGroup                   matlab.ui.container.TabGroup
        %
        NLEVPTab                            GUI.Parameter.NLEVPTab
        ContourTab                          GUI.Parameter.ContourTab
        MethodTab                           GUI.Parameter.MethodTab
        ShiftsTab                           GUI.Parameter.ShiftsTab
        % % %
        MainApp
        CIMData Numerics.CIM
    end

    methods (Access=public)

        function obj = ParameterPanel(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.createDynamicComponents();

            addlistener(obj.MainApp,'FontSize','PostSet',@(src,event)obj.updateFontSize);

        end

        function createDynamicComponents(comp)
            
            comp.NLEVPTab = GUI.Parameter.NLEVPTab(uitab(comp.ParameterTabGroup,'Title','NLEVP'),comp.CIMData);
            %
            comp.ContourTab = GUI.Parameter.ContourTab(uitab(comp.ParameterTabGroup,'Title','Contour'),comp.MainApp,comp.CIMData);
            %
            comp.MethodTab = GUI.Parameter.MethodTab(uitab(comp.ParameterTabGroup,'Title','Method'),comp.CIMData);
            %
            comp.ShiftsTab = GUI.Parameter.ShiftsTab(uitab(comp.ParameterTabGroup,'Title','Shifts(s)'),comp.CIMData);
            
        end

        function updateFontSize(comp,~)
            update = comp.MainApp.FontSize;
            fontsize(comp.ParameterTabGridLayout.Children,update,"points");
            comp.NLEVPTab.updateFontSize(update);
            comp.ContourTab.updateFontSize(update);
            comp.MethodTab.updateFontSize(update);
            comp.ShiftsTab.updateFontSize(update);
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