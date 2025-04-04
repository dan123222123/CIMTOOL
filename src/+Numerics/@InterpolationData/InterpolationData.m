classdef InterpolationData < Numerics.VisualReactiveClass & matlab.mixin.Copyable

    properties (SetObservable)
        mode
        theta
        sigma
    end

    methods (Static, Access = public)
        [theta,sigma] = default(mode);
    end

    % TODO
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.mode,obj.m,obj.K,obj.tol);
            cp.InterpolationData = copyElement(obj.InterpolationData);
            cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = InterpolationData(mode,theta,sigma,ax)
            arguments
                mode  = Numerics.ComputationalMode.Hankel
                theta = []
                sigma = []
                ax = []
            end
            obj.mode = mode;
            if nargin < 3
                [obj.theta,obj.sigma] = obj.default(obj.mode);
            else
                obj.theta = theta; obj.sigma = sigma;
            end
            obj.ax = ax;
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
            if ~isempty(obj.sigma)
                switch obj.mode
                    case ComputationalMode.Hankel
                        dn = "SPLoewner Shift";
                    case ComputationalMode.SPLoewner
                        dn = "Right Interpolation Points";
                end
                cphandles(end+1) = scatter(ax,real(obj.sigma),imag(obj.sigma),50,"blue","square","Tag","sigma","DisplayName",dn,'Linewidth',1.5);
            end
            if ~isempty(obj.theta)
                cphandles(end+1) = scatter(ax,real(obj.theta),imag(obj.theta),50,"red","square","Tag","theta","DisplayName","Left Interpolation Points",'Linewidth',1.5);
            end
            hold(ax,"off");
            if update_phandles; obj.phandles = cphandles; end
        end

    end

end