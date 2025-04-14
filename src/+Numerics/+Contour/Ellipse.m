classdef Ellipse < Numerics.Contour.Quad
% Ellipsoidal contour specified by a center `gamma`, horizontal and vertical semi-radii `alpha` and `beta`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double % center
        alpha   (1,1) double % horizontal semi-radius
        beta    (1,1) double % vertical semi-radius
        N       (1,1) double % number of quadrature nodes
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.Ellipse(obj.gamma,obj.alpha,obj.beta,obj.N);
        end
    end
    methods
        function obj = Ellipse(gamma,alpha,beta,N)
            arguments
                gamma = 0
                alpha = 1
                beta = 1
                N = 8
            end
            import Numerics.Contour.Ellipse
            [z,w] = trapezoid(gamma,alpha,beta,N);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma;
            obj.alpha = alpha;
            obj.beta = beta;
            obj.N = N;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'alpha','PostSet',@obj.update);
            addlistener(obj,'beta','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
        end
        function tf = inside(obj,pt)
            tf = (((real(pt) - real(obj.gamma)).^2/obj.alpha^2) + ((imag(pt) - imag(obj.gamma)).^2/obj.beta^2) < 1);
        end
        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode,variant)
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
                variant = 'cconj' % or 'trap'
            end
            import Numerics.Contour.Ellipse;
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
                    z = ellipquad(obj.gamma,as,bs,2*(nsw+1));
                case 'trap'
                    z = trapezoid(obj.gamma,as,bs,2*nsw);
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
            obj.N = rf*obj.N; obj.update();
        end
        function update(obj,~,~)
            import Numerics.Contour.Ellipse;
            [obj.z,obj.w] = trapezoid(obj.gamma,obj.alpha,obj.beta,obj.N);
        end
    end
    methods (Static)
        function [z,w] = trapezoid(gamma,alpha,beta,N)
            arguments (Input)
                gamma   % center
                alpha   % horizontal semi-radius
                beta    % vertical semi-radius
                N       % number of nodes
            end
            arguments (Output)
                z       % nodes
                w       % weights
            end
            q = @(N) ((2*pi)/N)*(1:N);
            f = @(theta) gamma + alpha*cos(theta) + 1i*beta*sin(theta);
            wfun = @(theta) (1/N)*(beta*cos(theta) + 1i*alpha*sin(theta));
            z = f(q(N));
            w = wfun(q(N));
        end
    end
    methods (Static, Access=private)
        function z = ellipquad(gamma,alpha,beta,N)
            assert(mod(N,2) == 0);
            q = ((2*pi)/N)*(1:(N/2)-1);
            f = @(theta) gamma + alpha*cos(theta) + 1i*beta*sin(theta);
            z = f(q); zc = flip(conj(z));
            z = [z missing zc+imag(gamma)*2i];
        end
    end
end
