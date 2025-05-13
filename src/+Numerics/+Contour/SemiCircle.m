classdef SemiCircle < Numerics.Contour.Quad
% Circular contour specified by a center `gamma`, radius `rho`, and number of quadrature nodes `N`.
    properties (SetObservable)
        gamma   (1,1) double % center
        rho     (1,1) double % radius
        theta   (1,1) double % angle wrt real line
        N1      (1,1) double % number of nodes on arc
        N2      (1,1) double % number of nodes on line segment
    end
    properties (Dependent)
        N
    end
    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.Contour.SemiCircle(obj.gamma,obj.rho,obj.theta,obj.N1,obj.N2);
        end
    end
    methods
        function val = get.N(obj)
            val = obj.N1 + obj.N2;
        end
        function set.N(obj,val)
            obj.N1 = val; obj.N2 = val;
        end
        function obj = SemiCircle(gamma,rho,theta,N1,N2)
            arguments
                gamma = 0
                rho = 1
                theta = 0
                N1 = 8
                N2 = N1
            end
            [z,w] = Numerics.Contour.SemiCircle.quad(gamma,rho,theta,N1,N2);
            obj@Numerics.Contour.Quad(z,w);
            obj.gamma = gamma; obj.rho = rho; obj.theta = theta;
            obj.N1 = N1; obj.N2 = N2;
            addlistener(obj,'gamma','PostSet',@obj.update);
            addlistener(obj,'rho','PostSet',@obj.update);
            addlistener(obj,'theta','PostSet',@obj.update);
            addlistener(obj,'N1','PostSet',@obj.update);
            addlistener(obj,'N2','PostSet',@obj.update);
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
            [obj.z,obj.w] = Numerics.Contour.SemiCircle.quad(obj.gamma,obj.rho,obj.theta,obj.N1,obj.N2);
        end
    end
    methods (Static)
        function [z,w] = quad(gamma,rho,theta,N1,N2)
            arguments (Input)
                gamma   % center
                rho     % radius
                theta   % angle wrt real line
                N1      % number of nodes on arc
                N2=N1   % number of nodes on line segment
            end
            arguments (Output)
                z       % nodes
                w       % weights
            end
            % for the arc
            [zGamma,wGamma] = Numerics.Contour.clencurt(N1);
            wGamma = wGamma';
            qGamma = rho*exp(1i*((pi/2)*(zGamma+1) + theta));
            wGamma = ((pi*1i)/2)*qGamma.*wGamma;
            zGamma = gamma + qGamma;
            % for the line segment
            [zgamma,wgamma] = Numerics.Contour.clencurt(N2);
            wgamma = wgamma';
            cgamma = rho*exp(theta*1i);
            wgamma = cgamma*wgamma;
            zgamma = gamma + cgamma*zgamma;
            % putting it all together
            z = [zGamma; zgamma]; w = [wGamma; wgamma];
        end
    end
end
