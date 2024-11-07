classdef ShiftsTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ShiftsTable                         matlab.ui.control.Table
    end

    properties (Access = public)
        CIMData
    end
    
    methods

        function obj = ShiftsTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            obj.addListeners();

        end

        function updateFontSize(comp,update)
            comp.ShiftsTable.FontSize = update;
        end

    end

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

        function addListeners(comp)
            addlistener(comp.CIMData.RealizationData,'InterpolationData','PostSet',@(src,event)comp.InterpolationDataChangedFcn);
            addlistener(comp.CIMData.RealizationData,'ComputationalMode','PostSet',@(src,event)comp.ShiftsTableEditableFcn);
        end

    end

    methods (Access = protected)
        
        function update(comp)
            %TODO
        end

        function setup(comp)
            comp.GridLayout = uigridlayout(comp.Parent,[1,1]);
            comp.GridLayout.Padding = [10 10 10 10];
            % table of shifts
            comp.ShiftsTable = uitable(comp.GridLayout);
            comp.ShiftsTable.ColumnName = {'theta','sigma'};
            comp.ShiftsTable.RowName = {};
            comp.ShiftsTable.CellEditCallback = @comp.ShiftsTableCellEdit;
        end
    end
    
end

