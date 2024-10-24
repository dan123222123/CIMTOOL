classdef RealizationData < handle
    
    properties (SetObservable)
        InterpolationData
        ComputationalMode
        K = 0;
        m = 0;
        ShiftScale = 1.25;
        tol = NaN
        loaded = false
        ax = missing
    end

    properties
        phandles = gobjects(0);
    end

    methods

        function obj = RealizationData(theta,sigma,mode,ax)
            arguments
                theta = NaN
                sigma = Inf
                mode = Numerics.ComputationalMode.Hankel
                ax = missing
            end
            obj.InterpolationData = Numerics.InterpolationData(theta,sigma);
            obj.ComputationalMode = mode;
            obj.ax = ax;
            if ~ismissing(ax)
                obj.plot(ax)
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
            if ismissing(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.phandles)
                obj.cla();
            end
            if ~any(ismissing(obj.ax))
                chold = ishold(ax);
                theta = obj.InterpolationData.theta;
                sigma = obj.InterpolationData.sigma;
                obj.phandles(end+1) = scatter(ax,real(sigma),imag(sigma),50,"blue","square");
                hold(ax,"on");
                obj.phandles(end+1) = scatter(ax,real(theta),imag(theta),50,"red","square");
                hold(ax,chold);
            end
            obj.ax = ax;
        end

        function cla(obj)
            for i=1:length(obj.phandles)
                  delete(obj.phandles(i));
            end
            obj.phandles = gobjects(0);
        end

        function update_plot(obj,~,~)
            obj.cla();
            if ~ismissing(obj.ax)
                obj.plot(obj.ax);
            end
        end

    end

end

