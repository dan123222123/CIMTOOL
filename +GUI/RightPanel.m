classdef RightPanel < matlab.ui.componentcontainer.ComponentContainer

    % Component Properties
    properties (Access = private)
        GridLayout                      matlab.ui.container.GridLayout
        PlotTabGroup                    matlab.ui.container.TabGroup
        MainPlotTab                     matlab.ui.container.Tab
        MainPlotTabGridLayout           matlab.ui.container.GridLayout
        MainPlotAxes                    matlab.ui.control.UIAxes
        HSVPlotTab                      matlab.ui.container.Tab
        HSVAxes                         matlab.ui.control.UIAxes
    end

    properties (Access = public)
        MainApp % app that contains this component, set in constructor
        CIM     % underlying computational structure that this component will modify
    end

    methods

        % executes when the value of a public property is changed
        function update(comp)
        end

        % create the underlying component
        function setup(comp)

            comp.Position = [1 1 1 1];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'1x'};
            comp.GridLayout.RowHeight = {'2x', '1x'};
            comp.GridLayout.RowSpacing = 7.33333333333333;
            comp.GridLayout.Padding = [10 10 10 10];

            % Create PlotTabGroup
            comp.PlotTabGroup = uitabgroup(comp.GridLayout);
            comp.PlotTabGroup.Layout.Row = 1;
            comp.PlotTabGroup.Layout.Column = 1;

        end

    end

end