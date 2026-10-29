classdef OperatorData <  Numerics.OperatorData & Visual.VisualReactive

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = copyElement@Numerics.OperatorData(obj);
          cp.ax = obj.ax;
      end

      function reattachListeners(obj)
          reattachListeners@Numerics.OperatorData(obj);
          obj.forgetGraphics();
          obj.attachListeners();
      end
   end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.OperatorData from a Numerics.OperatorData.
            arguments
                n Numerics.OperatorData
                ax = []
            end
            v = Visual.OperatorData();
            v.ax = ax;
            Visual.copyMatchingProperties(n, v, "loaded");
            v.ReferenceStatus = Numerics.OperatorData.settledStatus(n.ReferenceStatus);
            v.loaded = n.loaded;   % set last — fires listeners that depend on it
        end
    end

    methods

        function obj = OperatorData(T,name,arglist,ax)
            arguments
                T = []
                name = []
                arglist = []
                ax = []
            end
            obj = obj@Numerics.OperatorData(T,name,arglist);
            obj.ax = ax;
            % Store listener handle so it can be deleted later
            obj.listeners = addlistener(obj,'refew','PostSet',@obj.update_plot);
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.OperatorData.
            n = Numerics.OperatorData();
            Visual.copyMatchingProperties(obj, n, "loaded");
            n.ReferenceStatus = Numerics.OperatorData.settledStatus(obj.ReferenceStatus);
            n.loaded = obj.loaded;
        end

        function attachListeners(obj)
            % Recreate listeners (called when reattaching to new graphics)
            obj.deleteListeners();  % Clear any existing listeners first
            obj.listeners = addlistener(obj,'refew','PostSet',@obj.update_plot);
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = Visual.emptyHandles();
            if isempty(ax) || ~isgraphics(ax); return; end
            hold(ax,"on");
            if ~isempty(obj.refew)
                sp = obj.StylePreferences;
                phandles(end+1) = scatter(ax, real(obj.refew), imag(obj.refew), ...
                    sp.ReferenceEigenvalueSize, sp.ReferenceEigenvalueMarker, ...
                    "MarkerEdgeColor", sp.ReferenceEigenvalueColor, ...
                    "LineWidth", sp.ReferenceEigenvalueLineWidth, ...
                    'Tag', "reference_eigenvalues", ...
                    "DisplayName", "Reference Eigenvalues");
            end
            hold(ax,"off");
        end

    end

end

