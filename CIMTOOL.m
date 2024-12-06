classdef CIMTOOL < matlab.apps.AppBase

    % app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Menu                            GUI.Menu
        %
        GridLayout                      matlab.ui.container.GridLayout
        %
        LeftPanel                       GUI.LeftPanel
        LeftPanelGridLayout             matlab.ui.container.GridLayout
        %
        RightPanel                      matlab.ui.container.Panel
        RightPanelGridLayout            matlab.ui.container.GridLayout
        % %
        PlotPanel                       GUI.PlotPanel
        % %
        ParameterPanel                  GUI.ParameterPanel
    end

    properties (Access = public)
        CIMData                         Numerics.CIM
    end

    properties (SetObservable)
        FontSize
    end

    methods (Access = private)

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
        end
        

        % Create UIFigure and components
        function createComponents(app)

            % app.UIFigure = uifigure('Visible', 'off','WindowKeyPressFcn',@app.recordKey,'WindowKeyReleaseFcn',@app.releaseKey);
            app.UIFigure = uifigure('Visible', 'off','WindowKeyPressFcn',@app.recordKey);
            app.UIFigure.AutoResizeChildren = 'on';
            % app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'CIMTOOL';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            % %
            app.Menu = GUI.Menu(app.UIFigure,app,app.CIMData);
            % %
            app.GridLayout = uigridlayout(app.UIFigure,[1 2]);
            app.GridLayout.ColumnWidth = {'1x', '3x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            % app.GridLayout.Scrollable = 'on';
            app.LeftPanelGridLayout = uigridlayout(uipanel(app.GridLayout),[1,1]);
            app.RightPanelGridLayout = uigridlayout(uipanel(app.GridLayout),[2,1]);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'2x','1x'};
            %
            app.PlotPanel = GUI.PlotPanel(app.RightPanelGridLayout,app,app.UIFigure,app.CIMData);
            app.PlotPanel.Layout.Row = 1;
            %
            app.ParameterPanel = GUI.ParameterPanel(app.RightPanelGridLayout,app,app.CIMData);
            app.ParameterPanel.Layout.Row = 2;
            % %
            app.LeftPanel = GUI.LeftPanel(app.LeftPanelGridLayout,app,app.CIMData,app.PlotPanel.MainPlotAxes);

            app.UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        function recordKey(app,src,event)
            set(app.UIFigure,'WindowKeyPressFcn','');
            if contains(event.Modifier,'shift')
                set(app.UIFigure,'WindowButtonDownFcn',@app.MainPlotAxesWindowButtonDownFcn);
                set(app.UIFigure,'WindowKeyReleaseFcn',@app.shiftReleaseKey)
                set(app.PlotPanel.MainPlotAxes.Title,'String','MOD');
                app.PlotPanel.MainPlotAxes.Interactions = dataTipInteraction('SnapToDataVertex','off');
                app.PlotPanel.MainPlotAxes.PickableParts = "visible";
                app.CIMData.SampleData.Contour.toggleVisibility("on");
            end
            if contains(event.Modifier,'control')
                set(app.UIFigure,'WindowKeyPressFcn','');
                if event.Key == "equal"
                    app.updateFontSize(1);
                elseif event.Key == "hyphen"
                    app.updateFontSize(-1);
                end
            end
        end

        % this callback will be set when SHIFT is pressed
        % should allow for axes interactivity when not selected, while
        % allowing the user to affect CIM parameters when desired
        function MainPlotAxesWindowButtonDownFcn(app,handle,event)
            cf = gco(app.UIFigure);
            switch(cf.Tag)
                case "contour_center"
                    set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_center);
                    set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_center);
                case "contour"
                    set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_contour);
                    set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_contour);
            end
        end

        function drag_center(app,handle,event)
            % get current point
            cp = app.PlotPanel.MainPlotAxes.CurrentPoint; cp = cp(1,1) + cp(1,2)*1i;
            % delete previous ghost center
            onc = findobj(app.PlotPanel.MainPlotAxes,'Tag','ghost_contour_center');
            if ~isempty(onc)
                delete(onc)
            end
            scatter(app.PlotPanel.MainPlotAxes,real(cp),imag(cp),200,"red",'filled','Tag',"ghost_contour_center");
        end

        function drag_contour(app,handle,event)
            % get current point
            cp = app.PlotPanel.MainPlotAxes.CurrentPoint; cp = cp(1,1) + cp(1,2)*1i;
            % delete previous ghost contour
            onc = findobj(app.PlotPanel.MainPlotAxes,'Tag','ghost_contour');
            if ~isempty(onc)
                delete(onc)
            end
            % compute ghost quadrature according to previous contour
            c = app.CIMData.SampleData.Contour;
            switch(class(c))
                case 'Numerics.Contour.Circle'
                    rho = sqrt((real(c.gamma) - real(cp))^2 + (imag(c.gamma) - imag(cp))^2);
                    zc = c.trapezoid(c.gamma,rho,256);
                    zc = [c.gamma + rho, zc, c.gamma + rho];
                case 'Numerics.Contour.Ellipse'
                    error("not yet implemented");
            end
            plot(app.PlotPanel.MainPlotAxes,real(zc),imag(zc),"red",'LineWidth',5,'Tag','ghost_contour');
        end

        function set_new_center(app,handle,event)
            % get current point
            cp = app.PlotPanel.MainPlotAxes.CurrentPoint; cp = cp(1,1) + cp(1,2)*1i;
            delete(findobj(app.PlotPanel.MainPlotAxes,'Tag','ghost_contour_center'));
            app.CIMData.SampleData.Contour.gamma = cp;
            shiftReleaseKey(app,handle,event);
        end

        function set_new_contour(app,handle,event)
            % get current point
            cp = app.PlotPanel.MainPlotAxes.CurrentPoint; cp = cp(1,1) + cp(1,2)*1i;
            delete(findobj(app.PlotPanel.MainPlotAxes,'Tag','ghost_contour'));
            % set new contour
            c = app.CIMData.SampleData.Contour;
            switch(class(c))
                case 'Numerics.Contour.Circle'
                    c.rho = sqrt((real(c.gamma) - real(cp))^2 + (imag(c.gamma) - imag(cp))^2);
                case 'Numerics.Contour.Ellipse'
                    error("not yet implemented");
            end
            shiftReleaseKey(app,handle,event);
        end

        function shiftReleaseKey(app,src,event)
            set(app.PlotPanel.MainPlotAxes.Title,'String','NORMAL');
            app.CIMData.SampleData.Contour.toggleVisibility("off");
            set(app.UIFigure,'WindowButtonDownFcn','');
            set(app.UIFigure,'WindowButtonMotionFcn','');
            set(app.UIFigure,'WindowButtonUpFcn','');
            app.PlotPanel.MainPlotAxes.Interactions = [panInteraction('Dimensions','xy') zoomInteraction('Dimensions','xy')];
            set(app.UIFigure,'WindowKeyPressFcn',@app.recordKey);
        end

        % determine the proper font size/scaling for all app components
        % Update the obvervable FontSize (or FontScale) that components
        % will use to set their own (appropriate) font sizes
        function updateFontSize(app,update)

            % % base new font off of MATLAB's default font size (assumed that
            % % the user has set according to their preferences)
            % s = settings;
            % defaultFontSize = s.matlab.fonts.codefont.Size.FactoryValue;
            % minFontSize = defaultFontSize/2;
            % 
            % fig = app.UIFigure;
            % 
            % % resolution of the screen that the app is on
            % dSS = get(fig.Parent,'ScreenSize');
            % dispwidth = dSS(3);
            % dispheight = dSS(4);
            % 
            % % resolution of the app itself
            % figwidth = fig.Position(3);
            % figheight = fig.Position(4);
            % 
            % % percent fill of the app on the screen in the horizontal and
            % % vertical directions
            % wfill = (figwidth/dispwidth);
            % hfill = (figheight/dispheight);
            % 
            % % a heuristic for setting the font sizes
            % fill = min(wfill,hfill);
            % 
            % % update app.FontSize, respecting the min FontSize
            % app.FontSize = double(max(minFontSize,defaultFontSize*fill*(dispwidth/dispheight)));

            app.FontSize = app.FontSize + update;

        end

        % Construct app
        function app = CIMTOOL(CIMData)
            arguments
                CIMData = Numerics.CIM(Numerics.NLEVPData(),Numerics.Contour.Circle())
            end

            s = settings; app.FontSize = double(s.matlab.fonts.codefont.Size.FactoryValue);

            % all numerics and self-consistency are handled in app.CIM
            app.CIMData = CIMData;

            % Create UIFigure and components
            app.createComponents();

            % set event listeners
            % app.set_listeners();

            if nargout == 0
                clear app
            end
            
        end

        % Delete app
        function delete(app)
            delete(app.UIFigure)
        end

    end

end