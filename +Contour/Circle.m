classdef Circle < Contour.Quad
    
    properties (SetObservable)
        center  (1,1) double = 0+0i
        radius  (1,1) double = 1
        N       (1,1) double = 8
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

        function obj = Circle(center,radius,N,ax)
            arguments
                center
                radius
                N = 8
                ax = missing
            end
            [z,w] = Contour.Circle.trapezoid(center,radius,N);
            obj@Contour.Quad(z,w)
            obj.center = center;
            obj.radius = radius;
            obj.N = N;
            if ~ismissing(ax)
                obj.plot(ax)
            end
            addlistener(obj,'center','PostSet',@obj.update);
            addlistener(obj,'radius','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
            addlistener(obj,'plot_quadrature','PostSet',@obj.update_plot)
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
            zp = Contour.Circle.trapezoid(obj.center,obj.radius,512);
            zp = [obj.center + obj.radius, zp, obj.center + obj.radius];
            chold = ishold(ax);
            obj.phandles(end+1) = scatter(ax,real(obj.center),imag(obj.center),200,"black",'filled','Tag',"contour_center");
            hold(ax,"on");
            if obj.plot_quadrature
                obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature_nodes");
            end
            obj.phandles(end+1) = plot(ax,real(zp),imag(zp),"blue",'LineWidth',5,'Tag',"contour");
            hold(ax,chold);
            obj.ax = ax;
        end

        function update(obj,~,~)
            obj.loaded = false;
            [obj.z,obj.w] = Contour.Circle.trapezoid(obj.center,obj.radius,obj.N);
            obj.update_plot(missing,missing);
            obj.loaded = true;
        end

    end

end

