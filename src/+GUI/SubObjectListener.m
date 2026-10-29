classdef SubObjectListener < handle
% A PostSet listener on a property of an object reached from a root through a property path,
% such as Prop of cim.SampleData.Contour for the path "SampleData.Contour".
% When any object along the path is replaced, the listener moves to the new object and the
% callback runs once, so a GUI component that reads the current object stays in sync.
% An empty path listens on the root itself. A target without the property gets no listener until a
% replacement brings one that has it; the callback then still runs once and must handle that case.
%
% Usage:
%   l = GUI.SubObjectListener(cim, "SampleData.Contour", 'N', @(~,~) comp.QuadratureChangedFcn([]));
%   delete(l);   % removes every listener it holds

    properties (SetAccess = private)
        Root
        Path        string = string.empty   % property names from Root to the listened object
        Property    char
        Callback    function_handle
    end

    properties (Access = private)
        PathListeners   = event.proplistener.empty
        Listener        = event.proplistener.empty
    end

    methods
        function obj = SubObjectListener(root, path, prop, callback)
            arguments
                root (1,1) handle
                path (1,1) string
                prop (1,:) char
                callback (1,1) function_handle
            end
            obj.Root = root;
            if strlength(path) > 0
                obj.Path = split(path, ".").';
            end
            obj.Property = prop;
            obj.Callback = callback;
            obj.wire();
        end

        function delete(obj)
            obj.unwire();
        end
    end

    methods (Access = private)
        function wire(obj)
            obj.unwire();
            target = obj.Root;
            for p = obj.Path
                obj.PathListeners(end+1) = addlistener(target, char(p), 'PostSet', @(~,~) obj.replaced());
                target = target.(p);
            end
            % a target without the property (a plain Quad contour has no N) gets no listener;
            % the path listeners stay, so a later replacement that has it is followed again
            if isprop(target, obj.Property)
                obj.Listener = addlistener(target, obj.Property, 'PostSet', obj.Callback);
            end
        end

        function unwire(obj)
            delete(obj.PathListeners(isvalid(obj.PathListeners)));
            delete(obj.Listener(isvalid(obj.Listener)));
            obj.PathListeners = event.proplistener.empty;
            obj.Listener = event.proplistener.empty;
        end

        function replaced(obj)
            obj.wire();
            obj.Callback([], []);
        end
    end
end
