classdef CIMTOOL < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        %%
        LeftPanel                       matlab.ui.container.Panel
        %%
        RightPanel                      matlab.ui.container.Panel
        RightPanelGridLayout            matlab.ui.container.GridLayout
        PlotPanel                       GUI.PlotPanel
        ParameterPanel                  GUI.ParameterPanel
        % FileMenu                       matlab.ui.container.Menu
        % ImportNLEVPMenu                matlab.ui.container.Menu
        % WorkspaceMenu                  matlab.ui.container.Menu
        % ImportNLEVPFileMenu            matlab.ui.container.Menu
        % NLEVPPackMenu                  matlab.ui.container.Menu
        % ExportMenu                     matlab.ui.container.Menu
        % EigenvaluesMenu                matlab.ui.container.Menu
        % MomentsMenu                    matlab.ui.container.Menu
        % FigureMenu                     matlab.ui.container.Menu
        % PreferencesMenu                matlab.ui.container.Menu
        % ShiftPatternMenu               matlab.ui.container.Menu
        % equispacedMenu                 matlab.ui.container.Menu
        % randomMenu                     matlab.ui.container.Menu
        % PlottingAttributesMenu         matlab.ui.container.Menu
        % ComputationMenu                matlab.ui.container.Menu
        % LeftPanel                      matlab.ui.container.Panel
        % QuadNodesEditField             matlab.ui.control.NumericEditField
        % QuadNodesEditFieldLabel        matlab.ui.control.Label
        % IMINEditField                  matlab.ui.control.NumericEditField
        % IMINEditFieldLabel             matlab.ui.control.Label
        % RMAXEditField                  matlab.ui.control.NumericEditField
        % RMAXEditFieldLabel             matlab.ui.control.Label
        % RMINEditField                  matlab.ui.control.NumericEditField
        % RMINEditFieldLabel             matlab.ui.control.Label
        % IMAXEditField                  matlab.ui.control.NumericEditField
        % IMAXEditFieldLabel             matlab.ui.control.Label
        % PROBLEMLOADEDTextArea          matlab.ui.control.TextArea
        % PROBLEMLOADEDTextAreaLabel     matlab.ui.control.Label
        % ShiftsButton                   matlab.ui.control.Button
        % ComputeButton                  matlab.ui.control.Button
        % ComputationalModeButtonGroup   matlab.ui.container.ButtonGroup
        % MPLoewnerButton                matlab.ui.control.ToggleButton
        % SPLoewnerButton                matlab.ui.control.ToggleButton
        % HankelButton                   matlab.ui.control.ToggleButton
        % RightPanel                     matlab.ui.container.Panel
        % RightPanelGridLayout           matlab.ui.container.GridLayout
        % ParameterTabGroup              matlab.ui.container.TabGroup
        % NLEVPInformationTab            matlab.ui.container.Tab
        % NLEVPHelpTextArea              matlab.ui.control.TextArea
        % MethodTab                      matlab.ui.container.Tab
        % MethodTabGridLayout            matlab.ui.container.GridLayout
        % MethodDataParameterGridLayout  matlab.ui.container.GridLayout
        % MaxMomentsEditField            matlab.ui.control.NumericEditField
        % MaxMomentsEditFieldLabel       matlab.ui.control.Label
        % EigSearchEditField             matlab.ui.control.NumericEditField
        % EigSearchEditFieldLabel        matlab.ui.control.Label
        % ProbingGridLayout              matlab.ui.container.GridLayout
        % RightProbingSizeEditField      matlab.ui.control.NumericEditField
        % RightProbingSizeEditFieldLabel matlab.ui.control.Label
        % LeftProbingSizeEditField       matlab.ui.control.NumericEditField
        % LeftProbingSizeEditFieldLabel  matlab.ui.control.Label        
        % ContourTab                     matlab.ui.container.Tab
        % ContourTabGridLayout           matlab.ui.container.GridLayout
        % contourparameters              ContourComponentInterface
        % ContourTypeButtonGroup         matlab.ui.container.ButtonGroup
        % RectangleButton                matlab.ui.control.RadioButton
        % EllipseButton                  matlab.ui.control.RadioButton
        % CircleButton                   matlab.ui.control.RadioButton
        % ShiftsTab                      matlab.ui.container.Tab
        % ShiftsTabGridLayout            matlab.ui.container.GridLayout
        % ShiftsTable                    matlab.ui.control.Table
        % EigenvaluesTab                 matlab.ui.container.Tab
        % EigenvaluesTabGridLayout       matlab.ui.container.GridLayout
        % EigenvaluesTable               matlab.ui.control.Table
        % PlotTabGroup                   matlab.ui.container.TabGroup
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    properties (Access = public)
        idxKey
        CIMData     Numerics.CIM
    end
    
    % % GUI Plot Interactions
    % methods (Access = public)
    % 
    %     function recordKey(app,src,event)
    %         app.idxKey = [contains(event.Key,'control'), contains(event.Key,'shift')];
    %         if any(app.idxKey)
    %             set(app.MainPlotAxes.Title,'String','MOD');
    %         end
    %         set(app.UIFigure,'WindowButtonDownFcn',@app.MainPlotAxesWindowButtonDownFcn);
    %         app.MainPlotAxes.Interactions = dataTipInteraction('SnapToDataVertex','on');
    %         app.MainPlotAxes.PickableParts = "all";
    %     end
    % 
    %     function releaseKey(app,src,event)
    %         set(app.MainPlotAxes.Title,'String','NORMAL');
    %         app.idxKey = [false false];
    %         set(app.UIFigure,'WindowButtonDownFcn','');
    %         set(app.UIFigure,'WindowButtonMotionFcn','');
    %         set(app.UIFigure,'WindowButtonUpFcn','');
    %         app.MainPlotAxes.Interactions = [panInteraction('Dimensions','xy') zoomInteraction('Dimensions','xy')];
    %     end
    % 
    %     % this callback will be set when CTRL/SHIFT is pressed
    %     % should allow for axes interactivity when not selected, while
    %     % allowing the user to affect CIM parameters when desired
    %     function MainPlotAxesWindowButtonDownFcn(app,handle,event)
    %         cf = gco(app.UIFigure);
    %         switch(cf.Tag)
    %             case "contour_center"
    %                 set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_center);
    %                 set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_center);
    %             case "contour"
    %                 set(app.UIFigure,'WindowButtonMotionFcn',@app.drag_radius);
    %                 set(app.UIFigure,'WindowButtonUpFcn',@app.set_new_radius);
    %         end
    %     end
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

        % function set_listeners(app)
        %     addlistener(app.MainPlotAxes,'XLim','PostSet',@(src,event)app.MainPlotWindowXLimChangedFcn);
        %     addlistener(app.MainPlotAxes,'YLim','PostSet',@(src,event)app.MainPlotWindowYLimChangedFcn);
        % end

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            % app.UIFigure = uifigure('Visible', 'off','WindowKeyPressFcn',@app.recordKey,'WindowKeyReleaseFcn',@app.releaseKey);
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'on';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'CIMTOOL';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create AppGridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '3x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            app.LeftPanel = uipanel(app.GridLayout);
            app.RightPanel = uipanel(app.GridLayout);

            % Create RightPanelGridLayout
            % This Panel will include the Plot and Parameter Tab Groups
            app.RightPanelGridLayout = uigridlayout(app.RightPanel);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'2x','1x'};

            app.PlotPanel = GUI.PlotPanel(app.RightPanelGridLayout,app,app.CIMData);

            app.ParameterPanel = GUI.ParameterPanel(app.RightPanelGridLayout,app,app.CIMData);

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CIMTOOL

            % all numerics and self-consistency are handled in app.CIM
            app.CIMData = Numerics.CIM(Numerics.NLEVPData(),Contour.Circle());

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