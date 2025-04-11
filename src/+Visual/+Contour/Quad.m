classdef Quad < Numerics.Contour.Quad & Visual.VisualReactive

    properties (SetObservable)
        plot_quadrature = true
    end

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = Visual.Contour.Quad(obj.z,obj.w,obj.ax);
          cp.plot_quadrature = obj.plot_quadrature;
      end
   end

    methods

        function obj = Quad(z,w,ax)
            arguments
                z = []
                w = []
                ax = []
            end
            obj = obj@Numerics.Contour.Quad(z,w);
            obj.ax = ax;
            addlistener(obj,'z','PostSet',@obj.update_plot);
            addlistener(obj,'plot_quadrature','PostSet',@obj.update_plot);
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax) || ~obj.plot_quadrature; return; end
            hold(ax,"on");
            phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature","DisplayName","Quadrature Nodes");
            hold(ax,"off");
        end

    end

end

