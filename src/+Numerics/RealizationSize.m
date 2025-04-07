classdef RealizationSize

    properties
        m
        T1
        T2
    end

    methods
        function obj = RealizationSize(m,T1,T2)
            arguments
                m = 0
                T1 = m
                T2 = T1
            end
            obj.m = m; obj.T1 = T1; obj.T2 = T2;
        end
    end

end