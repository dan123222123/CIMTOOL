classdef InterpolationData
    properties
        theta
        sigma
    end
    methods
        function obj = InterpolationData(theta,sigma)
            arguments
                theta double = []
                sigma double = []
            end
            obj.theta = theta; obj.sigma = sigma;
        end
    end
end