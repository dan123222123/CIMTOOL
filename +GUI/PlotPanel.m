classdef PlotPanel < matlab.ui.componentcontainer.ComponentContainer

    % Component Properties
    properties (Access = private)
        PlotTabGridLayout               matlab.ui.container.GridLayout
        PlotTabGroup                    matlab.ui.container.TabGroup
        %
        MainPlotTab                     matlab.ui.container.Tab
        MainPlotTabGridLayout           matlab.ui.container.GridLayout
        %
        HSVPlotTab                      matlab.ui.container.Tab
        HSVPlotTabGridLayout            matlab.ui.container.GridLayout
    end

    properties (Access = public, SetObservable)
        MainPlotAxes                    matlab.ui.control.UIAxes
        HSVAxes                         matlab.ui.control.UIAxes
    end

    properties (Access = public)
        MainApp % app that contains this component, set in constructor
        CIMData % underlying computational structure that this component will modify
    end

    methods (Access=public)

        function obj = PlotPanel(Parent,MainApp,CIMData)

            % properly sets the parent
            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)

            obj.MainApp = MainApp;
            obj.CIMData = CIMData;

            obj.CIMData.MainAx = obj.MainPlotAxes;
            obj.CIMData.SvAx = obj.HSVAxes;

            % set the axes and listeners here, as setup will have already
            % executed at this point!
        end

    end

    methods (Access=protected)
        
        % executes when the value of a public property is changed
        % basically, just make sure the axes are still the active ones
        function update(comp)
            comp.CIMData.MainAx = comp.MainPlotAxes;
            comp.CIMData.SvAx = comp.HSVAxes;
        end

        % create the underlying component
        function setup(comp)
            
            comp.PlotTabGridLayout = uigridlayout(comp,[1, 1]);

            % Create PlotTabGroup
            comp.PlotTabGroup = uitabgroup(comp.PlotTabGridLayout);
            
            % Create MainPlotTab
            comp.MainPlotTab = uitab(comp.PlotTabGroup);
            comp.MainPlotTab.Title = 'Complex Plane';

            % Create HSVPlotTab
            comp.HSVPlotTab = uitab(comp.PlotTabGroup);
            comp.HSVPlotTab.Title = 'Data Matrix Singular Values';
        
            % Create MainPlotAxes
            comp.MainPlotAxes = uiaxes(comp.MainPlotTab);
            comp.MainPlotAxes.Layer = 'top';
            comp.MainPlotAxes.XGrid = 'on';
            comp.MainPlotAxes.XMinorGrid = 'on';
            comp.MainPlotAxes.YGrid = 'on';
            comp.MainPlotAxes.YMinorGrid = 'on';
            comp.MainPlotAxes.Title.String = 'NORMAL MODE';
            axis(comp.MainPlotAxes,'equal');
            hold(comp.MainPlotAxes,"on"); % easier to set hold on here
        
            % Create HSVAxes
            comp.HSVAxes = uiaxes(comp.HSVPlotTab);
            comp.HSVAxes.Layer = 'top';
            comp.HSVAxes.XGrid = 'on';
            comp.HSVAxes.XMinorGrid = 'on';
            comp.HSVAxes.YGrid = 'on';
            comp.HSVAxes.YMinorGrid = 'on';
            comp.HSVAxes.YScale = 'log';
            legend(comp.HSVAxes);

        end

    end

end