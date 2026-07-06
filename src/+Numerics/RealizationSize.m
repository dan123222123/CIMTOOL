classdef RealizationSize

    properties
        m  (1,1) double {mustBeNonnegative, mustBeInteger} = 0
        T1 (1,1) double {mustBeNonnegative, mustBeInteger} = 0
        T2 (1,1) double {mustBeNonnegative, mustBeInteger} = 0
    end

    methods
        function obj = RealizationSize(m,T1,T2)
            arguments
                m  (1,1) double {mustBeNonnegative, mustBeInteger} = 0
                T1 (1,1) double {mustBeNonnegative, mustBeInteger} = m
                T2 (1,1) double {mustBeNonnegative, mustBeInteger} = T1
            end
            obj.m = m; obj.T1 = T1; obj.T2 = T2;
        end
    end

end