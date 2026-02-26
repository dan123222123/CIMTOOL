classdef ResultData < Numerics.ResultData & Visual.VisualReactive

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = copyElement@Numerics.ResultData(obj);
          cp.ax = obj.ax;
      end
   end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.ResultData from a Numerics.ResultData.
            arguments
                n Numerics.ResultData
                ax = []
            end
            v = Visual.ResultData();
            v.ax = ax;
            Visual.copyMatchingProperties(n, v);
        end
    end

    methods
        function obj = ResultData(Db,Ds,B,BB,C,CC,X,Sigma,Y,ew,rev,lev,ax)
            arguments
                Db      = []
                Ds      = []
                B       = []
                BB      = []
                C       = []
                CC      = []
                X       = []
                Sigma   = []
                Y       = []
                ew      = []
                rev     = []
                lev     = []
                ax      = []
            end
            obj = obj@Numerics.ResultData(Db,Ds,B,BB,C,CC,X,Sigma,Y,ew,rev,lev);
            obj.ax = ax;
            % Store listener handles so they can be deleted later
            obj.listeners = [
                addlistener(obj,'ew','PostSet',@obj.update_plot)
                addlistener(obj,'Sigma','PostSet',@obj.update_plot)
            ];
        end

        function attachListeners(obj)
            % Recreate listeners (called when reattaching to new graphics)
            obj.deleteListeners();  % Clear any existing listeners first
            obj.listeners = [
                addlistener(obj,'ew','PostSet',@obj.update_plot)
                addlistener(obj,'Sigma','PostSet',@obj.update_plot)
            ];
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.ResultData.
            n = Numerics.ResultData();
            Visual.copyMatchingProperties(obj, n);
        end

        function phandles = plot_eigenvalues(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            hold(ax,"on");
            if ~isempty(obj.ew)
                sp = obj.StylePreferences;
                phandles(end+1) = scatter(ax, real(obj.ew), imag(obj.ew), ...
                    sp.ComputedEigenvalueSize, sp.ComputedEigenvalueMarker, ...
                    "MarkerFaceColor", sp.ComputedEigenvalueColor, ...
                    "LineWidth", sp.ComputedEigenvalueLineWidth, ...
                    'Tag', "computed_eigenvalues", ...
                    "DisplayName", "Computed Eigenvalues");
            end
            hold(ax,"off");
        end

        function phandles = plot_singularvalues(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            hold(ax,"on");
            if ~isempty(obj.Sigma)
                sp = obj.StylePreferences;
                Dbsw = diag(obj.Sigma) / obj.Sigma(1,1);
                phandles(end+1) = semilogy(ax, 1:length(Dbsw), Dbsw, ...
                    sp.SingularValueLineStyle, ...
                    "MarkerSize", sp.SingularValueMarkerSize, ...
                    'DisplayName', 'Base Data Matrix (Db)', ...
                    'Color', sp.SingularValueColor);
                ax.XLim = [0,length(Dbsw)+1];
            end
            hold(ax,"off");
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax); return; end % assumed that ax is a cell array of axes henceforth
            if ~iscell(ax); ax = num2cell(ax); end
            if isgraphics(ax{1}); phandles = [phandles obj.plot_eigenvalues(ax{1})]; end
            if length(ax) > 1 && isgraphics(ax{2}) % only update the singular value plot if we are given a second axis
                phandles = [phandles obj.plot_singularvalues(ax{2})];
            end
        end

    end

end
