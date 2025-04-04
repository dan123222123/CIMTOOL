classdef InterpolationData < matlab.mixin.Copyable

    properties (SetObservable)
        mode
        theta
        sigma
    end

    methods (Static, Access = public)
        function default(obj)
            mode = obj.mode;
            import Numerics.ComputationalMode;
            switch mode
                case ComputationalMode.Hankel
                    obj.theta = []; obj.sigma = Inf;
                case ComputationalMode.SPLoewner
                    obj.theta = []; obj.sigma = 0;
                case ComputationalMode.MPLoewner
                    obj.theta = []; obj.sigma = [];
            end
        end
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.InterpolationData(obj.mode,obj.theta,obj.sigma);
        end
    end

    methods

        function obj = InterpolationData(mode,theta,sigma)
            arguments
                mode  = Numerics.ComputationalMode.Hankel
                theta = []
                sigma = []
            end
            obj.mode = mode;
            if nargin < 3
                obj.default();
            else
                obj.theta = theta; obj.sigma = sigma;
            end
        end

        function [theta,sigma] = getThetaSigma(obj,T1,T2)
            arguments
                obj
                T1 = length(obj.theta)
                T2 = length(obj.sigma)
            end
            theta = obj.theta; sigma = obj.sigma;
            import Numerics.ComputationalMode
            if obj.mode == ComputationalMode.MPLoewner
                theta = theta(1:T1); sigma = sigma(1:T2);
            end
        end

    end

end