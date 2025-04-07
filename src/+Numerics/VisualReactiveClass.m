classdef VisualReactiveClass < handle

    properties (SetObservable)
        ax = [];
    end

    properties
        phandles = gobjects(0); % array of graphics handles associated to this contour
    end

    methods (Abstract)
        plot(obj);
    end

    methods

        function cla(obj)
            for i=1:length(obj.phandles)
                cgo = obj.phandles(i);
                if isgraphics(cgo)
                    delete(cgo);
                end
            end
            obj.phandles = gobjects(0);
        end

        function update_plot(obj,~,~)
            obj.plot(obj.ax,true);
        end

    end

end