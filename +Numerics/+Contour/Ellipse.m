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
            % q = @(N) ((2*pi)/N)*((1:N) - (1/2));
            q = @(N) ((2*pi)/N)*(1:N);
            f = @(theta) gamma + alpha*cos(theta) + 1i*beta*sin(theta);
            wfun = @(theta) (1/N)*(beta*cos(theta) + 1i*alpha*sin(theta));
            z = f(q(N));
            w = wfun(q(N));
        end

        function z = ellipquad(gamma,alpha,beta,N)
            assert(mod(N,2) == 0);
            q = ((2*pi)/N)*(1:(N/2)-1);
            f = @(theta) gamma + alpha*cos(theta) + 1i*beta*sin(theta);
            % f = @(theta) gamma + rho*exp(1i*theta);
            z = f(q); zc = flip(conj(z));
            z = [z missing zc+imag(gamma)*2i];
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

        function [z,w] = trapezoidContour(obj)
            [z,w] = Numerics.Contour.Ellipse.trapezoid(obj.gamma,obj.alpha,obj.beta,obj.N);
        end

        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode,variant)
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
                variant = 'cconj' % or 'trap'
            end

            % nodes on a circle around the current quad nodes
            switch mode
                case 'scale'
                    as = obj.alpha*d;
                    bs = obj.beta*d;
                case 'shift'
                    as = obj.alpha+d;
                    bs = obj.beta+d;
            end
        
            theta = double.empty();
            sigma = double.empty();
        
            % workaround since even nsw doesn't work for cconj variant...
            if mod(nsw,2) == 1
                variant = 'trap';
            end
        
            switch variant
                case 'cconj'
                    z = Numerics.Contour.Ellipse.ellipquad(obj.gamma,as,bs,2*(nsw+1));
                case 'trap'
                    z = Numerics.Contour.Ellipse.trapezoid(obj.gamma,as,bs,2*nsw);
            end
        
            for i=1:length(z)
                if ~ismissing(z(i))
                    if mod(i,2) == 0
                        theta(end+1) = z(i);
                    else
                        sigma(end+1) = z(i);
                    end
                end
            end
        
            theta = theta.';
            sigma = sigma.';

        end

        function refineQuadrature(obj,rf)
            arguments
                obj
                rf = 2
            end
            obj.N = rf*obj.N;
            [obj.z,obj.w] = trapezoidContour(obj);
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
            % chold = ishold(ax);
            of = max(obj.alpha,obj.beta)*0.05;
            % obj.phandles(end+1) = scatter(ax,real(obj.gamma),imag(obj.gamma),200,"black",'filled','Tag',"contour_center","HandleVisibility","off");
            obj.phandles(end+1) = rectangle(ax,'Position',[real(obj.gamma)-of/2 imag(obj.gamma)-of/2 of of], 'Curvature',[1 1], 'Facecolor','k', 'Edgecolor','k','Tag','contour_center',"HandleVisibility","off","Visible","off");
            hold(ax,"on");
            if obj.plot_quadrature
                obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature","DisplayName","Quadrature Nodes");
            end
            obj.phandles(end+1) = plot(ax,real(zp),imag(zp),"blue",'LineWidth',5,'Tag',"contour","HandleVisibility","off");
            % hold(ax,chold);
            hold(ax,"off")
            obj.ax = ax;
        end

        function update(obj,~,~)
            [obj.z,obj.w] = Numerics.Contour.Ellipse.trapezoid(obj.gamma,obj.alpha,obj.beta,obj.N);
            obj.update_plot(missing,missing);
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

