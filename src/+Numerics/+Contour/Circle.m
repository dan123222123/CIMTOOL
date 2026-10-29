classdef Circle < Numerics.Contour.Quad
% Circular contour specified by a center `gamma`, radius `rho`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double = 0 % center
        rho     (1,1) double {mustBePositive} = 1 % radius
        N       (1,1) double {mustBePositive, mustBeInteger} = 8 % number of quadrature nodes
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.Circle(obj.gamma,obj.rho,obj.N);
        end
        function reattachListeners(obj)
            obj.addUpdateListeners();
        end
    end
    methods (Access = private)
        function addUpdateListeners(obj)
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
        end
    end
    methods
        function obj = Circle(gamma,rho,N)
            arguments
                gamma (1,1) double = 0
                rho (1,1) double {mustBePositive} = 1
                N (1,1) double {mustBePositive, mustBeInteger} = 8
            end
            import Numerics.Contour.Circle.trapezoid;
            [z,w] = trapezoid(gamma,rho,N);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma; obj.rho = rho; obj.N = N;
            obj.addUpdateListeners();
        end

        function tf = inside(obj,pt)
            tf = (abs(pt-obj.gamma) < obj.rho);
        end

        function s = FindShift(obj,scale)
            % As Quad.FindShift, from the center `gamma` and radius `rho` rather than the nodes.
            arguments
                obj
                scale = 1.25
            end
            s = obj.gamma + obj.rho*scale*exp(1i*pi/4);
        end

        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode,variant,phase)
        % Returns a set of left and right interleaved shifts with `nsw` shifts each. The shifts are placed `d`*\(\rho\) or `d`+\(\rho\) away from the center of the contour depending on setting `mode=scale` or `mode=shift`, respectively.
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
                variant = 'cconj' % or 'trap'
                phase = 0         % rotation of the 'trap' points, in [0, pi/2]
            end
            import Numerics.Contour.Circle.trapezoid Numerics.Contour.Circle.circquad;
            c = obj.gamma;
            r = obj.rho;
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
                    if phase ~= 0
                        error("Numerics:Circle:phaseNeedsTrap", "phase applies to the 'trap' variant only.");
                    end
                    z = circquad(c,rs,2*(nsw+1));
                case 'trap'
                    z = trapezoid(c,rs,2*nsw,phase);
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
        % Scales the number of quadrature points of the contour by a factor `rf` and explicitly updates the contour.
            arguments
                obj
                rf = 2
            end
            obj.N = rf*obj.N; obj.update();
        end
        function update(obj,~,~)
        % Updates contour nodes and weights using the trapezoid rule.
            import Numerics.Contour.Circle.trapezoid;
            [obj.z,obj.w] = trapezoid(obj.gamma,obj.rho,obj.N);
        end
    end
    methods (Static)
        function [z,w] = trapezoid(gamma,rho,N,phase)
            arguments (Input)
                gamma       % center
                rho         % radius
                N           % number of nodes
                phase = 0   % angle added to every node
            end
            arguments (Output)
                z       % nodes
                w       % weights
            end
            q = @(N) phase + ((2*pi)/N)*(1:N);
            f = @(theta) gamma + rho*exp(1i*theta);
            wfun = @(theta) (rho/N)*exp(1i*theta);
            z = f(q(N)); w = wfun(q(N));
        end
    end
    methods (Static, Access=private)
        function z = circquad(gamma,rho,N)
            assert(mod(N,2) == 0);
            q = ((2*pi)/N)*(1:(N/2)-1);
            f = @(theta) gamma + rho*exp(1i*theta);
            z = f(q); zc = flip(conj(z));
            z = [z missing zc+imag(gamma)*2i];
        end
    end
end
