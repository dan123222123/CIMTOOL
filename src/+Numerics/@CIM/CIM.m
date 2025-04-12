classdef CIM < matlab.mixin.Copyable

    properties (Access = public)
        SampleData          Numerics.SampleData
        RealizationData     Numerics.RealizationData
        ResultData          Numerics.ResultData
    end

    properties (SetObservable)
        DataDirtiness = 2
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
            cp = eval(class(obj));
            cp.auto = obj.auto;
            cp.auto_compute_samples = obj.auto_compute_samples;
            cp.auto_compute_realization = obj.auto_compute_realization;
            cp.auto_estimate_m = obj.auto_estimate_m;
            cp.auto_update_shifts = obj.auto_update_shifts;
            cp.auto_update_K = obj.auto_update_K;
            %
            cp.SampleData = copy(obj.SampleData);
            cp.updateSampleDataListeners([],[]);
            cp.RealizationData = copy(obj.RealizationData);
            cp.updateRealizationDataListeners([],[]);
            cp.ResultData = copy(obj.ResultData);
            %
            cp.DataDirtiness = obj.DataDirtiness;
        end
    end

    methods (Access = public)
        interlevedshifts(obj);
        computeRealization(obj);
        refineQuadrature(obj);
    end

    methods

        function obj = CIM(OperatorData,Contour,RealizationData)
            arguments
                OperatorData = Numerics.OperatorData()
                Contour = Numerics.Contour.Circle()
                RealizationData = Numerics.RealizationData()
            end
            obj.SampleData = Numerics.SampleData(OperatorData,Contour,0,0);
            obj.RealizationData = RealizationData;
            obj.ResultData = Numerics.ResultData();
            obj.updateListeners([],[]);
        end

        function setComputationalMode(obj,cm)
            if obj.RealizationData.ComputationalMode == cm
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    odms = min(obj.SampleData.ell,obj.SampleData.r)*obj.RealizationData.K;
                case Numerics.ComputationalMode.MPLoewner
                    odms = obj.RealizationData.K;
            end
            obj.RealizationData.ComputationalMode = cm;
            if obj.auto_update_K && min(obj.SampleData.ell,obj.SampleData.r) ~= 0
                switch cm
                    case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                        obj.default_shifts();
                        K = ceil(odms/min(obj.SampleData.ell,obj.SampleData.r));
                    case Numerics.ComputationalMode.MPLoewner
                        K = odms;
                end
                obj.RealizationData.RealizationSize = Numerics.RealizationSize(obj.RealizationData.RealizationSize.m,K,K);
            end
        end

        function updateContourListeners(obj,~,~)
            addlistener(obj.SampleData.Contour,'z','PostSet',@obj.update_shifts);
            obj.update_shifts([],[]);
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
            obj.updateContourListeners([],[]);
        end

        function updateListeners(obj,~,~)
            obj.updateSampleDataListeners([],[]);
            obj.updateRealizationDataListeners([],[]);
        end

        function default_shifts(obj)
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.SPLoewner
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,obj.SampleData.Contour.FindRandomShift());
                case Numerics.ComputationalMode.MPLoewner
                    obj.contour_interlevedshifts();
            end
        end

        function update_shifts(obj,src,~)
            if ~obj.auto_update_shifts
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.MPLoewner
                    obj.contour_interlevedshifts();
            end
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

        function [Db,Ds] = getFullDataMatrices(obj)
            obj.compute();
            Db = obj.ResultData.Db;
            Ds = obj.ResultData.Ds;
        end

        function [V, D, W] = eigs(obj)
            obj.compute();
            [~,ewidx] = sort(abs(obj.ResultData.ew));
            if nargout <= 1
                V = obj.ResultData.ew(ewidx);
            elseif nargout >= 2
                V = obj.ResultData.rev(:,ewidx);
                D = diag(obj.ResultData.ew(ewidx));
                W = obj.ResultData.lev(ewidx,:)';
            end
        end

        function H = tf(obj,m,abstol)
            arguments
                obj
                m = obj.RealizationData.RealizationSize.m
                abstol = NaN
            end
            cp = copy(obj);
            cp.compute();
            [Lambda,V,W] = Numerics.tf_dbsvd(m, ...
                cp.ResultData.X, ...
                cp.ResultData.Sigma, ...
                cp.ResultData.Y, ...
                cp.ResultData.Ds, ...
                cp.ResultData.BB, ...
                cp.ResultData.CC, ...
                abstol ...
                );
            H = @(z) V*((Lambda-z*eye(size(Lambda)))\W);
        end

    end
end
