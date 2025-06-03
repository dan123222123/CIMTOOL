classdef SemiCircle < Numerics.Contour.Quad
% Circular contour specified by a center `gamma`, radius `rho`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double % center
        rho     (1,1) double % radius
        theta   (1,1) double % angle wrt real line
        N       (1,2) double % number of nodes on [arc;line segment]
        qr = "clencurt" % default quadrature rule on [-1,1]
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.SemiCircle(obj.gamma,obj.rho,obj.theta,obj.N,obj.qr);
        end
    end
    methods
        function obj = SemiCircle(gamma,rho,theta,N,qr)
            arguments
                gamma = 0
                rho = 1
                theta = 0
                N = [8;8]
                qr = "clencurt"
            end
            [z,w] = Numerics.Contour.SemiCircle.quad(gamma,rho,theta,N,qr);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma; obj.rho = rho; obj.theta = theta;
            obj.N = N;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'theta','PostSet',@obj.update);
            addlistener(obj,'N','PostSet',@obj.update);
        end
        
        function tf = inside(obj,pt)
            cp = pt-obj.gamma; cang = angle(cp);
            tf = ((cang>obj.theta & cang<(obj.theta+pi)) & abs(cp)<obj.rho);
        end
        % TODO
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
            [obj.z,obj.w] = Numerics.Contour.SemiCircle.quad(obj.gamma,obj.rho,obj.theta,obj.N,obj.qr);
        end
    end
    methods (Static)
        function [z,w] = quad(gamma,rho,theta,N,qr)
            arguments (Input)
                gamma   % center
                rho     % radius
                theta   % angle wrt real line
                N       % number of nodes on [arc;line segment]
                qr = "clencurt" % default quadrature rule on [-1,1]
            end
            arguments (Output)
                z       % nodes
                w       % weights
            end
            if qr == "clencurt"
                qr = @Numerics.Contour.clencurt;
            elseif qr == "gauss"
                qr = @Numerics.Contour.gauss;
            else
                error('Unsupported quadrature rule specified.');
            end
            % for the arc
            [zGamma,wGamma] = qr(N(1));
            wGamma = wGamma';
            qGamma = rho*exp(1i*((pi/2)*(zGamma+1) + theta));
            wGamma = ((pi*1i)/2)*qGamma.*wGamma;
            zGamma = gamma + qGamma;
            % for the line segment
            [zgamma,wgamma] = qr(N(2));
            wgamma = wgamma';
            cgamma = rho*exp(theta*1i);
            wgamma = cgamma*wgamma;
            zgamma = gamma + cgamma*zgamma;
            % putting it all together
            z = [zGamma; zgamma]; w = [wGamma; wgamma];
        end
    end
end
