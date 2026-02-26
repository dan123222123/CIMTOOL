classdef VisualReactive < handle

    properties (Access = public, SetObservable)
        ax = []
        StylePreferences = Visual.StylePreferences()
    end

    properties
        phandles = gobjects(0)
    end

    properties (Access = protected)
        % Store listener handles so they can be cleaned up without deleting object
        listeners = []
    end

    methods (Abstract)
        phandles = plot(obj,ax);
    end

    methods

        function set.ax(obj,value)
            obj.ax = value;
            % Only update plot if object is still valid
            try
                if isvalid(obj)
                    obj.update_plot([],[]);
                end
            catch
                % Ignore errors during deletion
            end
        end

        function set.StylePreferences(obj,value)
            obj.StylePreferences = value;
            % Only update plot if object is still valid
            try
                if isvalid(obj)
                    obj.update_plot([],[]);
                end
            catch
                % Ignore errors during deletion
            end
        end

        function cla(obj)
            % Clear graphics handles - skip if already invalid
            try
                for i=1:length(obj.phandles)
                    cgo = obj.phandles(i);
                    if isgraphics(cgo)
                        delete(cgo);
                    end
                end
                obj.phandles = gobjects(0);
            catch
                % Graphics already deleted - just clear the array
                obj.phandles = gobjects(0);
            end
        end

        function update_plot(obj,~,~)
            % Skip update if object is being deleted or axes are invalid
            try
                if ~isvalid(obj)
                    return;
                end
                obj.cla();
                obj.phandles = [obj.phandles obj.plot(obj.ax)];
            catch ME
                % Ignore errors during cleanup/deletion
                % Common when listeners fire after graphics are deleted
                if ~contains(ME.message, 'deleted')
                    rethrow(ME);  % Re-throw unexpected errors
                end
            end
        end

        function detachFromGraphics(obj)
            % Detach from graphics and remove listeners without deleting the object
            % This allows the object to be reused later with a new GUI
            try
                % Clear graphics handles
                obj.cla();

                % Clear axes reference
                obj.ax = [];

                % Delete all listeners to prevent them from firing
                obj.deleteListeners();
            catch
                % Ignore errors during cleanup
            end
        end

        function deleteListeners(obj)
            % Delete all stored listeners
            % Subclasses should override to delete their specific listeners
            Visual.deleteListeners(obj.listeners);
            obj.listeners = [];
        end

        function attachListeners(obj)
            % Attach/recreate listeners
            % Subclasses should override to recreate their specific listeners
            % Base class has no listeners to attach
        end

        function delete(obj)
            % Clean up when object is actually being deleted
            try
                if isvalid(obj)
                    obj.detachFromGraphics();
                end
            catch
                % Object already deleted or in invalid state - ignore
            end
        end

    end

end