classdef Quad < matlab.mixin.Copyable
    % Quad Generic contour
    %   Prototype/minimal contour specification, requiring only a
    %   quadrature and associated weights.

    properties
        phandles = gobjects(0); % array of graphics handles associated to this contour
    end

    properties (SetObservable)
        z (1,:) double = NaN        % quadrature nodes
        w (1,:) double = NaN        % quadrature weights
        ax             = []    % axis to manage plots on
    end

    methods

        function s = FindRandomShift(obj,scale)
            % Returns a random point outside of the convex hull of the
            % given Quad contour.
            % First, the maximum distance (d) between any quadrature node and
            % the geometric center (c) of the nodes is determined.
            % Then, the point is chosen to from the boundary of the circle
            % centered at c with radius d*scale.
            arguments
                obj 
                scale = 1.5 
            end
            c = sum(obj.z)/length(obj.z);
            d = max(abs(c - obj.z))*scale;
            r = randn(1,"like",1i); r = r/norm(r);
            s = c + r*d;
        end

        function obj = Quad(z,w,ax)
            arguments
                z
                w
                ax = []
            end
            obj.z = z;
            obj.w = w;
            obj.ax = ax;
            obj.phandles = gobjects(0);
            if ~isempty(ax)
                obj.plot(ax); obj.ax = ax; obj.update_plot();
            end
            addlistener(obj,'z','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function plot(obj,ax)
            arguments
                obj
                ax = obj.ax
            end
            if isempty(ax)
                ax = gca;
            end
            % if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.phandles)
                obj.cla();
            end
            obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature","DisplayName","Quadrature Nodes");
            obj.ax = ax;
        end

        function cla(obj)
            for i=1:length(obj.phandles)
                  delete(obj.phandles(i));
            end
            obj.phandles = gobjects(0);
        end

        function update_plot(obj,~,~)
            obj.cla();
            if ~isempty(obj.ax)
                obj.plot(obj.ax);
            end
        end

        function delete(obj)
            obj.cla();
        end

    end

end

