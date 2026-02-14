classdef Quad < matlab.mixin.Copyable
% Generic "contour" specified only by its nodes and weights.

    properties (SetObservable)
        z (1,:) double = []  % nodes
        w (1,:) double = []  % weights
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = feval(class(obj));
            cp.z = obj.z; cp.w = obj.w;
        end
    end

    methods
        function obj = Quad(z,w)
            obj.z = z; obj.w = w;
        end
        function tf = inside(obj,pt)
            % Determine if a point `pt` is inside the convex hull of the contour
            c = sum(obj.z)/length(obj.z);
            d = max(abs(c - obj.z));
            tf = (abs(pt-c) < d);
        end
        function s = FindRandomShift(obj,scale)
            % Returns a random point outside of the convex hull of the given contour.
            % First, the maximum distance `d` between any node and the geometric center `c` is determined.
            % A complex i.i.d point is chosen with distance `d`*`scale` from `c`.
            arguments
                obj
                scale = 1.25
            end
            c = sum(obj.z)/length(obj.z);
            d = max(abs(c - obj.z))*scale;
            r = randn(1,"like",1i); r = r/norm(r);
            s = c + r*d;
        end
    end

end
