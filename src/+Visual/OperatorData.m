classdef OperatorData <  Numerics.OperatorData & Visual.VisualReactive

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = copyElement@Numerics.OperatorData(obj);
          cp.ax = obj.ax;
      end
   end
    
    methods

        function obj = OperatorData(T,name,arglist,ax)
            arguments
                T = []
                name = []
                arglist = []
                ax = []
            end
            obj = obj@Numerics.OperatorData(T,name,arglist);
            obj.ax = ax;
            addlistener(obj,'refew','PostSet',@obj.update_plot);
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            hold(ax,"on");
            if ~isempty(obj.refew)
                phandles(end+1) = scatter(ax,real(obj.refew),imag(obj.refew),100,"diamond","MarkerEdgeColor","#E66100","LineWidth",1.5,'Tag',"reference_eigenvalues","DisplayName","Reference Eigenvalues");
            end
            hold(ax,"off");
        end
        
    end

end

