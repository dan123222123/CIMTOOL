classdef CIM < matlab.mixin.Copyable
    % Docstring of CIM class.

    properties (Access = public)
        SampleData          Numerics.SampleData
        RealizationData     Numerics.RealizationData
        ResultData          Numerics.ResultData
    end

    properties (SetObservable)
        DataDirtiness = 2
        MainAx = []
        SvAx = []
        auto = false;
        auto_compute_samples = false;
        auto_compute_realization = false;
        auto_estimate_m = false;
        auto_update_shifts = true;
        auto_update_K = true;
        options = struct("PadStrategy","cyclical","AbsTol",NaN,"Verbose",true);
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.CIM(copy(obj.SampleData.NLEVPData),copy(obj.SampleData.Contour),[],[]);
            cp.auto = obj.auto; cp.auto_compute_samples = obj.auto_compute_samples;
            cp.auto_compute_realization = obj.auto_compute_realization;
            cp.auto_estimate_m = obj.auto_estimate_m;
            cp.auto_update_shifts = obj.auto_update_shifts;
            cp.auto_update_K = obj.auto_update_K;
            %
            cp.SampleData = copy(obj.SampleData);
            cp.updateSampleDataListeners([],[]);
            cp.RealizationData = copy(obj.RealizationData);
            cp.updateRealizationDataListeners([],[]);
        end
    end

    methods (Access = public)
        interlevedshifts(obj);
        computeRealization(obj);
        refineQuadrature(obj);
    end

    methods

        function obj = CIM(nep,contour,MainAx,SvAx)
            arguments
                nep
                contour
                MainAx = []
                SvAx = []
            end
            obj.SampleData = Numerics.SampleData(nep,contour,0,0,MainAx);
            % default to Hankel realization
            obj.RealizationData = Numerics.RealizationData(Numerics.ComputationalMode.Hankel,[],[],NaN,MainAx);
            obj.ResultData = Numerics.ResultData(MainAx,SvAx);
            obj.MainAx = MainAx;
            obj.SvAx = SvAx;
            obj.update_plot([],[]);
            obj.updateListeners([],[]);

        end

        function updateContourListeners(obj,~,~)
            addlistener(obj.SampleData.Contour,'z','PostSet',@obj.update_shifts);
            obj.update_shifts([],[]);
        end

        function updateNLEVPDataListeners(obj,~,~)
            addlistener(obj.SampleData.NLEVPData,'loaded','PostSet',@obj.NLEVPDataChanged);
        end

        function updateRealizationDataListeners(obj,~,~)
            addlistener(obj.RealizationData,'loaded','PostSet',@obj.checkdirty);
            addlistener(obj.RealizationData,'ComputationalMode','PostSet',@obj.update_shifts);
            addlistener(obj.RealizationData,'RealizationSize','PostSet',@obj.update_shifts);
            obj.update_shifts([],[]);
        end

        function updateSampleDataListeners(obj,~,~)
            addlistener(obj.SampleData,'loaded','PostSet',@obj.checkdirty);
            addlistener(obj.SampleData,'Contour','PostSet',@obj.updateContourListeners);
            addlistener(obj.SampleData,'NLEVPData','PostSet',@obj.updateNLEVPDataListeners);
            obj.updateNLEVPDataListeners([],[]); obj.updateContourListeners([],[]);
        end

        function updateListeners(obj,~,~)
            addlistener(obj,'MainAx','PostSet',@obj.update_plot);
            obj.updateSampleDataListeners([],[]);
            obj.updateRealizationDataListeners([],[]);
        end

        function update_shifts(obj,src,~)
            if (isempty(src) || src.Name == "z" || src.Name == "K") && ~obj.auto_update_shifts
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    obj.RealizationData.defaultInterpolationData();
                case Numerics.ComputationalMode.SPLoewner
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData([],obj.SampleData.Contour.FindRandomShift());
                case Numerics.ComputationalMode.MPLoewner
                    obj.contour_interlevedshifts();
            end
        end

        function NLEVPDataChanged(obj,~,~)
            if obj.SampleData.NLEVPData.loaded
                obj.ResultData.ew = [];
                obj.ResultData.ev = [];
                obj.ResultData.Db = [];
                obj.ResultData.Ds = [];
            end
        end

        function update_plot(obj,~,~)
            if ~isempty(obj.MainAx)
                ax = obj.MainAx; hold(ax,"on");
                obj.SampleData.ax = ax; hold(ax,"on");
                obj.RealizationData.ax = ax; hold(ax,"on");
                obj.ResultData.MainAx = ax; hold(ax,"off");
            end

            if ~isempty(obj.SvAx)
                ax = obj.SvAx; hold(ax,"on");
                obj.ResultData.SvAx = ax; hold(ax,"off");
            end
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
