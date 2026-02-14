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
            ax = obj.ax;
            if isempty(ax)
                ax = {[]};
            elseif ~iscell(ax)
                ax = num2cell(ax);
            end
            obj.SampleData.ax = ax{1};
            obj.RealizationData.ax = ax{1};
            obj.ResultData.ax = ax;
            obj.phandles = [obj.SampleData.phandles obj.RealizationData.phandles obj.ResultData.phandles];
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
            %
            xlabel(ax{1},"$\bf{R}$",'Interpreter','latex');
            ylabel(ax{1},"$i\bf{R}$",'Interpreter','latex');
            legend(ax{1},'Interpreter','latex','Location','northoutside','Orientation','horizontal');
            phandles = [phandles obj.ResultData.plot(ax)];
        end
    end
end
