classdef RealizationData < Numerics.RealizationData & Visual.VisualReactive

    methods(Access = protected)
      function cp = copyElement(obj)
          cp = copyElement@Numerics.RealizationData(obj);
          cp.ax = obj.ax;
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
            hold(ax,"on");
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    % Nothing to plot
                case Numerics.ComputationalMode.SPLoewner
                    if ~isempty(sigma)
                        phandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName","SPLoewner Shift",'Linewidth',1.5);
                    end
                case Numerics.ComputationalMode.MPLoewner
                    if ~isempty(sigma)
                        phandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName","Right Interpolation Points",'Linewidth',1.5);
                    end
                    if ~isempty(theta)
                        phandles(end+1) = scatter(ax,real(theta),imag(theta),50,"red","square","Tag","theta","DisplayName","Left Interpolation Points",'Linewidth',1.5);
                    end
            end
            hold(ax,"off");
        end

        function RealizationDataChanged(obj,~,~)
            obj.update_plot([],[]);
            RealizationDataChanged@Numerics.RealizationData(obj,[],[]);
        end

    end
end
