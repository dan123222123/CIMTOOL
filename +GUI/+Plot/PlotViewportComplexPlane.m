classdef PlotViewportComplexPlane < GUI.Plot.PlotViewportComponent

    properties
        GridLayout
        Imax
        Rmax
        Imin
        Rmin
        ImaxLabel
        RmaxLabel
        IminLabel
        RminLabel
    end

    properties (Access = public)
        MainPlotAxes
    end

    methods (Access = public)

        function obj = PlotViewportComplexPlane(Parent,MainPlotAxes)

            obj@GUI.Plot.PlotViewportComponent(Parent)
            obj.MainPlotAxes = MainPlotAxes;

            obj.addListeners();

            obj.Rmax.Value = obj.MainPlotAxes.XLim(2);
            obj.Rmin.Value = obj.MainPlotAxes.XLim(1);
            obj.Imax.Value = obj.MainPlotAxes.YLim(2);
            obj.Imin.Value = obj.MainPlotAxes.YLim(1);

        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end
    
    methods (Access = protected)

        function addListeners(comp)
            addlistener(comp.MainPlotAxes,'XLim','PostSet',@(src,event)comp.MainPlotWindowXLimChangedFcn);
            addlistener(comp.MainPlotAxes,'YLim','PostSet',@(src,event)comp.MainPlotWindowYLimChangedFcn);
        end

        function MainPlotWindowXLimChangedFcn(comp,~,~)
            comp.Rmin.Value = comp.MainPlotAxes.XLim(1);
            comp.Rmax.Value = comp.MainPlotAxes.XLim(2);
        end

        function MainPlotWindowYLimChangedFcn(comp,~,~)
            comp.Imin.Value = comp.MainPlotAxes.YLim(1);
            comp.Imax.Value = comp.MainPlotAxes.YLim(2);
        end

        function MainPlotAxesWindowChangedFcn(comp, event)
            OldXLim = comp.MainPlotAxes.XLim;
            OldYLim = comp.MainPlotAxes.YLim;
            NewXLim = [comp.Rmin.Value; comp.Rmax.Value];
            NewYLim = [comp.Imin.Value; comp.Imax.Value];
            try
                comp.MainPlotAxes.XLim = NewXLim;
                comp.MainPlotAxes.YLim = NewYLim;
            catch PLE
                event.Source.Value = event.PreviousValue;
                comp.MainPlotAxes.XLim = OldXLim;
                comp.MainPlotAxes.YLim = OldYLim;
                uialert(comp.UIFigure,'Please ensure that IMIN < IMAX and RMIN < RMAX.','MainPlotAxes Error');
                return
            end
        end

        function update(comp)
            %TODO
        end

        function setup(comp)

            comp.GridLayout = uigridlayout(comp,[5,5]);

            comp.ImaxLabel = uilabel(comp.GridLayout);
            comp.ImaxLabel.HorizontalAlignment = 'center';
            comp.ImaxLabel.Text = 'IMAX';
            comp.ImaxLabel.Layout.Row = 1;
            comp.ImaxLabel.Layout.Column = 3;
            %
            comp.Imax = uieditfield(comp.GridLayout, 'numeric');
            comp.Imax.HorizontalAlignment = 'center';
            comp.Imax.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Imax.Layout.Row = 2;
            comp.Imax.Layout.Column = 3;
            % %
            comp.RminLabel = uilabel(comp.GridLayout);
            comp.RminLabel.HorizontalAlignment = 'center';
            comp.RminLabel.Text = 'RMIN';
            comp.RminLabel.Layout.Row = 3;
            comp.RminLabel.Layout.Column = 1;
            %
            comp.Rmin = uieditfield(comp.GridLayout, 'numeric');
            comp.Rmin.HorizontalAlignment = 'center';
            comp.Rmin.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Rmin.Layout.Row = 3;
            comp.Rmin.Layout.Column = 2;
            % %
            comp.RmaxLabel = uilabel(comp.GridLayout);
            comp.RmaxLabel.HorizontalAlignment = 'center';
            comp.RmaxLabel.Text = 'RMAX';
            comp.RmaxLabel.Layout.Row = 3;
            comp.RmaxLabel.Layout.Column = 5;
            %
            comp.Rmax = uieditfield(comp.GridLayout, 'numeric');
            comp.Rmax.HorizontalAlignment = 'center';
            comp.Rmax.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Rmax.Layout.Row = 3;
            comp.Rmax.Layout.Column = 4;
            % %
            comp.Imin = uieditfield(comp.GridLayout, 'numeric');
            comp.Imin.HorizontalAlignment = 'center';
            comp.Imin.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Imin.Layout.Row = 4;
            comp.Imin.Layout.Column = 3;
            %
            comp.IminLabel = uilabel(comp.GridLayout);
            comp.IminLabel.HorizontalAlignment = 'center';
            comp.IminLabel.Text = 'IMIN';
            comp.IminLabel.Layout.Row = 5;
            comp.IminLabel.Layout.Column = 3;
        end

    end

end

