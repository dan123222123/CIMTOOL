classdef SampleData < Numerics.SampleData & Visual.VisualReactive

    methods (Access = protected)
        function cp = copyElement(obj)
            cp = copyElement@Numerics.SampleData(obj);
            cp.ax = obj.ax; cp.update_plot();
        end
    end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.SampleData from a Numerics.SampleData.
            arguments
                n Numerics.SampleData
                ax = []
            end
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
                Contour = Visual.Contour.Circle()
                ell = OperatorData.n
                r = OperatorData.n
                ax = []
            end
            obj = obj@Numerics.SampleData(OperatorData,Contour,ell,r);
            obj.ax = ax; obj.update_plot([],[]);
            addlistener(obj,'OperatorData','PostSet',@obj.update_plot);
            addlistener(obj,'Contour','PostSet',@obj.update_plot);
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.SampleData.
            n_op      = obj.OperatorData.toNumerics();
            n_contour = obj.Contour.toNumerics();
            n = Numerics.SampleData(n_op, n_contour, obj.ell, obj.r);
            Visual.copyMatchingProperties(obj, n, ["OperatorData","Contour","ell","r","loaded"]);
            n.loaded = obj.loaded;
        end

        function update_plot(obj,~,~)
            obj.Contour.ax = obj.ax; obj.OperatorData.ax = obj.ax;
            obj.phandles = [obj.Contour.phandles obj.OperatorData.phandles];
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax); return; end
            phandles = [phandles obj.Contour.plot(ax)];
            phandles = [phandles obj.OperatorData.plot(ax)];
        end

    end

end
