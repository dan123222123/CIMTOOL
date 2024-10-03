classdef CIM < handle
    
    properties (Access = public)
        DataDirtiness       = 2
        SampleData          Numerics.SampleData
        RealizationData     Numerics.RealizationData
        ResultData          Numerics.ResultData
    end

    properties (SetObservable)
        MainAx = missing
        SvAx = missing
        auto = false;
        auto_update_shifts = true;
    end
    
    methods

        function obj = CIM(nep,contour,MainAx,SvAx)
            arguments
                nep 
                contour 
                MainAx = missing
                SvAx = missing
            end
            obj.SampleData = Numerics.SampleData(nep,contour);
            % default to Hankel realization
            obj.RealizationData = Numerics.RealizationData(NaN,Inf,Numerics.ComputationalMode.Hankel,MainAx);
            obj.ResultData = Numerics.ResultData(MainAx,SvAx);
            obj.MainAx = MainAx;
            obj.SvAx = SvAx;
            obj.update_plot(missing,missing);
            addlistener(obj.SampleData,'loaded','PostSet',@obj.checkdirty);
            addlistener(obj.RealizationData,'loaded','PostSet',@obj.checkdirty);
            %
            addlistener(obj.RealizationData,'ComputationalMode','PostSet',@obj.update_shifts);
            addlistener(obj.RealizationData,'ShiftScale','PostSet',@obj.update_shifts);
            addlistener(obj.RealizationData,'K','PostSet',@obj.update_shifts);
            addlistener(obj.SampleData.Contour,'z','PostSet',@obj.update_shifts);


            addlistener(obj,'MainAx','PostSet',@obj.update_plot);
        end

        function update_shifts(obj,src,~)
            if (src.Name == "z" || src.Name == "K") && ~obj.auto_update_shifts
                return;
            end
            switch obj.RealizationData.ComputationalMode
                case Numerics.ComputationalMode.Hankel
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,Inf);
                case Numerics.ComputationalMode.SPLoewner
                    obj.RealizationData.InterpolationData = Numerics.InterpolationData(NaN,FindRandomShift(obj.SampleData.Contour));
                case Numerics.ComputationalMode.MPLoewner
                    obj.interlevedshifts();
            end
        end

        % using the underlying quadrature
        % determine the geometric center and the maximum distance
        % between the center and a quadrature node.
        % then scale that distance and interleve the nodes on a 
        % circle with geo center and max_dist*scale
        function interlevedshifts(obj)
            z = obj.SampleData.Contour.z;
            nsw = obj.RealizationData.K;
            % get the geometric center
            c = sum(z)/length(z);
            % get the maximum distance between c and quad nodes
            r = max(abs(c - z));
            % nodes on a circle around the current quad nodes
            z = Contour.Circle.trapezoid(c,r*obj.RealizationData.ShiftScale,2*nsw);
            theta = double.empty();
            sigma = double.empty();
            for i=1:length(z)
                if mod(i,2) == 1
                    theta(end+1) = z(i);
                else
                    sigma(end+1) = z(i);
                end
            end
            theta = theta.';
            sigma = sigma.';
            obj.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
        end

        function update_plot(obj,~,~)
            if ~ismissing(obj.MainAx)
                ax = obj.MainAx;
                hold(ax,"on");
                obj.SampleData.ax = ax;
                obj.RealizationData.ax = ax;
                obj.ResultData.MainAx = ax;
            end

            if ~ismissing(obj.SvAx)
                ax = obj.SvAx;
                hold(ax,"on");
                obj.ResultData.SvAx = ax;
            end
        end

        function checkdirty(obj,~,~)
            if ~obj.SampleData.loaded
                obj.DataDirtiness = 2;
            elseif ~obj.RealizationData.loaded
                obj.DataDirtiness = 1;
            else
                obj.DataDirtiness = 0;
            end
            if obj.auto
                obj.compute();
            end
        end

        function compute(obj)
            obj.SampleData.compute();
            switch(obj.RealizationData.ComputationalMode)
                case {Numerics.ComputationalMode.Hankel,Numerics.ComputationalMode.SPLoewner}
                    [obj.ResultData.ew,obj.ResultData.ev,obj.ResultData.Dbsw,obj.ResultData.Dssw,obj.ResultData.Db,obj.ResultData.Ds] = Numerics.sploewner( ...
                        obj.SampleData.Qlr, ...
                        obj.SampleData.Qr, ...
                        obj.RealizationData.InterpolationData.sigma(1), ...
                        obj.SampleData.Contour.z, ...
                        obj.SampleData.Contour.w, ...
                        obj.RealizationData.m, ...
                        obj.RealizationData.K, ...
                        obj.RealizationData.tol ...
                    );
                case Numerics.ComputationalMode.MPLoewner
                    [obj.ResultData.ew,obj.ResultData.ev,obj.ResultData.Dbsw,obj.ResultData.Dssw,obj.ResultData.Db,obj.ResultData.Ds] = Numerics.mploewner( ...
                        obj.SampleData.Ql, ...
                        obj.SampleData.Qr, ...
                        obj.RealizationData.InterpolationData.theta, ...
                        obj.RealizationData.InterpolationData.sigma, ...
                        obj.SampleData.L, ...
                        obj.SampleData.R, ...
                        obj.SampleData.Contour.z, ...
                        obj.SampleData.Contour.w, ...
                        obj.RealizationData.m, ...
                        obj.RealizationData.tol ...
                    );
            end
            obj.RealizationData.loaded = true;
        end
    end
end

