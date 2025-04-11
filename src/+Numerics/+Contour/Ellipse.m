classdef Ellipse < Numerics.Contour.Quad
    
    properties (SetObservable)
        gamma   (1,1) double
        alpha   (1,1) double
        beta    (1,1) double
        N       (1,1) double
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
            [z,w] = Numerics.Contour.Ellipse.trapezoid(gamma,alpha,beta,N);
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

        function update(obj,~,~)
            [obj.z,obj.w] = Numerics.Contour.Ellipse.trapezoid(obj.gamma,obj.alpha,obj.beta,obj.N);
        end

    end

end

