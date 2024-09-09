classdef ContourComponentInterface < matlab.ui.componentcontainer.ComponentContainer

    methods (Abstract)
        getNodesWeights(obj,N)
    end
    
    methods (Access = protected)
        function setup(comp)
        end

        function update(comp)
        end
    end

end

