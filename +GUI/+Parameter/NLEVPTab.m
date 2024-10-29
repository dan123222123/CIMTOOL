classdef NLEVPTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        NLEVPHelpTextArea                   matlab.ui.control.TextArea
    end

    properties (Access = public)
        CIMData
    end
    
    methods

        function obj = NLEVPTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            % obj.addListeners();

        end

    end

    methods (Access = protected)

        function update(comp)
            %TODO
        end

        function setup(comp)
            comp.GridLayout = uigridlayout(comp.Parent,[1,1]);
            comp.GridLayout.Padding = [10 10 10 10];
            %
            comp.NLEVPHelpTextArea = uitextarea(comp.GridLayout);
            comp.NLEVPHelpTextArea.Editable = 'off';
            comp.NLEVPHelpTextArea.HorizontalAlignment = 'center';
            comp.NLEVPHelpTextArea.BackgroundColor = [0.8 0.8 0.8];
            comp.NLEVPHelpTextArea.Value = {'No NLEVP Loaded.'};
        end

    end

end