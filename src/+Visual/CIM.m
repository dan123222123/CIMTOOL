classdef CIM < Numerics.CIM & Visual.VisualReactive

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.CIM(obj);
            cp.ax = obj.ax;
        end

        function reattachListeners(obj)
            reattachListeners@Numerics.CIM(obj);
            obj.forgetGraphics();
            obj.addPlotListeners();
        end
    end

    methods (Access = private)
        function addPlotListeners(obj)
            obj.deleteListeners();
            obj.listeners = obj.partListeners(["SampleData","RealizationData","ResultData"]);
        end
    end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.CIM from a Numerics.CIM.
            %
            % Converts all sub-components to their Visual counterparts and
            % preserves already-computed sample and result state so that no
            % recomputation is needed after conversion.
            %
            % Usage:
            %   v = Visual.CIM.fromNumerics(n);          % no axes
            %   v = Visual.CIM.fromNumerics(n, ax);      % attach to axes
            arguments
                n Numerics.CIM
                ax = []
            end
            v_sd     = Visual.SampleData.fromNumerics(n.SampleData, ax);
            v_rd     = Visual.RealizationData.fromNumerics(n.RealizationData, ax);
            v_result = Visual.ResultData.fromNumerics(n.ResultData, ax);

            % Construct with defaults and turn the auto updates off before
            % assigning the converted parts, so update_shifts() cannot replace
            % their shifts or loaded flags; the assignments re-wire the listeners.
            v = Visual.CIM();
            v.auto_update_shifts = false;
            v.auto_update_K      = false;
            v.options = n.options;   % before RealizationData: an options change marks the realization stale
            v.SampleData = v_sd;
            v.RealizationData = v_rd;
            v.ResultData = v_result;
            v.RealizationData.loaded = n.RealizationData.loaded;   % replacing the parts marked it stale

            % Copy any remaining CIM-level properties; DataDirtiness is derived below.
            Visual.copyMatchingProperties(n, v, ["SampleData","RealizationData","ResultData", ...
                                           "auto_update_shifts","auto_update_K","options","DataDirtiness"]);
            v.auto_update_shifts = n.auto_update_shifts;   % restore last
            v.auto_update_K      = n.auto_update_K;
            v.checkdirty([],[]);
            v.ax = ax;
        end
    end

    methods

        function obj = CIM(OperatorData,Contour,RealizationData,ax)
            arguments
                OperatorData = Visual.OperatorData()
                Contour = Visual.Contour.Quad.empty
                RealizationData = Visual.RealizationData()
                ax = []
            end
            import Visual.*
            obj.SampleData = SampleData(OperatorData,Contour);
            obj.RealizationData = RealizationData;
            obj.ResultData = ResultData();
            obj.ax = ax; obj.update_plot([],[]);
            obj.updateListeners([],[]);
            obj.addPlotListeners();
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.CIM.
            %
            % The returned object preserves all computed sample data and results
            % so no recomputation is needed. Suitable for use in parfor or other
            % contexts where graphics handles must not be present.
            n_sd     = obj.SampleData.toNumerics();
            n_rd     = obj.RealizationData.toNumerics();
            n_result = obj.ResultData.toNumerics();

            % as in fromNumerics: defaults, auto updates off, options, then the converted parts
            n = Numerics.CIM();
            n.auto_update_shifts = false;
            n.auto_update_K      = false;
            n.options = obj.options;
            n.SampleData = n_sd;
            n.RealizationData = n_rd;
            n.ResultData = n_result;
            n.RealizationData.loaded = obj.RealizationData.loaded;   % replacing the parts marked it stale

            Visual.copyMatchingProperties(obj, n, ["SampleData","RealizationData","ResultData", ...
                                             "auto_update_shifts","auto_update_K","options","DataDirtiness"]);
            n.auto_update_shifts = obj.auto_update_shifts;
            n.auto_update_K      = obj.auto_update_K;
            n.checkdirty([],[]);
        end

        function update_plot(obj,~,~)
            % Skip if object or children are invalid
            try
                if ~isvalid(obj)
                    return;
                end
                obj.cla();

                ax = obj.ax;
                if isempty(ax)
                    ax = {[]};
                elseif ~iscell(ax)
                    ax = num2cell(ax);
                end

                % Propagate StylePreferences to all child components
                if ~isempty(obj.SampleData) && isvalid(obj.SampleData)
                    obj.SampleData.StylePreferences = obj.StylePreferences;
                    obj.SampleData.ax = ax{1};
                end
                if ~isempty(obj.RealizationData) && isvalid(obj.RealizationData)
                    obj.RealizationData.StylePreferences = obj.StylePreferences;
                    obj.RealizationData.ax = ax{1};
                end
                if ~isempty(obj.ResultData) && isvalid(obj.ResultData)
                    obj.ResultData.StylePreferences = obj.StylePreferences;
                    obj.ResultData.ax = ax;
                end

                obj.phandles = [obj.SampleData.phandles obj.RealizationData.phandles obj.ResultData.phandles];

                % Apply axes/legend styling at the CIM level
                if ~isempty(ax) && ~isempty(ax{1}) && isgraphics(ax{1})
                    obj.applyAxesStyle(ax{1});
                end
                if length(ax) >= 2 && ~isempty(ax{2}) && isgraphics(ax{2})
                    obj.applyAxesStyle(ax{2}, false, true);
                end
            catch
                % Ignore errors during cleanup
            end
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = Visual.emptyHandles();
            if isempty(ax); return; end
            if ~iscell(ax); ax = num2cell(ax); end
            phandles = [phandles obj.SampleData.plot(ax{1})];
            phandles = [phandles obj.RealizationData.plot(ax{1})];
            obj.applyAxesStyle(ax{1});
            if length(ax) >= 2 && ~isempty(ax{2}) && isgraphics(ax{2})
                obj.applyAxesStyle(ax{2}, false, true);
            end
            phandles = [phandles obj.ResultData.plot(ax)];
        end

        function applyAxesStyle(obj, ax, applyLabels, forceGrid)
            % Apply axes and legend styling from StylePreferences
            %   applyLabels - if false, skip axis labels (for non-complex-plane axes)
            %   forceGrid   - if true, grid is always on (for log-scale axes)
            arguments
                obj
                ax
                applyLabels logical = true
                forceGrid   logical = false
            end
            if isempty(ax) || ~isgraphics(ax); return; end
            sp = obj.StylePreferences;
            if applyLabels
                xlabel(ax, sp.AxesXLabelText, 'Interpreter', sp.AxesLabelInterpreter);
                ylabel(ax, sp.AxesYLabelText, 'Interpreter', sp.AxesLabelInterpreter);
            end
            set(ax, 'Color', sp.AxesBackgroundColor);
            if forceGrid
                set(ax, 'XGrid', 'on', 'YGrid', 'on', ...
                        'XMinorGrid', 'on', 'YMinorGrid', 'on', ...
                        'MinorGridAlpha', 0.5);
            else
                grid(ax, sp.AxesGridVisible);
            end
            if forceGrid || strcmpi(sp.AxesGridVisible, 'on')
                set(ax, 'GridLineStyle', sp.AxesGridLineStyle, 'GridColor', sp.AxesGridColor);
            end
            legend(ax, 'Interpreter', sp.LegendInterpreter, ...
                       'Location', sp.LegendLocation, ...
                       'Orientation', sp.LegendOrientation, ...
                       'FontSize', sp.LegendFontSize);
        end

        function attachListeners(obj)
            % Recreate listeners recursively (called when reattaching to new graphics)
            obj.addPlotListeners();
            % Attach listeners on children
            try
                if ~isempty(obj.SampleData) && isvalid(obj.SampleData)
                    obj.SampleData.attachListeners();
                end
                if ~isempty(obj.RealizationData) && isvalid(obj.RealizationData)
                    obj.RealizationData.attachListeners();
                end
                if ~isempty(obj.ResultData) && isvalid(obj.ResultData)
                    obj.ResultData.attachListeners();
                end
            catch
                % Ignore errors
            end
        end

        function detachFromGraphics(obj)
            % Detach from graphics and remove all listeners recursively
            % This allows the object to be reused later with a new GUI
            try
                % Detach children first
                if ~isempty(obj.SampleData) && isvalid(obj.SampleData)
                    obj.SampleData.detachFromGraphics();
                end
                if ~isempty(obj.RealizationData) && isvalid(obj.RealizationData)
                    obj.RealizationData.detachFromGraphics();
                end
                if ~isempty(obj.ResultData) && isvalid(obj.ResultData)
                    obj.ResultData.detachFromGraphics();
                end

                % Call parent detach
                detachFromGraphics@Visual.VisualReactive(obj);
            catch
                % Ignore errors during cleanup
            end
        end

    end
end
