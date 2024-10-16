classdef ParameterPanel < matlab.ui.componentcontainer.ComponentContainer

    % Component Properties
    properties (Access = private)
        ParameterTabGridLayout              matlab.ui.container.GridLayout
        ParameterTabGroup                   matlab.ui.container.TabGroup
        %
        ShiftsTabGridLayout                 matlab.ui.container.GridLayout
        ShiftsTab                           matlab.ui.container.Tab
        ShiftsTable                         matlab.ui.control.Table
    end

    properties (Access = public)
        MainApp % app that contains this component, set in constructor
        CIMData Numerics.CIM
    end

    % constructor
    methods (Access=public)

        function obj = ParameterPanel(Parent,MainApp,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.addShiftsTabListeners();

        end

    end

    % shift tab methods
    methods (Access=private)

        % ShiftsTable Changed -> update InterpolationData
        function ShiftsTableCellEdit(comp, src, event)
            comp.CIMData.RealizationData.InterpolationData = Numerics.InterpolationData(event.Source.Data.theta,event.Source.Data.sigma);
        end

        % make certain table entries editable based on Computational Mode
        function ShiftsTableEditableFcn(comp, event)
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case Numerics.ComputationalMode.Hankel
                    comp.ShiftsTable.ColumnEditable = [false false];
                case Numerics.ComputationalMode.SPLoewner
                    comp.ShiftsTable.ColumnEditable = [false true];
                case Numerics.ComputationalMode.MPLoewner
                    comp.ShiftsTable.ColumnEditable = true;
            end
        end

        % InterpolationData Changed -> update ShiftsTable
        function InterpolationDataChangedFcn(comp, event)
            id = comp.CIMData.RealizationData.InterpolationData;
            theta = id.theta;
            sigma = id.sigma;
            mil = max(length(id.theta),length(id.sigma));
            thetapadsize = mil - length(theta);
            sigmapadsize = mil - length(sigma);
            comp.ShiftsTable.Data = table(padarray(theta,thetapadsize,NaN,'post'),padarray(sigma,sigmapadsize,NaN,'post'),'VariableNames',["theta","sigma"]);
        end

        % create ShiftsTab ui components
        function createShiftsTab(comp,anchor)
            comp.ShiftsTab = uitab(anchor);
            comp.ShiftsTab.Title = 'Shift(s)';
            %
            comp.ShiftsTabGridLayout = uigridlayout(comp.ShiftsTab,[1,1]);
            comp.ShiftsTabGridLayout.ColumnWidth = {'1x'};
            comp.ShiftsTabGridLayout.RowHeight = {'1x'};
            comp.ShiftsTabGridLayout.Padding = [10 10 10 10];
            % table of shifts
            comp.ShiftsTable = uitable(comp.ShiftsTabGridLayout);
            comp.ShiftsTable.ColumnName = {'theta','sigma'};
            comp.ShiftsTable.RowName = {};
            comp.ShiftsTable.CellEditCallback = @comp.ShiftsTableCellEdit;
        end

        function addShiftsTabListeners(comp)
            addlistener(comp.CIMData.RealizationData,'InterpolationData','PostSet',@(src,event)comp.InterpolationDataChangedFcn);
            addlistener(comp.CIMData.RealizationData,'ComputationalMode','PostSet',@(src,event)comp.ShiftsTableEditableFcn);
        end

    end

    % pure GUI construction
    methods (Access=protected)

        % executes when the value of a public property is changed
        % basically, just make sure the axes are still the active ones
        function update(comp)
            %TODO
        end

        % create the underlying component
        function setup(comp)
            
            comp.ParameterTabGridLayout = uigridlayout(comp,[1, 1]);
            comp.ParameterTabGroup = uitabgroup(comp.ParameterTabGridLayout);
            %
            comp.createShiftsTab(comp.ParameterTabGroup);

        end

    end

end