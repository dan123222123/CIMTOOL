classdef SampleData < Numerics.SampleData & Visual.VisualReactive

    methods (Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.SampleData(obj);
            cp.ax = obj.ax; cp.update_plot();
        end

        function reattachListeners(obj)
            reattachListeners@Numerics.SampleData(obj);
            obj.forgetGraphics();
            obj.addPlotListeners();
        end
    end

    methods (Access = private)
        function addPlotListeners(obj)
            obj.deleteListeners();
            obj.listeners = obj.partListeners(["OperatorData","Contour"]);
        end
    end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.SampleData from a Numerics.SampleData.
            arguments
                n Numerics.SampleData
                ax = []
            end
            if n.OperatorData.loaded; n.drawDirections(); end
            v_op      = Visual.OperatorData.fromNumerics(n.OperatorData, ax);
            v_contour = Visual.Contour.Quad.fromNumerics(n.Contour, ax);
            v = Visual.SampleData(v_op, v_contour, n.ell, n.r, ax);
            % Copy remaining primitive properties (Lf, Rf, Ql, Qr, Qlr, show_progress).
            % Exclude OperatorData/Contour (already converted above), ell/r (passed to
            % constructor), and loaded (must be set last to avoid spurious dirty state).
            Visual.copyMatchingProperties(n, v, ["OperatorData","Contour","ell","r","loaded"]);
            v.loaded = n.loaded;   % set last
        end
    end

    methods

        function obj = SampleData(OperatorData,Contour,ell,r,ax)
            arguments
                OperatorData = Visual.OperatorData()
                Contour = Visual.Contour.Quad.empty
                ell = OperatorData.n
                r = OperatorData.n
                ax = []
            end
            obj = obj@Numerics.SampleData(OperatorData,Contour,ell,r);
            obj.ax = ax; obj.update_plot([],[]);
            obj.addPlotListeners();
        end

        function attachListeners(obj)
            % Recreate listeners recursively (called when reattaching to new graphics)
            obj.addPlotListeners();
            % Attach listeners on children too
            if ~isempty(obj.Contour) && isvalid(obj.Contour)
                obj.Contour.attachListeners();
            end
            if ~isempty(obj.OperatorData) && isvalid(obj.OperatorData)
                obj.OperatorData.attachListeners();
            end
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.SampleData.
            if obj.OperatorData.loaded; obj.drawDirections(); end   % as copy: the conversion shares the source's directions
            n_op      = obj.OperatorData.toNumerics();
            n_contour = obj.Contour.toNumerics();
            n = Numerics.SampleData(n_op, n_contour, obj.ell, obj.r);
            Visual.copyMatchingProperties(obj, n, ["OperatorData","Contour","ell","r","loaded"]);
            n.loaded = obj.loaded;
        end

        function update_plot(obj,~,~)
            % Propagate StylePreferences and axes to children
            % Skip if object or children are invalid
            try
                if ~isvalid(obj)
                    return;
                end
                obj.cla();
                if ~isempty(obj.Contour) && isvalid(obj.Contour)
                    obj.Contour.StylePreferences = obj.StylePreferences;
                    obj.Contour.ax = obj.ax;
                end
                if ~isempty(obj.OperatorData) && isvalid(obj.OperatorData)
                    obj.OperatorData.StylePreferences = obj.StylePreferences;
                    obj.OperatorData.ax = obj.ax;
                end
                obj.phandles = [obj.Contour.phandles obj.OperatorData.phandles];
            catch
                % Ignore errors during cleanup
            end
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = Visual.emptyHandles();
            if isempty(ax); return; end
            if ~isempty(obj.Contour)
                phandles = [phandles obj.Contour.plot(ax)];
            end
            phandles = [phandles obj.OperatorData.plot(ax)];
        end

        function detachFromGraphics(obj)
            % Detach from graphics and remove all listeners recursively
            try
                % Detach children first
                if ~isempty(obj.Contour) && isvalid(obj.Contour)
                    obj.Contour.detachFromGraphics();
                end
                if ~isempty(obj.OperatorData) && isvalid(obj.OperatorData)
                    obj.OperatorData.detachFromGraphics();
                end

                % Call parent detach
                detachFromGraphics@Visual.VisualReactive(obj);
            catch
                % Ignore errors during cleanup
            end
        end

    end

end
