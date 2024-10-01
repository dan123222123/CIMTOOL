classdef InterpolationData
    
    properties
        theta   (:,1) double % left shifts
        sigma   (:,1) double  % right shifts
    end
    
    methods
        function obj = InterpolationData(theta,sigma)
            arguments
                theta = NaN
                sigma = Inf
            end
            obj.theta = theta;
            obj.sigma = sigma;
        end
    end
end

