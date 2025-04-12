classdef CIM < Numerics.CIM & Visual.VisualReactive

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.CIM(obj);
            cp.ax = obj.ax;
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
