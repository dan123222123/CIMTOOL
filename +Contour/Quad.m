classdef Quad < handle

    properties
        z (1,:) double = NaN
        w (1,:) double = NaN
        phandles = gobjects(0);
    end

    properties (SetObservable)
        changed = false
        ax = missing
    end

    methods

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
            hold(ax,"on");
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

