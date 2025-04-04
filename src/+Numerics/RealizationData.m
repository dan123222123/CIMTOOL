classdef RealizationData < Numerics.VisualReactiveClass & matlab.mixin.Copyable

    properties (SetObservable)
        InterpolationData
        RealizationSize
        ranktol
        loaded = false
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.mode,obj.m,obj.K,obj.ranktol);
            cp.InterpolationData = copyElement(obj.InterpolationData);
            cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = RealizationData(mode,rs,ranktol,ax)
            arguments
                mode = Numerics.ComputationalMode.Hankel
                rs = Numerics.RealizationSize()
                ranktol = NaN
                ax = []
            end
            import Numerics.InterpolationData;
            obj.InterpolationData = InterpolationData(mode);
            obj.RealizationSize = rs;
            obj.ranktol = ranktol;
            obj.ax = ax;
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.updateInterpolationDataListeners();
            obj.RealizationDataChanged([],[]);
        end

        function plot(obj,ax,update_phandles)
            arguments
                obj
                ax = gca
                update_phandles = false
            end
            import Numerics.ComputationalMode
            if isempty(ax); return; end
            if update_phandles; obj.cla(); end
            hold(ax,"on");
            cphandles = gobjects(0);
            [theta,sigma] = obj.InterpolationData.getThetaSigma(obj.rs.T1,obj.rs.T2);
            switch obj.mode
                case ComputationalMode.SPLoewner
                    dn = "SPLoewner Shift";
                case ComputationalMode.MPLoewner
                    dn = "Right Interpolation Points";
            end
            if ~isempty(sigma) && obj.mode ~= ComputationalMode.Hankel
                cphandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName",dn,'Linewidth',1.5);
            end
            if ~isempty(theta)
                cphandles(end+1) = scatter(ax,real(theta),imag(theta),50,"red","square","Tag","theta","DisplayName","Left Interpolation Points",'Linewidth',1.5);
            end
            hold(ax,"off");
            if update_phandles; obj.phandles = cphandles; end
        end

        function updateListeners(obj)
            updateRealizationDataListeners(obj);
            updateInterpolationDataListeners(obj);
        end

        function updateRealizationDataListeners(obj)
            addlistener(obj,'RealizationSize','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'ranktol','PostSet',@obj.RealizationDataChanged);
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

        function InterpolationDataChanged(obj,~,~)
            obj.plot(obj.ax,true);
            obj.RealizationDataChanged();
        end

    end

end
