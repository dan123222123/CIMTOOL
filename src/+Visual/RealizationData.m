classdef RealizationData < Numerics.RealizationData & Visual.VisualReactive

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = copyElement@Numerics.RealizationData(obj);
          cp.ax = obj.ax;
      end
   end

    methods (Static)
        function v = fromNumerics(n, ax)
            % FROMNUMERICS Construct a Visual.RealizationData from a Numerics.RealizationData.
            arguments
                n Numerics.RealizationData
                ax = []
            end
            v = Visual.RealizationData();
            v.ax = ax;
            Visual.copyMatchingProperties(n, v, "loaded");
            v.loaded = n.loaded;   % set last — fires listeners that depend on it
        end
    end

    methods

        function obj = RealizationData(ComputationalMode,InterpolationData,RealizationSize,ranktol,ax)
            arguments
                ComputationalMode = Numerics.ComputationalMode.Hankel
                InterpolationData = []
                RealizationSize = []
                ranktol = NaN
                ax = []
            end
            obj = obj@Numerics.RealizationData(ComputationalMode,InterpolationData,RealizationSize,ranktol);
            obj.ax = ax;
            obj.RealizationDataChanged();
            % Store listener handles so they can be deleted later
            obj.listeners = [
                addlistener(obj,'ComputationalMode','PostSet',@obj.update_plot)
                addlistener(obj,'InterpolationData','PostSet',@obj.update_plot)
                addlistener(obj,'RealizationSize','PostSet',@obj.update_plot)
            ];
        end

        function attachListeners(obj)
            % Recreate listeners (called when reattaching to new graphics)
            obj.deleteListeners();  % Clear any existing listeners first
            obj.listeners = [
                addlistener(obj,'ComputationalMode','PostSet',@obj.update_plot)
                addlistener(obj,'InterpolationData','PostSet',@obj.update_plot)
                addlistener(obj,'RealizationSize','PostSet',@obj.update_plot)
            ];
        end

        function n = toNumerics(obj)
            % TONUMERICS Strip visual state and return a Numerics.RealizationData.
            n = Numerics.RealizationData();
            Visual.copyMatchingProperties(obj, n, "loaded");
            n.loaded = obj.loaded;
        end

        function phandles = plot(obj,ax)
            arguments
                obj
                ax = gca
            end
            phandles = gobjects(0);
            if isempty(ax) || ~isgraphics(ax); return; end
            % try to first get the next theta/sigma before clearing plots
            [theta,sigma] = obj.getThetaSigma(obj.RealizationSize.T1,obj.RealizationSize.T2);
            sp = obj.StylePreferences;
            hold(ax,"on");
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    % Nothing to plot
                case Numerics.ComputationalMode.SPLoewner
                    if ~isempty(sigma)
                        phandles(end+1) = scatter(ax, real(sigma), imag(sigma), ...
                            sp.SPLoewnerShiftSize, sp.SPLoewnerShiftMarker, ...
                            "MarkerEdgeColor", sp.SPLoewnerShiftColor, ...
                            "LineWidth", sp.SPLoewnerShiftLineWidth, ...
                            "Tag", "sigma", ...
                            "DisplayName", "SPLoewner Shift");
                    end
                case Numerics.ComputationalMode.MPLoewner
                    if ~isempty(sigma)
                        phandles(end+1) = scatter(ax, real(sigma), imag(sigma), ...
                            sp.MPLoewnerRightSize, sp.MPLoewnerRightMarker, ...
                            "MarkerEdgeColor", sp.MPLoewnerRightColor, ...
                            "LineWidth", sp.MPLoewnerRightLineWidth, ...
                            "Tag", "sigma", ...
                            "DisplayName", "Right Interpolation Points");
                    end
                    if ~isempty(theta)
                        phandles(end+1) = scatter(ax, real(theta), imag(theta), ...
                            sp.MPLoewnerLeftSize, sp.MPLoewnerLeftMarker, ...
                            "MarkerEdgeColor", sp.MPLoewnerLeftColor, ...
                            "LineWidth", sp.MPLoewnerLeftLineWidth, ...
                            "Tag", "theta", ...
                            "DisplayName", "Left Interpolation Points");
                    end
            end
            hold(ax,"off");
        end

        function RealizationDataChanged(obj,~,~)
            RealizationDataChanged@Numerics.RealizationData(obj,[],[]);
            obj.update_plot([],[]);
        end

    end
end
