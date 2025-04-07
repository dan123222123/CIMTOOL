classdef RealizationData < Numerics.VisualReactiveClass & matlab.mixin.Copyable

    properties (SetObservable)
        ComputationalMode
        InterpolationData
        RealizationSize
        ranktol
        auto_update_realization_size = true
        loaded = false
    end

    properties (Dependent)
        K
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.ComputationalMode,obj.m,obj.K,obj.ranktol);
            cp.InterpolationData = obj.InterpolationData;
            cp.loaded = obj.loaded;
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
            obj.ComputationalMode = ComputationalMode;
            if isempty(InterpolationData)
                obj.defaultInterpolationData();
            end
            m = max(length(obj.InterpolationData.theta),length(obj.InterpolationData.sigma));
            if isempty(RealizationSize)
                obj.RealizationSize = Numerics.RealizationSize(m,m,m);
            end
            obj.ranktol = ranktol;
            obj.ax = ax;
            obj.updateListeners();
            obj.RealizationDataChanged();
        end

        function value = get.K(obj)
            value = max(obj.RealizationSize.T1,obj.RealizationSize.T2);
        end

        function set.ComputationalMode(obj,value)
            obj.ComputationalMode = value;
            obj.defaultInterpolationData();
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.InterpolationDataChanged([],[]);
        end

        function set.ranktol(obj,value)
            obj.ranktol = value;
            obj.loaded = false;
        end

        function defaultInterpolationData(obj)
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    theta = []; sigma = Inf;
                case Numerics.ComputationalMode.SPLoewner
                    theta = []; sigma = 0;
                case Numerics.ComputationalMode.MPLoewner
                    theta = []; sigma = [];
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma);
        end

        function [theta,sigma] = getThetaSigma(obj,T1,T2)
            arguments
                obj
                T1 = length(obj.InterpolationData.theta)
                T2 = length(obj.InterpolationData.sigma)
            end
            theta = obj.InterpolationData.theta;
            sigma = obj.InterpolationData.sigma;
            if obj.ComputationalMode == Numerics.ComputationalMode.MPLoewner
                theta = theta(1:T1); sigma = sigma(1:T2);
            end
        end

        function plot(obj,ax,update_phandles)
            arguments
                obj
                ax = gca
                update_phandles = false
            end
            if isempty(ax); return; end
            % try to first get the next theta/sigma before clearing plots
            [theta,sigma] = obj.getThetaSigma(obj.RealizationSize.T1,obj.RealizationSize.T2);
            if update_phandles; obj.cla(); end
            hold(ax,"on");
            cphandles = gobjects(0);
            switch obj.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    % Nothing to plot
                case Numerics.ComputationalMode.SPLoewner
                    if ~isempty(sigma)
                        cphandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName","SPLoewner Shift",'Linewidth',1.5);
                    end
                case Numerics.ComputationalMode.MPLoewner
                    if ~isempty(sigma)
                        cphandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName","Right Interpolation Points",'Linewidth',1.5);
                    end
                    if ~isempty(theta)
                        cphandles(end+1) = scatter(ax,real(theta),imag(theta),50,"red","square","Tag","theta","DisplayName","Left Interpolation Points",'Linewidth',1.5);
                    end
            end
            hold(ax,"off");
            if update_phandles; obj.phandles = cphandles; end
        end

        function updateListeners(obj)
            addlistener(obj,'RealizationSize','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end
        
        function RealizationDataChanged(obj,~,~)
            obj.plot(obj.ax,true);
            obj.loaded = false;
        end

        function InterpolationDataChanged(obj,~,~)
            if ~isempty(obj.RealizationSize) && obj.auto_update_realization_size
                obj.RealizationSize = Numerics.RealizationSize(obj.RealizationSize.m,length(obj.InterpolationData.theta),length(obj.InterpolationData.sigma));
            end
            obj.RealizationDataChanged([],[]);
        end

        function update_plot(obj,~,~)
            obj.plot(obj.ax,true);
        end

    end

end
