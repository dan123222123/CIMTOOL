classdef Quad < handle

    properties
        phandles = gobjects(0);
    end

    properties (SetObservable)
        z (1,:) double = NaN
        w (1,:) double = NaN
        ax = missing
    end

    methods

        function s = FindRandomShift(obj,scale)
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
                ax = missing
            end
            obj.z = z;
            obj.w = w;
            obj.ax = ax;
            obj.phandles = gobjects(0);
            if ~ismissing(ax)
                obj.plot(ax)
            end
            addlistener(obj,'z','PostSet',@obj.update_plot);
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
            obj.phandles(end+1) = scatter(ax,real(obj.z),imag(obj.z),200,"red","x",'Tag',"quadrature_nodes");
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
            if ~ismissing(obj.ax)
                obj.plot(obj.ax);
            end
        end

        function delete(obj)
            obj.cla();
        end

    end

end

