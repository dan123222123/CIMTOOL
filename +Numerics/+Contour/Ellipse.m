classdef Ellipse < Numerics.Contour.Quad
    
    properties (SetObservable)
        gamma   (1,1) double
        alpha   (1,1) double
        beta    (1,1) double
        N       (1,1) double
        plot_quadrature = false
    end

    methods (Static)

        function [z,w] = trapezoid(gamma,alpha,beta,N)
            q = @(N) ((2*pi)/N)*((1:N) - (1/2));
            f = @(theta) gamma + alpha*cos(theta) + 1i*beta*sin(theta);
            wfun = @(theta) (1/N)*(beta*cos(theta) + 1i*alpha*sin(theta));
            z = f(q(N));
            w = wfun(q(N));
        end

    end
    
    methods

        function obj = Ellipse(gamma,alpha,beta,N,ax)
            arguments
                gamma = 0
                alpha = 1
                beta = 1
                N = 8
                ax = missing
            end
            [z,w] = Numerics.Contour.Ellipse.trapezoid(gamma,alpha,beta,N);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma;
            obj.alpha = alpha;
            obj.beta = beta;
            obj.N = N;
            if ~ismissing(ax)
                obj.plot(ax)
            end
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'alpha','PostSet',@obj.update);
            addlistener(obj,'beta','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
            addlistener(obj,'plot_quadrature','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function tf = inside(obj,pt)
            tf = (((real(pt) - real(obj.gamma)).^2/obj.alpha^2) + ((imag(pt) - imag(obj.gamma)).^2/obj.beta^2) < 1);
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
            zp = Numerics.Contour.Ellipse.trapezoid(obj.gamma,obj.alpha,obj.beta,512);
            zp = [obj.gamma + obj.alpha, zp, obj.gamma + obj.alpha];
            chold = ishold(ax);
            obj.phandles(end+1) = scatter(ax,real(obj.gamma),imag(obj.gamma),200,"black",'filled','Tag',"contour_center");
            hold(ax,"on");
            if obj.plot_quadrature
                obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature_nodes");
            end
            obj.phandles(end+1) = plot(ax,real(zp),imag(zp),"blue",'LineWidth',5,'Tag',"contour");
            hold(ax,chold);
            obj.ax = ax;
        end

        function update(obj,~,~)
            [obj.z,obj.w] = Numerics.Contour.Ellipse.trapezoid(obj.gamma,obj.alpha,obj.beta,obj.N);
            obj.update_plot(missing,missing);
        end

    end

end

