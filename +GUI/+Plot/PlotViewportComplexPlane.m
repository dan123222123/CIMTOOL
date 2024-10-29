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
    
    methods (Access = protected)

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
            % comp.Imax.ValueChangedFcn = createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
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
            % comp.Rmin.ValueChangedFcn = createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
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
            % comp.RMAXEditField.ValueChangedFcn = createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Rmax.Layout.Row = 3;
            comp.Rmax.Layout.Column = 4;
            % %
            comp.Imax = uieditfield(comp.GridLayout, 'numeric');
            comp.Imax.HorizontalAlignment = 'center';
            % comp.IMINEditField.ValueChangedFcn = createCallbackFcn(comp, @MainPlotAxesWindowChangedFcn, true);
            comp.Imax.Layout.Row = 4;
            comp.Imax.Layout.Column = 3;
            %
            comp.ImaxLabel = uilabel(comp.GridLayout);
            comp.ImaxLabel.HorizontalAlignment = 'center';
            comp.ImaxLabel.Text = 'IMIN';
            comp.ImaxLabel.Layout.Row = 5;
            comp.ImaxLabel.Layout.Column = 3;
        end

    end

end

