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
        AxisEqualCheckbox
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

            % If axis equal is enabled, maintain square aspect ratio
            if comp.AxisEqualCheckbox.Value
                % Determine which control was changed
                Rrange = diff(NewXLim);
                Irange = diff(NewYLim);

                % Use the larger range to determine the square size
                maxRange = max(Rrange, Irange);

                % Calculate centers
                Rcenter = mean(NewXLim);
                Icenter = mean(NewYLim);

                % Adjust both axes to maintain square aspect ratio
                NewXLim = Rcenter + [-maxRange/2; maxRange/2];
                NewYLim = Icenter + [-maxRange/2; maxRange/2];

                % Update all controls
                comp.Rmin.Value = NewXLim(1);
                comp.Rmax.Value = NewXLim(2);
                comp.Imin.Value = NewYLim(1);
                comp.Imax.Value = NewYLim(2);
            end

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

        function AxisEqualCheckboxChangedFcn(comp, ~)
            if comp.AxisEqualCheckbox.Value
                % Enable axis equal
                axis(comp.MainPlotAxes, 'equal');
            else
                % Disable axis equal
                axis(comp.MainPlotAxes, 'normal');
            end
            MainPlotWindowXLimChangedFcn(comp,[],[]);
            MainPlotWindowYLimChangedFcn(comp,[],[]);
        end

        function update(comp)
            %TODO
        end

        function setup(comp)

            comp.GridLayout = uigridlayout(comp,[3,4]);

            comp.AxisEqualCheckbox = uicheckbox(comp.GridLayout);
            comp.AxisEqualCheckbox.Text = 'Square';
            comp.AxisEqualCheckbox.Value = false;
            comp.AxisEqualCheckbox.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @AxisEqualCheckboxChangedFcn, true);
            comp.AxisEqualCheckbox.Layout.Row = 1;
            comp.AxisEqualCheckbox.Layout.Column = 1;
            %
            comp.ImaxLabel = uilabel(comp.GridLayout);
            comp.ImaxLabel.HorizontalAlignment = 'right';
            comp.ImaxLabel.Text = 'IMAX:';
            comp.ImaxLabel.Layout.Row = 1;
            comp.ImaxLabel.Layout.Column = 2;
            %
            comp.Imax = uieditfield(comp.GridLayout, 'numeric');
            comp.Imax.HorizontalAlignment = 'center';
            comp.Imax.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Imax.Layout.Row = 1;
            comp.Imax.Layout.Column = 3;
            % %
            comp.RminLabel = uilabel(comp.GridLayout);
            comp.RminLabel.HorizontalAlignment = 'right';
            comp.RminLabel.Text = 'RMIN:';
            comp.RminLabel.Layout.Row = 2;
            comp.RminLabel.Layout.Column = 1;
            %
            comp.Rmin = uieditfield(comp.GridLayout, 'numeric');
            comp.Rmin.HorizontalAlignment = 'center';
            comp.Rmin.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Rmin.Layout.Row = 2;
            comp.Rmin.Layout.Column = 2;
            % %
            comp.RmaxLabel = uilabel(comp.GridLayout);
            comp.RmaxLabel.HorizontalAlignment = 'left';
            comp.RmaxLabel.Text = 'RMAX:';
            comp.RmaxLabel.Layout.Row = 2;
            comp.RmaxLabel.Layout.Column = 3;
            %
            comp.Rmax = uieditfield(comp.GridLayout, 'numeric');
            comp.Rmax.HorizontalAlignment = 'center';
            comp.Rmax.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Rmax.Layout.Row = 2;
            comp.Rmax.Layout.Column = 4;
            % %
            comp.Imin = uieditfield(comp.GridLayout, 'numeric');
            comp.Imin.HorizontalAlignment = 'center';
            comp.Imin.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Imin.Layout.Row = 3;
            comp.Imin.Layout.Column = 3;
            %
            comp.IminLabel = uilabel(comp.GridLayout);
            comp.IminLabel.HorizontalAlignment = 'right';
            comp.IminLabel.Text = 'IMIN:';
            comp.IminLabel.Layout.Row = 3;
            comp.IminLabel.Layout.Column = 2;
        end

    end

end

