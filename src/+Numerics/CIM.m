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
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.CIM(copy(obj.SampleData.NLEVP),copy(obj.SampleData.Contour),[],[]);
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
            obj.RealizationData = Numerics.RealizationData(NaN,Inf,Numerics.ComputationalMode.Hankel,MainAx);
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

        function updateNLEVPListeners(obj,~,~)
            addlistener(obj.SampleData.NLEVP,'loaded','PostSet',@obj.NLEVPChanged);
        end

        function updateRealizationDataListeners(obj,~,~)
            addlistener(obj.RealizationData,'loaded','PostSet',@obj.checkdirty);
            addlistener(obj.RealizationData,'ComputationalMode','PostSet',@obj.update_shifts);
            addlistener(obj.RealizationData,'ShiftScale','PostSet',@obj.update_shifts);
            addlistener(obj.RealizationData,'K','PostSet',@obj.update_shifts);
            obj.update_shifts([],[]);
        end

        function updateSampleDataListeners(obj,~,~)
            addlistener(obj.SampleData,'loaded','PostSet',@obj.checkdirty);
            addlistener(obj.SampleData,'Contour','PostSet',@obj.updateContourListeners);
            addlistener(obj.SampleData,'NLEVP','PostSet',@obj.updateNLEVPListeners);
            obj.updateNLEVPListeners([],[]); obj.updateContourListeners([],[]);
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
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,Inf);
                case Numerics.ComputationalMode.SPLoewner
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,obj.SampleData.Contour.FindRandomShift(obj.RealizationData.ShiftScale));
                case Numerics.ComputationalMode.MPLoewner
                    obj.interlevedshifts();
            end
        end

        function NLEVPChanged(obj,~,~)
            if obj.SampleData.NLEVP.loaded
                obj.ResultData.ew = [];
                obj.ResultData.ev = [];
                obj.ResultData.Db = [];
                obj.ResultData.Ds = [];
            end
        end

        % using the underlying quadrature
        % determine the geometric center and the maximum distance
        % between the center and a quadrature node.
        % then scale that distance and interleve the nodes on a
        % circle with geo center and max_dist*scale
        function interlevedshifts(obj)
            nsw = obj.RealizationData.K;
            d = obj.RealizationData.ShiftScale;
            [theta,sigma] = obj.SampleData.Contour.interlevedshifts(nsw,d);
            obj.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
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

            ew = obj.ResultData.ew; refew = obj.SampleData.NLEVP.refew;

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

        function computeRealization(obj)
            obj.ResultData.loaded = false;
            switch(obj.RealizationData.ComputationalMode)
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    [obj.ResultData.ew,obj.ResultData.rev,obj.ResultData.lev,obj.ResultData.Db,obj.ResultData.Ds,obj.ResultData.B,obj.ResultData.C,obj.ResultData.X,obj.ResultData.Sigma,obj.ResultData.Y] = Numerics.sploewner( ...
                        obj.SampleData.Contour.z, ...
                        obj.SampleData.Contour.w, ...
                        obj.SampleData.Qlr, ...
                        obj.SampleData.Ql, ...
                        obj.SampleData.Qr, ...
                        obj.RealizationData.InterpolationData.sigma(1), ...
                        obj.RealizationData.m, ...
                        obj.RealizationData.K, ...
                        obj.RealizationData.tol ...
                    );
                case Numerics.ComputationalMode.MPLoewner
                    [obj.ResultData.ew,obj.ResultData.rev,obj.ResultData.lev,obj.ResultData.Db,obj.ResultData.Ds,obj.ResultData.B,obj.ResultData.C,obj.ResultData.X,obj.ResultData.Sigma,obj.ResultData.Y] = Numerics.mploewner( ...
                        obj.SampleData.Contour.z, ...
                        obj.SampleData.Contour.w, ...
                        obj.SampleData.Ql, ...
                        obj.SampleData.Qr, ...
                        obj.SampleData.L, ...
                        obj.SampleData.R, ...
                        obj.RealizationData.InterpolationData.theta, ...
                        obj.RealizationData.InterpolationData.sigma, ...
                        obj.RealizationData.m, ...
                        obj.RealizationData.tol ...
                    );
            end
            obj.RealizationData.loaded = true;
            obj.ResultData.ComputationalMode = obj.RealizationData.ComputationalMode;
            obj.ResultData.loaded = true;
        end

        function compute(obj)
            obj.SampleData.compute();
            obj.computeRealization();
        end

        function refineQuadrature(obj)
            % old auto values -- we set them back at the end
            acs = obj.auto_compute_samples; acr = obj.auto_compute_realization; aem = obj.auto_estimate_m; aus = obj.auto_update_shifts;
            obj.auto_compute_samples = false; obj.auto_compute_realization = false; obj.auto_estimate_m = false; obj.auto_update_shifts = false;

            % refine the quadrature and compute
            try
                obj.SampleData.refineQuadrature();
                obj.compute();
                obj.auto_compute_samples = acs; obj.auto_compute_realization = acr; obj.auto_estimate_m = aem; obj.auto_update_shifts = aus;
            catch e
                obj.auto_compute_samples = acs; obj.auto_compute_realization = acr; obj.auto_estimate_m = aem; obj.auto_update_shifts = aus;
                rethrow(e);
            end
        end

        function [Db,Ds] = getData(obj)
            Db = obj.ResultData.Db;
            Ds = obj.ResultData.Ds;
        end

    end
end
