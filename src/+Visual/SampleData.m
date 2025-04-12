classdef SampleData < Numerics.SampleData & Visual.VisualReactive

    methods (Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.SampleData(obj);
            cp.ax = obj.ax; cp.update_plot();
        end
    end
    
    methods

        function obj = SampleData(OperatorData,Contour,ell,r,ax)
            arguments
                OperatorData = Visual.OperatorData()
                Contour = Visual.Contour.Circle()
                ell = 0
                r = 0
                ax = []
            end
            obj = obj@Numerics.SampleData(OperatorData,Contour,ell,r);
            obj.ax = ax; obj.update_plot([],[]);
            addlistener(obj,'OperatorData','PostSet',@obj.update_plot);
            addlistener(obj,'Contour','PostSet',@obj.update_plot);
        end

        function update_plot(obj,~,~)
            obj.Contour.ax = obj.ax; obj.OperatorData.ax = obj.ax;
            obj.phandles = [obj.Contour.phandles obj.OperatorData.phandles];
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax); return; end
            phandles = [phandles obj.Contour.plot(ax)];
            phandles = [phandles obj.OperatorData.plot(ax)];
        end

    end

end