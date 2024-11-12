classdef Circle < Numerics.Contour.Quad
    
    properties (SetObservable)
        gamma   (1,1) double
        radius  (1,1) double
        N       (1,1) double
        plot_quadrature = false
    end

    methods (Static)

        function [z,w] = trapezoid(gamma,rho,N)
            q = @(N) ((2*pi)/N)*((1:N) - (1/2));
            f = @(theta) gamma + rho*exp(1i*theta);
            wfun = @(theta) (rho/N)*exp(1i*theta);
            z = f(q(N));
            w = wfun(q(N));
        end

    end
    
    methods

        function obj = Circle(gamma,radius,N,ax)
            arguments
                gamma = 0
                radius = 1
                N = 8
                ax = missing
            end
            [z,w] = Numerics.Contour.Circle.trapezoid(gamma,radius,N);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma;
            obj.radius = radius;
            obj.N = N;
            if ~ismissing(ax)
                obj.plot(ax)
            end
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'radius','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
            addlistener(obj,'plot_quadrature','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function tf = inside(obj,pt)
            tf = (abs(pt-obj.gamma) < obj.radius);
        end

        function plot(obj,ax)
            arguments
                obj
                ax = obj.ax
            end
            if ismissing(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.phandles)
                obj.cla();
            end
            zp = Numerics.Contour.Circle.trapezoid(obj.gamma,obj.radius,512);
            zp = [obj.gamma + obj.radius, zp, obj.gamma + obj.radius];
            chold = ishold(ax);
            obj.phandles(end+1) = scatter(ax,real(obj.gamma),imag(obj.gamma),200,"black",'filled','Tag',"contour_center","HandleVisibility","off");
            hold(ax,"on");
            if obj.plot_quadrature
                obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature","DisplayName","Quadrature Nodes");
            end
            obj.phandles(end+1) = plot(ax,real(zp),imag(zp),"blue",'LineWidth',5,'Tag',"contour","HandleVisibility","off");
            hold(ax,chold);
            obj.ax = ax;
        end

        function update(obj,~,~)
            [obj.z,obj.w] = Numerics.Contour.Circle.trapezoid(obj.gamma,obj.radius,obj.N);
            obj.update_plot(missing,missing);
        end

    end

end

