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
        ctrlKey
        shiftKey
        CIMData                         Numerics.CIM
    end

    properties (SetObservable)
        FontSize
    end

    methods

        function recordKey(app,src,event)
            % if app.shiftKey
            %     set(app.MainPlotAxes.Title,'String','MOD');
            %     set(app.UIFigure,'WindowButtonDownFcn',@app.MainPlotAxesWindowButtonDownFcn);
            %     app.MainPlotAxes.Interactions = dataTipInteraction('SnapToDataVertex','on');
            %     app.MainPlotAxes.PickableParts = "all";
            % end
            if contains(event.Modifier,'control')
                if event.Key == "equal"
                    app.updateFontSize(1);
                elseif event.Key == "hyphen"
                    app.updateFontSize(-1);
                end
            end
        end

    end
    
    % % GUI Plot Interactions
    % methods (Access = public)

        % % this callback will be set when SHIFT is pressed
        % % should allow for axes interactivity when not selected, while
        % % allowing the user to affect CIM parameters when desired
        % function MainPlotAxesWindowButtonDownFcn(app,handle,event)
        %     cf = gco(app.UIFigure);
        %     switch(cf.Tag)
        %         case "contour_center"
        %             set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_center);
        %             set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_center);
        %         case "contour"
        %             set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_radius);
        %             set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_radius);
        %     end
        % end
        % 
        % function releaseKey(app,src,event)
        %     set(app.MainPlotAxes.Title,'String','NORMAL');
        %     app.ctrlKey = [false false];
        %     set(app.UIFigure,'WindowButtonDownFcn','');
        %     set(app.UIFigure,'WindowButtonMotionFcn','');
        %     set(app.UIFigure,'WindowButtonUpFcn','');
        %     app.MainPlotAxes.Interactions = [panInteraction('Dimensions','xy') zoomInteraction('Dimensions','xy')];
        % end
    % 
    %     function drag_center(app,handle,event)
    %         cp = app.MainPlotAxes.CurrentPoint;
    %         onc = findobj(app.MainPlotAxes,'Tag','new_contour_center');
    %         if ~isempty(onc)
    %             delete(onc)
    %         end
    %         scatter(app.MainPlotAxes,cp(1,1),cp(1,2),200,"red",'filled','Tag',"new_contour_center");
    %     end
    % 
    %     function set_new_center(app,handle,event)
    %         cp = app.MainPlotAxes.CurrentPoint;
    %         cp = cp(1,1) + cp(1,2)*1i;
    %         delete(findobj(app.MainPlotAxes,'Tag','new_contour_center'));
    %         app.contourparameters.center = cp;
    %         app.releaseKey(handle,event);
    %     end
    % 
    %     function drag_radius(app,handle,event)
    %         cp = app.MainPlotAxes.CurrentPoint;
    %         cp = cp(1,1) + cp(1,2)*1i;
    %         center = app.contourparameters.center;
    %         radius = sqrt((real(center) - real(cp))^2 + (imag(center) - imag(cp))^2);
    %         onc = findobj(app.MainPlotAxes,'Tag','new_contour');
    %         if ~isempty(onc)
    %             delete(onc)
    %         end
    %         zc = circle_trapezoid(256,center,radius);
    %         zc = [center + radius, zc, center + radius];
    %         plot(app.MainPlotAxes,real(zc),imag(zc),"red",'LineWidth',5,'Tag',"new_contour");
    %     end
    % 
    %     function set_new_radius(app,handle,event)
    %         cp = app.MainPlotAxes.CurrentPoint;
    %         cp = cp(1,1) + cp(1,2)*1i;
    %         center = app.contourparameters.center;
    %         radius = sqrt((real(center) - real(cp))^2 + (imag(center) - imag(cp))^2);
    %         delete(findobj(app.MainPlotAxes,'Tag','new_contour'));
    %         app.contourparameters.radius = radius;
    %         app.releaseKey(handle,event);
    %     end
    % 
    % end

    methods (Access = private)

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
        end
        

        % Create UIFigure and components
        function createComponents(app)

            % app.UIFigure = uifigure('Visible', 'off','WindowKeyPressFcn',@app.recordKey,'WindowKeyReleaseFcn',@app.releaseKey);
            % app.UIFigure = uifigure('Visible', 'off');
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
            app.PlotPanel = GUI.PlotPanel(app.RightPanelGridLayout,app,app.CIMData);
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