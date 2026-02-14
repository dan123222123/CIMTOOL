classdef CircularSegment < Numerics.Contour.Quad
% Circular contour specified by a center `gamma`, radius `rho`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double % center
        rho     (1,1) double % radius
        theta   (1,2) double % central subtending angle [start;end]
        N       (1,2) double % number of nodes on [arc;line segment]
        qr = "clencurt" % default quadrature rule on [-1,1]
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.CircularSegment(obj.gamma,obj.rho,obj.theta,obj.N,obj.qr);
        end
    end
    methods
        function obj = CircularSegment(gamma,rho,theta,N,qr)
            arguments
                gamma = 0
                rho = 1
                theta = [-pi/2,pi/2]
                N = [8;8]
                qr = "clencurt"
            end
            [z,w] = Numerics.Contour.CircularSegment.quad(gamma,rho,theta,N,qr);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma; obj.rho = rho;
            if isscalar(N)
                obj.N = [N,N];
            end
            if isscalar(theta)
                obj.theta = [-theta,theta];
            end
            obj.qr = qr;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'theta','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
            addlistener(obj,'qr','PostSet',@obj.update);
        end

        function tf = inside(obj,pt)
            cp = pt-obj.gamma; cang = angle(cp);
            rang = ((cang>obj.theta(1) & cang<(obj.theta(2)))); % right angle
            d = obj.rho*cos(obj.theta(2)-obj.theta(1));
            rrho = bitand((abs(cp) > d),(abs(cp) < obj.rho));
            tf =  rang & rrho;
        end
        % TODO
        function refineQuadrature(obj,rf)
        % Scales the number of quadrature points of the contour by a factor `rf` and explicitly updates the contour.
            arguments
                obj
                rf = 2
            end
            %error("refining of quadrature not yet implemented for circular segments");
            warning("refining circular segments does not reuse previous quadrature information");
            obj.N = rf*obj.N; obj.update();
        end
        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode)
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
            end
            import Numerics.Contour.CircularSegment;
            % nodes on a circle around the current quad nodes
            switch mode
                case 'scale'
                    rs = obj.rho*d;
                case 'shift'
                    rs = obj.rho+d;
            end
            theta = double.empty();
            sigma = double.empty();
            z = Numerics.Contour.CircularSegment.quad(obj.gamma,rs,obj.theta,nsw,obj.qr);
            z_chord = z(length(z)/2+1:length(z)); z_chord = z_chord + sin(obj.theta(1))*(rs-obj.rho);
            z = [z(1:length(z)/2) z_chord];
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
        function update(obj,~,~)
        % Updates contour nodes and weights using the trapezoid rule.
            [obj.z,obj.w] = Numerics.Contour.CircularSegment.quad(obj.gamma,obj.rho,obj.theta,obj.N,obj.qr);
        end
    end
    methods (Static)
        function [z,w] = quad(gamma,rho,theta,N,qr)
            arguments (Input)
                gamma   % center
                rho     % radius
                theta   % central subtending angle
                N       % number of nodes on [arc;line segment]
                qr = "clencurt" % default quadrature rule on [-1,1]
            end
            arguments (Output)
                z       % nodes
                w       % weights
            end
            import Numerics.Contour.*;

            % use the same number of nodes on each boundary segment if scalar N
            if isscalar(N)
                N = [N;N];
            end
            % assume equal subtending angles if scalar theta
            if isscalar(theta)
                theta = [-theta,theta];
            end

            % fix the quadrature rule on [-1,1] to use
            % note that clencurt gives N+1 nodes, so we decrement N by 1
            if qr == "clencurt"
                N = N - 1;
                qr = @clencurt;
            elseif qr == "gauss"
                qr = @gauss;
            else
                error('Unsupported quadrature rule specified.');
            end

            [t1,w1] = qr(N(1)); w1 = w1.'; [t2,w2] = qr(N(2)); w2 = w2.';

            z_arc = @(t) gamma + rho*exp(1i*(theta(1) + ((1+t)/2) * (theta(2) - theta(1))));
            w_arc = @(t) 1i*rho*((theta(2)-theta(1))/2) * exp(1i*(theta(1) + ((1+t)/2) * (theta(2) - theta(1))));

            z_chord = @(t) gamma + (rho/2)*(exp(1i*theta(1)) + exp(1i*theta(2)) + t*(exp(1i*theta(1))-exp(1i*theta(2))));
            w_chord = (rho/2)*(exp(1i*theta(1))-exp(1i*theta(2))); % just a constant

            z = [z_arc(t1);z_chord(t2)]; w = [(w1.*w_arc(t1));w2*w_chord];
            w = w/(2i*pi); % needed for contour integral to be scaled correctly in CIMTOOL!
            z = z.'; w = w.';
        end
    end
end
