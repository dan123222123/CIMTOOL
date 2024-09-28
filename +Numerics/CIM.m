classdef CIM
    %CIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        SampleData      Numerics.SampleData
        ContourData     Contour.Quad
        NLEVPData       Numerics.NLEVPData
        RealizationData Numerics.RealizationData
        ResultData      Numerics.ResultData
        DataDirtiness % make this an enum class, inherit from unit
        ComputationalMode % make this an enum class
    end
    
    methods
        function obj = CIM(inputArg1,inputArg2)
            %CIM Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

