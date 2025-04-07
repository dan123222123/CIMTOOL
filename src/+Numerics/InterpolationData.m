classdef InterpolationData
    properties
        theta
        sigma
    end
    methods
        function obj = InterpolationData(theta,sigma)
            obj.theta = theta; obj.sigma = sigma;
        end
    end
end