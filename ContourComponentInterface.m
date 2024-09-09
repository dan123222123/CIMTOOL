classdef ContourComponentInterface < matlab.ui.componentcontainer.ComponentContainer

    properties (Access = public)
        q % map from N -> parameter
        f % map from parameter -> point in C
    end

    methods (Abstract)
        %setQuadRule(obj, qnew)
        %setContourParametrization(obj, f)
    end
    
    methods (Access = protected)

        function setup(comp)

        end

        function update(comp)

        end

    end

    methods (Access = public)

        % return N-vector samples of contour in C corresponding to the
        % contour parametrized by f under rule q
        function z = getQuadNodes(obj, N)
            z = obj.f(obj.q(N));
        end

    end
end

