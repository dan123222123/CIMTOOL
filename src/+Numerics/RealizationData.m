classdef RealizationData < matlab.mixin.Copyable

    properties (SetObservable)
        InterpolationData
        ComputationalMode
        K = 0;
        m = 0;
        ShiftScale = 1.25;
        tol = NaN
        loaded = false
        ax = []
    end

    properties
        phandles = gobjects(0);
    end

    methods(Access = protected)
        function cp = copyElement(obj)
            cp = Numerics.RealizationData(obj.InterpolationData.theta,obj.InterpolationData.sigma,obj.ComputationalMode,[]);
            cp.K = obj.K; cp.m = obj.m; cp.ShiftScale = obj.ShiftScale; cp.tol = obj.tol; cp.loaded = obj.loaded;
        end
    end

    methods

        function obj = RealizationData(theta,sigma,mode,ax)
            arguments
                theta = NaN
                sigma = Inf
                mode = Numerics.ComputationalMode.Hankel
                ax = []
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma);
            obj.ComputationalMode = mode;
            obj.ax = ax;
            if ~isempty(ax)
                obj.plot(ax); obj.ax = ax;
            end
            %addlistener(obj,'ComputationalMode','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'K','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'m','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'ShiftScale','PostSet',@obj.RealizationDataChanged);
            addlistener(obj,'tol','PostSet',@obj.RealizationDataChanged);
            % could store historical data in case the mode is changed back
            % and forth before computation?!?
            addlistener(obj,'InterpolationData','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function set.InterpolationData(obj,value)
            obj.InterpolationData = value;
            obj.loaded = false;
        end

        function RealizationDataChanged(obj,~,~)
            obj.loaded = false;
        end

        function plot(obj,ax)
            arguments
                obj
                ax = obj.ax
            end
            if isempty(ax)
                ax = gca;
            end
            if ~isempty(obj.phandles)
                obj.cla();
            end
            if ~isempty(ax)
                theta = obj.InterpolationData.theta;
                sigma = obj.InterpolationData.sigma;
                if obj.ComputationalMode ~= Numerics.ComputationalMode.Hankel
                    if obj.ComputationalMode == Numerics.ComputationalMode.SPLoewner
                        dn = "SPLoewner Shift";
                    else
                        dn = "Right Interpolation Points";
                    end
                    obj.phandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square","Tag","sigma","DisplayName",dn,'Linewidth',1.5);
                    hold(ax,"on");
                end
                if obj.ComputationalMode == Numerics.ComputationalMode.MPLoewner
                    obj.phandles(end+1) = scatter(ax,real(theta),imag(theta),50,"red","square","Tag","theta","DisplayName","Left Interpolation Points",'Linewidth',1.5);
                end
                hold(ax,"off");
            end
        end

        function cla(obj)
            for i=1:length(obj.phandles)
                  delete(obj.phandles(i));
            end
            obj.phandles = gobjects(0);
        end

        function update_plot(obj,~,~)
            obj.cla();
            if ~isempty(obj.ax)
                obj.plot(obj.ax);
            end
        end

    end

end
