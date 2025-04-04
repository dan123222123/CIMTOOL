classdef RealizationData < matlab.mixin.Copyable

    properties (SetObservable)
        InterpolationData
        K = 0
        m = 0
        ShiftScale = 1.25
        tol = NaN
        loaded = false
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.InterpolationData.theta,obj.InterpolationData.sigma,obj.ComputationalMode,[]);
            cp.K = obj.K; cp.m = obj.m; cp.ShiftScale = obj.ShiftScale; cp.tol = obj.tol; cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = RealizationData(nargin)
            arguments
                mode = Numerics.ComputationalMode.Hankel
                theta = NaN
                sigma = Inf
                ax = []
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma,mode,ax);
            obj.ComputationalMode = mode;
            obj.ax = ax;
            addlistener(obj,'K','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'m','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'ShiftScale','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'tol','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'InterpolationData','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.loaded = false;
        end

        function RealizationDataChanged(obj,~,~)
            obj.loaded = false;
        end

    end

end
