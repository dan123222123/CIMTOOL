classdef Quad < matlab.mixin.Copyable
    % Quad Generic contour
    %   Prototype/minimal contour specification, requiring only a
    %   quadrature and associated weights.

    properties (SetObservable)
        z (1,:) double        % quadrature nodes
        w (1,:) double        % quadrature weights
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = eval(class(obj));
            cp.z = obj.z; cp.w = obj.w;
        end
    end

    methods

        function s = FindRandomShift(obj,scale)
            % Returns a random point outside of the convex hull of the
            % given Quad contour.
            % First, the maximum distance (d) between any quadrature node and
            % the geometric center (c) of the nodes is determined.
            % Then, the point is chosen to from the boundary of the circle
            % centered at c with radius d*scale.
            arguments
                obj 
                scale = 1.5 
            end
            c = sum(obj.z)/length(obj.z);
            d = max(abs(c - obj.z))*scale;
            r = randn(1,"like",1i); r = r/norm(r);
            s = c + r*d;
        end

        function obj = Quad(z,w)
            arguments
                z = []
                w = []
            end
            obj.z = z;
            obj.w = w;
        end

    end

end

