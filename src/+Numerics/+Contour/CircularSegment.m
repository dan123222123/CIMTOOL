classdef CircularSegment < Numerics.Contour.Quad
% Circular contour specified by a center `gamma`, radius `rho`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double = 0 % center
        rho     (1,1) double {mustBePositive} = 1 % radius
        theta   (1,2) double {mustBeReal} = [-pi/2, pi/2] % central subtending angle [start,end]
        N       (1,2) double {mustBePositive, mustBeInteger} = [8, 8] % number of nodes on [arc;line segment]
        qr      (1,1) string {mustBeMember(qr,["clencurt","gauss"])} = "clencurt" % quadrature rule on [-1,1]
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.CircularSegment(obj.gamma,obj.rho,obj.theta,obj.N,obj.qr);
        end
    end
    methods
        function obj = CircularSegment(gamma,rho,theta,N,qr)
            arguments
                gamma (1,1) double = 0
                rho (1,1) double {mustBePositive} = 1
                theta double {mustBeReal} = [-pi/2,pi/2]
                N double {mustBePositive, mustBeInteger} = [8;8]
                qr (1,1) string {mustBeMember(qr,["clencurt","gauss"])} = "clencurt"
            end
            if isscalar(N)
                N = [N;N];
            end
            if isscalar(theta)
                theta = [-theta,theta];
            end
            % validate the (possibly expanded) angle range and node-count shapes
            if numel(theta) ~= 2
                error("Numerics:Contour:CircularSegment:badTheta", ...
                    "theta must be a scalar half-angle or a 2-element [start,end] range; got %d elements.", numel(theta));
            end
            if ~(theta(2) > theta(1))
                error("Numerics:Contour:CircularSegment:badTheta", ...
                    "theta(2) (=%g) must be strictly greater than theta(1) (=%g).", theta(2), theta(1));
            end
            if theta(2) - theta(1) > 2*pi + 1e-9
                error("Numerics:Contour:CircularSegment:badTheta", ...
                    "theta span (=%g) must not exceed 2*pi.", theta(2) - theta(1));
            end
            if numel(N) ~= 2
                error("Numerics:Contour:CircularSegment:badN", ...
                    "N must be a scalar or a 2-element [arc;chord] node count; got %d elements.", numel(N));
            end
            [z,w] = Numerics.Contour.CircularSegment.quad(gamma,rho,theta,N,qr);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma; obj.rho = rho;
            obj.N = N;
            obj.theta = theta;
            obj.qr = qr;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'theta','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
            addlistener(obj,'qr','PostSet',@obj.update);
        end

        function tf = inside(obj,pt)
            % segment = open disk intersected with the open half-plane on
            % the arc side of the chord (valid for minor and major segments,
            % no angle() branch-cut issues)
            cp = pt-obj.gamma;
            mid = (obj.theta(1)+obj.theta(2))/2;
            d = obj.rho*cos((obj.theta(2)-obj.theta(1))/2); % center-to-chord distance (signed)
            tf = (abs(cp) < obj.rho) & (real(cp.*exp(-1i*mid)) > d);
        end
        function reused = refineQuadrature(obj,rf)
        % Refine the quadrature, reusing previous samples where the nodes nest.
        %
        % The Clenshaw-Curtis nodes are nested: the N-node rule cos(pi*k/(N-1))
        % is exactly the even-indexed subset of the 2(N-1)+1-node rule, so a
        % nested doubling takes N -> 2N-1 on each boundary piece (arc and chord)
        % and every old node survives -- at the ODD local positions of the
        % refined piece. We return a logical mask over the refined node vector
        % obj.z marking those reused nodes (in their original order) so that
        % SampleData can slot in the cached operator evaluations and sample only
        % the genuinely new nodes. Gauss nodes do not nest: fall back to a plain
        % (non-reusing) refinement and return [] to mean "resample everything".
            arguments
                obj
                rf = 2
            end
            if rf == 2 && obj.qr == "clencurt"
                Nold = obj.N;                       % [N_arc, N_chord]
                La = 2*Nold(1) - 1; Lc = 2*Nold(2) - 1;
                reused = false(1, La + Lc);
                reused(1:2:La) = true;              % arc:   old nodes at odd local positions
                reused(La + (1:2:Lc)) = true;       % chord: old nodes at odd local positions
                obj.N = [La, Lc];
                obj.update();
            else
                warning("Numerics:Contour:CircularSegment:noNest", ...
                    "Refining a '%s' circular segment does not reuse previous quadrature data.", obj.qr);
                obj.N = rf*obj.N;
                obj.update();
                reused = [];                        % signal SampleData to resample everything
            end
        end
        function [theta,sigma] = interlevedshifts(obj,nsw,d,mode)
            arguments
                obj
                nsw
                d = 1.25
                mode = 'scale'
            end
            import Numerics.Contour.CircularSegment;
            switch mode
                case 'scale'
                    rs = obj.rho*d;
                case 'shift'
                    rs = obj.rho+d;
            end
            % Interpolation points sit on the segment boundary pushed OUTWARD so
            % they stay outside the contour for any orientation:
            %   * arc   -> same angles at the enlarged radius rs (outside the disk)
            %   * chord -> the original chord offset by (rs-rho) along its outward
            %              normal -exp(1i*mid), mid = (theta1+theta2)/2.
            % Offsetting along the geometric normal keeps the chord points outside
            % under rotation, and they flip with the segment (flipping adds pi to
            % mid, so the normal -- and the chord points -- flip with it).
            delta = rs - obj.rho;
            mid = (obj.theta(1) + obj.theta(2))/2;
            nrm = -exp(1i*mid);
            zout = CircularSegment.quad(obj.gamma,rs,obj.theta,nsw,obj.qr);
            zin  = CircularSegment.quad(obj.gamma,obj.rho,obj.theta,nsw,obj.qr);
            half = length(zout)/2;
            z = [zout(1:half), zin(half+1:end) + delta*nrm];

            theta = double.empty();
            sigma = double.empty();
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
