classdef Circle < Numerics.Contour.Circle & Visual.Contour.Quad

   methods(Access = protected)
      function cp = copyElement(obj)
          cp = Visual.Contour.Circle(obj.gamma,obj.rho,obj.N,obj.ax);
          cp.plot_quadrature = obj.plot_quadrature;
      end
   end
    
    methods
        function obj = Circle(gamma,rho,N,ax)
            arguments
                gamma = 0
                rho = 1
                N = 8
                ax = []
            end
            obj = obj@Numerics.Contour.Circle(gamma,rho,N);
            obj.plot_quadrature = false;
            obj.ax = ax;
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            zp = Numerics.Contour.Circle.trapezoid(obj.gamma,obj.rho,512);
            zp = [obj.gamma + obj.rho, zp, obj.gamma + obj.rho];
            phandles = obj.plotContourCurve(ax, zp, obj.gamma, obj.rho*0.05);
            phandles = [phandles plot@Visual.Contour.Quad(obj,ax)];
        end

        function toggleVisibility(obj,mode)
            p = findobj(obj.phandles,'Tag','contour_center');
            uistack(p,'top');
            set(p,'HandleVisibility',mode);
            set(p,'Visible',mode);
            p = findobj(obj.phandles,'Tag','contour');
            set(p,'HandleVisibility',mode);
            uistack(p,'top');
        end

    end

end

