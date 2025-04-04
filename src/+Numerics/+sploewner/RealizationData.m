classdef RealizationData < matlab.mixin.Copyable

    properties (SetObservable)
        InterpolationData
        K
        m
        tol
        loaded = false
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.mode,obj.m,obj.K,obj.tol);
            cp.InterpolationData = copyElement(obj.InterpolationData);
            cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = RealizationData(mode,m,K,tol,ax)
            arguments
                mode = Numerics.ComputationalMode.Hankel
                m = 0
                K = 0
                tol = NaN
                ax = []
            end
            import Numerics.InterpolationData
            obj.K = K;
            obj.m = m;
            obj.tol = tol;
            obj.InterpolationData = InterpolationData(mode,[],[],ax);
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            updateInterpolationDataListeners();
            obj.RealizationDataChanged([],[]);
        end

        function updateListeners(obj)
            updateRealizationDataListeners(obj);
            updateInterpolationDataListeners(obj);
        end

        function updateRealizationDataListeners(obj)
            addlistener(obj,'K','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'m','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'tol','PostSet',@obj.RealizationDataChanged);
        end

        function updateInterpolationDataListeners(obj)
            addlistener(obj,'InterpolationData','PostSet',@obj.RealizationDataChanged);
            addlistener(obj.InterpolationData,'mode','PostSet',@obj.RealizationDataChanged);
            addlistener(obj.InterpolationData,'theta','PostSet',@obj.RealizationDataChanged);
            addlistener(obj.InterpolationData,'sigma','PostSet',@obj.RealizationDataChanged);
        end

        function RealizationDataChanged(obj,~,~)
            obj.loaded = false;
        end

    end

end
