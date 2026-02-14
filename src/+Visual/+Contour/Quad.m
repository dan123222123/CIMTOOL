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

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.Contour.* from a Numerics.Contour.Quad subclass.
            % Dispatches on the runtime type of n.
            arguments
                n Numerics.Contour.Quad
                ax = []
            end
            switch class(n)
                case 'Numerics.Contour.Circle'
                    v = Visual.Contour.Circle(n.gamma, n.rho, n.N, ax);
                case 'Numerics.Contour.Ellipse'
                    v = Visual.Contour.Ellipse(n.gamma, n.alpha, n.beta, n.N, ax);
                case 'Numerics.Contour.CircularSegment'
                    v = Visual.Contour.CircularSegment(n.gamma, n.rho, n.theta, n.N, n.qr, ax);
                case 'Numerics.Contour.Quad'
                    v = Visual.Contour.Quad(n.z, n.w, ax);
                otherwise
                    error('Visual.Contour.Quad.fromNumerics: unknown contour type "%s"', class(n));
            end
            % Constructor already set all shared properties via named params.
            % plot_quadrature defaults to true — intentionally not copied from Numerics.
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

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return the matching Numerics.Contour.* type.
            switch class(obj)
                case 'Visual.Contour.Circle'
                    n = Numerics.Contour.Circle();
                case 'Visual.Contour.Ellipse'
                    n = Numerics.Contour.Ellipse();
                case 'Visual.Contour.CircularSegment'
                    n = Numerics.Contour.CircularSegment();
                case 'Visual.Contour.Quad'
                    n = Numerics.Contour.Quad();
                otherwise
                    error('Visual.Contour.Quad.toNumerics: unknown contour type "%s"', class(obj));
            end
            % Copies gamma/rho/N/z/w etc.; skips ax, phandles, plot_quadrature
            Visual.copyMatchingProperties(obj, n);
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
