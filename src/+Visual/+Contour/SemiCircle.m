classdef SemiCircle < Numerics.Contour.SemiCircle & Visual.Contour.Quad

   methods(Access = protected)
      function cp = copyElement(obj)
          cp = Visual.Contour.SemiCircle(obj.gamma,obj.rho,obj.theta,obj.N,obj.ax);
          cp.plot_quadrature = obj.plot_quadrature;
      end
   end
    
    methods
        function obj = SemiCircle(gamma,rho,theta,N,ax)
            arguments
                gamma = 0
                rho = 1
                theta = 0
                N = [8;8]
                ax = []
            end
            obj = obj@Numerics.Contour.SemiCircle(gamma,rho,theta,N);
            obj.plot_quadrature = false; obj.ax = ax;
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            zp = Numerics.Contour.SemiCircle.quad(obj.gamma,obj.rho,obj.theta,[512;512]);
            of = obj.rho*0.05;
            hold(ax,"on");
            phandles(end+1) = rectangle(ax,'Position',[real(obj.gamma)-of/2 imag(obj.gamma)-of/2 of of], 'Curvature',[1 1], 'Facecolor','k', 'Edgecolor','k','Tag','contour_center',"HandleVisibility","off","Visible","off");
            phandles(end+1) = plot(ax,real(zp),imag(zp),"blue",'LineWidth',5,'Tag',"contour","HandleVisibility","off","DisplayName","Contour");
            hold(ax,"off");
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

