classdef CIM < Numerics.CIM & Visual.VisualReactive

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.CIM(obj);
            cp.ax = obj.ax;
        end
    end

    methods

        function obj = CIM(nep,contour,ax)
            arguments
                nep = []
                contour = []
                ax = []
            end
            import Visual.*
            obj.SampleData = SampleData(nep,contour,0,0,MainAx);
            obj.RealizationData = Numerics.RealizationData(Numerics.ComputationalMode.Hankel,[],[],NaN,MainAx);
            obj.ResultData = Numerics.ResultData(MainAx,SvAx);
            obj.MainAx = MainAx;
            obj.SvAx = SvAx;
            obj.update_plot([],[]);
            obj.updateListeners([],[]);
        end

        function plot(obj,ax)
            arguments
                obj
                ax = gca
            end

            ew = obj.ResultData.ew; refew = obj.SampleData.NLEVPData.refew;

            if ~isempty(refew)
                scatter(ax,real(refew),imag(refew),50,"diamond","MarkerEdgeColor","#E66100","LineWidth",1.5,"DisplayName","$\lambda$"); hold on;
            end
            if ~isempty(ew)
                scatter(ax,real(ew),imag(ew),15,"MarkerFaceColor","#1AFF1A",'DisplayName',"$\hat{\lambda}$"); hold on;
            end
            obj.SampleData.Contour.plot(ax); hold on;
            obj.RealizationData.plot(ax); hold on;
            grid;
            title(sprintf("Complex Plane (%d reference eigenvalues inside contour)",obj.RealizationData.m));
            xlabel("$\bf{R}$",'Interpreter','latex'); ylabel("$i\bf{R}$",'Interpreter','latex');
            legend('Interpreter','latex','Location','northoutside','Orientation','horizontal')
            hold off

        end

        function checkdirty(obj,~,~)
            if ~obj.SampleData.loaded
                obj.DataDirtiness = 2;
                if obj.auto_compute_samples
                    obj.SampleData.compute();
                    obj.checkdirty([],[]);
                end
            elseif ~obj.RealizationData.loaded
                obj.DataDirtiness = 1;
                if obj.auto_compute_realization
                    obj.computeRealization();
                    obj.checkdirty([],[]);
                end
            else
                obj.DataDirtiness = 0;
            end
        end

        function compute(obj)
            obj.SampleData.compute();
            obj.computeRealization();
        end

        function [Db,Ds] = getData(obj)
            Db = obj.ResultData.Db;
            Ds = obj.ResultData.Ds;
        end

    end
end
