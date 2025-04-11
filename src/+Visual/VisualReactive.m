classdef VisualReactive < handle

    properties (SetObservable)
        ax = []
    end

    properties
        phandles = gobjects(0)
    end

    methods (Abstract)
        phandles = plot(obj,ax);
    end

    methods

        function set.ax(obj,value)
            obj.ax = value;
            obj.update_plot([],[]);
        end

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
            obj.cla(); obj.phandles = obj.plot(obj.ax);
        end

        function delete(obj)
            obj.cla();
        end

    end

end