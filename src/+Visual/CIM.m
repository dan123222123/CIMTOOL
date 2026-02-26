classdef CIM < Numerics.CIM & Visual.VisualReactive

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.CIM(obj);
            cp.ax = obj.ax;
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

            % Construct with matching OperatorData/Contour so the constructor's
            % internal SampleData uses the same handles, then immediately replace it.
            % Disable auto-update flags first to prevent update_shifts() from
            % overwriting the InterpolationData already restored in v_rd.
            v = Visual.CIM(v_sd.OperatorData, v_sd.Contour, v_rd, ax);
            v.auto_update_shifts = false;
            v.auto_update_K      = false;

            v.SampleData = v_sd;       % fires updateSampleDataListeners — correct
            v.ResultData = v_result;

            % Copy remaining CIM-level primitives (DataDirtiness, options).
            % auto_update_* are excluded and restored explicitly last.
            Visual.copyMatchingProperties(n, v, ["SampleData","RealizationData","ResultData", ...
                                           "auto_update_shifts","auto_update_K"]);
            v.auto_update_shifts = n.auto_update_shifts;   % restore last
            v.auto_update_K      = n.auto_update_K;
        end
    end

    methods

        function obj = CIM(OperatorData,Contour,RealizationData,ax)
            arguments
                OperatorData = Visual.OperatorData()
                Contour = Visual.Contour.Circle()
                RealizationData = Visual.RealizationData()
                ax = []
            end
            import Visual.*
            obj.SampleData = SampleData(OperatorData,Contour);
            obj.RealizationData = RealizationData;
            obj.ResultData = ResultData();
            obj.ax = ax; obj.update_plot([],[]);
            obj.updateListeners([],[]);
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

            n = Numerics.CIM(n_sd.OperatorData, n_sd.Contour, n_rd);
            n.auto_update_shifts = false;
            n.auto_update_K      = false;

            n.SampleData = n_sd;       % fires updateSampleDataListeners — correct
            n.ResultData = n_result;

            Visual.copyMatchingProperties(obj, n, ["SampleData","RealizationData","ResultData", ...
                                             "auto_update_shifts","auto_update_K"]);
            n.auto_update_shifts = obj.auto_update_shifts;
            n.auto_update_K      = obj.auto_update_K;
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
            catch
                % Ignore errors during cleanup
            end
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax); return; end
            if ~iscell(ax); ax = num2cell(ax); end
            phandles = [phandles obj.SampleData.plot(ax{1})];
            phandles = [phandles obj.RealizationData.plot(ax{1})];
            obj.applyAxesStyle(ax{1});
            phandles = [phandles obj.ResultData.plot(ax)];
        end

        function applyAxesStyle(obj, ax)
            % Apply axes and legend styling from StylePreferences
            if isempty(ax) || ~isgraphics(ax); return; end
            sp = obj.StylePreferences;
            xlabel(ax, sp.AxesXLabelText, 'Interpreter', sp.AxesLabelInterpreter);
            ylabel(ax, sp.AxesYLabelText, 'Interpreter', sp.AxesLabelInterpreter);
            set(ax, 'Color', sp.AxesBackgroundColor);
            grid(ax, sp.AxesGridVisible);
            if strcmpi(sp.AxesGridVisible, 'on')
                set(ax, 'GridLineStyle', sp.AxesGridLineStyle, 'GridColor', sp.AxesGridColor);
            end
            legend(ax, 'Interpreter', sp.LegendInterpreter, ...
                       'Location', sp.LegendLocation, ...
                       'Orientation', sp.LegendOrientation, ...
                       'FontSize', sp.LegendFontSize);
        end

        function attachListeners(obj)
            % Recreate listeners recursively (called when reattaching to new graphics)
            obj.deleteListeners();  % Clear any existing listeners first
            % Visual.CIM inherits from VisualReactive but has no additional listeners
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

        function delete(obj)
            % Only delete if explicitly requested (not called during GUI close)
            try
                if isvalid(obj)
                    % Detach from graphics first
                    obj.detachFromGraphics();

                    % Delete children
                    if ~isempty(obj.SampleData) && isvalid(obj.SampleData)
                        delete(obj.SampleData);
                    end
                    if ~isempty(obj.RealizationData) && isvalid(obj.RealizationData)
                        delete(obj.RealizationData);
                    end
                    if ~isempty(obj.ResultData) && isvalid(obj.ResultData)
                        delete(obj.ResultData);
                    end
                end
            catch
                % Already deleted - ignore
            end
        end
    end
end
