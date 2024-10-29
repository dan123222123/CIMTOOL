classdef SPLoewnerComponent < GUI.Method.MethodComponent
    
    % GUI Properties
    properties (Access = private)
        GridLayout               matlab.ui.container.GridLayout
    end
    
    methods
        function obj = HankelComponent(inputArg1,inputArg2)
            %HANKELCOMPONENT Construct an instance of this class
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

