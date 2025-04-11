classdef Circle < Numerics.Contour.Quad
    
    properties (SetObservable)
        gamma   (1,1) double
        rho     (1,1) double
        N       (1,1) double
    end

    methods (Static)

        function [z,w] = trapezoid(gamma,rho,N)
            % q = @(N) ((2*pi)/N)*((1:N) - (1/2));
            q = @(N) ((2*pi)/N)*(1:N);
            f = @(theta) gamma + rho*exp(1i*theta);
            wfun = @(theta) (rho/N)*exp(1i*theta);
            z = f(q(N));
            w = wfun(q(N));
        end

        function z = circquad(gamma,rho,N)
            assert(mod(N,2) == 0);
            q = ((2*pi)/N)*(1:(N/2)-1);
            f = @(theta) gamma + rho*exp(1i*theta);
            z = f(q); zc = flip(conj(z));
            z = [z missing zc+imag(gamma)*2i];
        end

    end

   methods(Access = protected)
      function cp = copyElement(obj)
          cp = Numerics.Contour.Circle(obj.gamma,obj.rho,obj.N);
      end
   end
    
    methods

        function obj = Circle(gamma,rho,N)
            arguments
                gamma = 0
                rho = 1
                N = 8
            end
            [z,w] = Numerics.Contour.Circle.trapezoid(gamma,rho,N);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma;
            obj.rho = rho;
            obj.N = N;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
        end

        function tf = inside(obj,pt)
            tf = (abs(pt-obj.gamma) < obj.rho);
        end

        function [z,w] = trapezoidContour(obj)
            [z,w] = Numerics.Contour.Circle.trapezoid(obj.gamma,obj.rho,obj.N);
        end

        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode,variant)
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
                variant = 'cconj' % or 'trap'
            end

            z = obj.z;
            % get the geometric center
            c = sum(z)/length(z);
            % get the maximum distance between c and quad nodes
            r = max(abs(c - z));
            % nodes on a circle around the current quad nodes
            switch mode
                case 'scale'
                    rs = r*d;
                case 'shift'
                    rs = r+d;
            end
        
            theta = double.empty();
            sigma = double.empty();
        
            % workaround since even nsw doesn't work for cconj variant...
            if mod(nsw,2) == 1
                variant = 'trap';
            end
        
            switch variant
                case 'cconj'
                    z = Numerics.Contour.Circle.circquad(c,rs,2*(nsw+1));
                case 'trap'
                    z = Numerics.Contour.Circle.trapezoid(c,rs,2*nsw);
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
            [obj.z,obj.w] = Numerics.Contour.Circle.trapezoid(obj.gamma,obj.rho,obj.N);
        end

    end

end

