classdef RealizationData < matlab.mixin.Copyable

    properties (SetObservable)
        ComputationalMode
        InterpolationData
        RealizationSize
        ranktol
        auto_update_realization_size = true
        loaded = false
    end

    properties (Dependent)
        K
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = eval(class(obj));
            cp.ComputationalMode = obj.ComputationalMode;
            cp.InterpolationData = obj.InterpolationData;
            cp.RealizationSize = obj.RealizationSize;
            cp.ranktol = obj.ranktol;
            cp.auto_update_realization_size = obj.auto_update_realization_size;
            cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = RealizationData(ComputationalMode,InterpolationData,RealizationSize,ranktol)
            arguments
                ComputationalMode = Numerics.ComputationalMode.Hankel
                InterpolationData = []
                RealizationSize = []
                ranktol = NaN
            end
            obj.ComputationalMode = ComputationalMode;
            if isempty(InterpolationData)
                obj.defaultInterpolationData();
            end
            m = max(length(obj.InterpolationData.theta),length(obj.InterpolationData.sigma));
            if isempty(RealizationSize)
                obj.RealizationSize = Numerics.RealizationSize(m,m,m);
            end
            obj.ranktol = ranktol;
            obj.updateListeners();
            obj.RealizationDataChanged();
        end

        function value = get.K(obj)
            value = max(obj.RealizationSize.T1,obj.RealizationSize.T2);
        end

        function set.ComputationalMode(obj,value)
            obj.ComputationalMode = value;
            obj.defaultInterpolationData();
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.InterpolationDataChanged([],[]);
        end

        function set.ranktol(obj,value)
            obj.ranktol = value;
            obj.loaded = false;
        end

        function defaultInterpolationData(obj)
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    theta = []; sigma = Inf;
                case Numerics.ComputationalMode.SPLoewner
                    theta = []; sigma = 0;
                case Numerics.ComputationalMode.MPLoewner
                    theta = []; sigma = [];
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma);
        end

        function [theta,sigma] = getThetaSigma(obj,T1,T2)
            arguments
                obj
                T1 = length(obj.InterpolationData.theta)
                T2 = length(obj.InterpolationData.sigma)
            end
            theta = obj.InterpolationData.theta;
            sigma = obj.InterpolationData.sigma;
            if obj.ComputationalMode == Numerics.ComputationalMode.MPLoewner
                theta = theta(1:T1); sigma = sigma(1:T2);
            end
        end

        function updateListeners(obj)
            addlistener(obj,'RealizationSize','PostSet',@obj.RealizationDataChanged);
        end
        
        function RealizationDataChanged(obj,~,~)
            obj.loaded = false;
        end

        function InterpolationDataChanged(obj,~,~)
            if ~isempty(obj.RealizationSize) && obj.auto_update_realization_size
                obj.RealizationSize = Numerics.RealizationSize(obj.RealizationSize.m,length(obj.InterpolationData.theta),length(obj.InterpolationData.sigma));
            end
            obj.RealizationDataChanged([],[]);
        end

    end

end
