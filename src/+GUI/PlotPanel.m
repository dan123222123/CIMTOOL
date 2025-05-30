classdef PlotPanel < matlab.ui.componentcontainer.ComponentContainer

    % Component Properties
    properties (Access = public)
        PlotTabGridLayout               matlab.ui.container.GridLayout
        PlotTabGroup                    matlab.ui.container.TabGroup
        %
        MainPlotTab                     matlab.ui.container.Tab
        MainPlotTabGridLayout           matlab.ui.container.GridLayout
        %
        HSVPlotTab                      matlab.ui.container.Tab
        HSVPlotTabGridLayout            matlab.ui.container.GridLayout
        %
        ResultTab                       matlab.ui.container.Tab
        ResultTabGridLayout             matlab.ui.container.GridLayout
        ResultsTable                    matlab.ui.control.Table
    end

    properties (Access = public, SetObservable)
        MainPlotAxes                    matlab.ui.control.UIAxes
        HSVAxes                         matlab.ui.control.UIAxes
    end

    properties (Access = public)
        MainAppUIFigure
        MainApp % app that contains this component, set in constructor
        CIMData Numerics.CIM % underlying computational structure that this component will modify
    end

    methods (Access=public)

        function obj = PlotPanel(Parent,MainApp,MainAppUIFigure,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)

            obj.MainApp = MainApp;
            obj.MainAppUIFigure = MainAppUIFigure;
            obj.CIMData = CIMData;

            obj.CIMData.ax = {obj.MainPlotAxes,obj.HSVAxes};

            addlistener(obj.CIMData.SampleData.OperatorData,'refew','PostSet',@(src,event)obj.ResultDataChangedFcn);
            % addlistener(obj.CIMData.ResultData,'rev','PostSet',@(src,event)obj.ResultDataChangedFcn);
            % addlistener(obj.CIMData.SampleData.Contour,'z','PostSet',@(src,event)obj.ResultDataChangedFcn);

            addlistener(obj.CIMData.RealizationData,'loaded','PostSet',@(src,event)obj.ResultDataChangedFcn);

            addlistener(obj.MainApp,'FontSize','PostSet',@(src,event)obj.updateFontSize);

            obj.ResultDataChangedFcn(0);

        end

        function updateFontSize(comp,~)
            update = comp.MainApp.FontSize;
            fontsize(comp.PlotTabGridLayout.Children,update,"points");
            % comp.ContourTab.updateFontSize(update);
            % comp.MethodTab.updateFontSize(update);
            % comp.ShiftsTab.updateFontSize(update);
        end

        % listen for rd.loaded, OperatorData.refew, etc. to re-do this table display
        function ResultDataChangedFcn(comp,~)

            rd = comp.CIMData.ResultData;
            nd = comp.CIMData.SampleData.OperatorData;

            ew = rd.ew; ev = rd.rev;
            T = nd.T; refew = reshape(nd.refew,[length(nd.refew) 1]);

            % if reference is present, show it
            % we have contour information, so we can use it to try and
            % prune extra reference eigenvalues from the table view at
            % least
            if ~all(ismissing(refew))
                % sort reference eigenvalues by magnitude, only those
                % inside the contour
                refew = refew(comp.CIMData.SampleData.Contour.inside(refew));
                [~,refewidx] = sort(abs(refew)); refew = refew(refewidx);
                nin = length(refew); cstr = sprintf('Ref. EW (# Inside Contour %d)',nin);
            else
                refew = repelem(NaN,length(ew))';
                cstr = ('Ref. EW');
            end
            comp.ResultsTable.ColumnName = {cstr,'Comp. EW','Rel. Res.'};

            % after updating the table, there is no point going farther if
            % the ResultData is not ready to be updated
            % if ~comp.CIMData.ResultData.loaded
            %     return
            % end

            m = max([length(refew),length(ew)]);

            % if computed eigenvalues are available, show them and the
            % relative residual (assuming ev are also available)
            if comp.CIMData.RealizationData.loaded && ~all(ismissing(ew))
                if ~all(isnan(refew)) % greedy matching between comp and ref if ref is available
                    cew = ew; cev = ev;
                    new = zeros(size(cew)); nev = zeros(size(cev));
                    % greedily match as many ew/ev as we can to reference
                    for i=1:min(length(refew),length(ew))
                        mdist = Inf; midx = -1;
                        for j=1:length(cew)
                            if norm(refew(i)-cew(j)) < mdist
                                mdist = norm(refew(i)-cew(j)); midx = j;
                            end
                        end
                        new(i) = cew(midx); nev(:,i) = cev(:,midx);
                        cew(midx) = []; cev(:,midx) = [];
                    end
                    % now append any remaining ew/ev
                    [cew,cewI] = sort(cew); cev = cev(:,cewI);
                    new(min(length(refew),length(ew))+1:end) = cew;
                    nev(:,min(length(refew),length(ew))+1:end) = cev;
                    ew = new; ev = nev;
                else % dumb sort
                    refew = repelem(NaN,m)';
                    [ew,ewI] = sort(ew); ev = ev(:,ewI);
                end
                rr = Numerics.relres(T,ew,ev,nd.sample_mode);
            else
                ew = repelem(NaN,m)';
                rr = repelem(NaN,m)';
            end
            
            % pad out all arrays to match the length of the longest list
            refew = padarray(refew,m-length(refew),NaN,'post');
            ew = padarray(ew,m-length(ew),NaN,'post');
            rr = padarray(rr,m-length(rr),NaN,'post');

            % make the final table
            comp.ResultsTable.Data = [refew(1:m),ew(1:m),rr(1:m)];
            comp.ResultsTable.ColumnFormat = {'long','long','longE'};

        end

    end

    methods (Access=protected)       
        
        % executes when the value of a public property is changed
        % basically, just make sure the axes are still the active ones
        function update(comp)
            comp.CIMData.ax = {comp.MainPlotAxes,comp.HSVAxes};
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
            legend(comp.MainPlotAxes,Location="southoutside",Orientation="horizontal");
            hold(comp.MainPlotAxes,"on"); % easier to set hold on here
        
            % Create HSVAxes
            comp.HSVAxes = uiaxes(comp.HSVPlotTab);
            comp.HSVAxes.Layer = 'top';
            comp.HSVAxes.XGrid = 'on';
            comp.HSVAxes.XMinorGrid = 'on';
            comp.HSVAxes.YGrid = 'on';
            comp.HSVAxes.YMinorGrid = 'on';
            comp.HSVAxes.YScale = 'log';
            legend(comp.HSVAxes,Location="southoutside",Orientation="horizontal");

            comp.ResultTab = uitab(comp.PlotTabGroup);
            comp.ResultTab.Title = 'Numerical Results';

            comp.ResultTabGridLayout = uigridlayout(comp.ResultTab,[1,1]);
            comp.ResultTabGridLayout.Padding = [10 10 10 10];

            % table of numerical results
            comp.ResultsTable = uitable(comp.ResultTabGridLayout);
            comp.ResultsTable.RowName = {};

        end

    end

end