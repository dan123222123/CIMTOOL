classdef InterpolationData
    
    properties
        theta   % left shifts
        sigma   % right shifts
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

