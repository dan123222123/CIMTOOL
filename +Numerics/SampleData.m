classdef SampleData < handle

    properties
        Ql      (:,:,:) double = missing
        Qr      (:,:,:) double = missing
        Qlr     (:,:,:) double = missing
        % s* properties can be used in sample to re-use any of the info in
        % Ql/Qr/Qlr if info was valid during the prior sampling
        sT = missing
        squad = missing
        sL = missing
        sR = missing
    end
    
    properties (SetObservable)
        ell     (1,1) double
        r       (1,1) double
        Lf       (:,:) double
        Rf       (:,:) double
        loaded  = false
        ax = missing
    end

    properties (SetObservable,Access = public)
        NLEVP
        Contour
    end

    properties (Dependent)
        L
        R
    end
    
    methods

        function obj = SampleData(NLEVP,Contour,ell,r)
            arguments
                NLEVP
                Contour
                ell = min(NLEVP.n,10)
                r = min(NLEVP.n,10)
            end
            obj.NLEVP = NLEVP;
            obj.Contour = Contour;
            obj.ell = ell;
            obj.r = r;
            addlistener(obj.NLEVP,'loaded','PostSet',@obj.NLEVPChanged);
            addlistener(obj.Contour,'z','PostSet',@obj.ContourChanged);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function update_plot(obj,~,~)
            hold(obj.ax,"on");
            obj.Contour.ax = obj.ax;
            obj.NLEVP.ax = obj.ax;
        end

        function NLEVPChanged(obj,~,~)
            if obj.NLEVP.loaded
                nold = size(obj.Lf,1);
                n = obj.NLEVP.n;
                if n ~= nold
                    obj.Lf = Numerics.SampleData.sampleMatrix(n,obj.ell);
                    obj.Rf = Numerics.SampleData.sampleMatrix(n,obj.r);
                end
                obj.ell = min(obj.ell,n);
                obj.r = min(obj.r,n);
                obj.sT = missing;
                obj.sL = missing;
                obj.sR = missing;
                obj.squad = missing;
                obj.loaded = false;
            end
        end

        function ContourChanged(obj,~,~)
            obj.loaded = false;
        end

        function value = get.L(obj)
            maxsize = size(obj.Lf,2);
            value = obj.Lf(:,1:min(obj.ell,maxsize));
        end

        function value = get.R(obj)
            maxsize = size(obj.Rf,2);
            value = obj.Rf(:,1:min(obj.r,maxsize));
        end

        function set.ell(obj,value)
            Lsize = size(obj.Lf,2);
            if value ~= Lsize % don't mess with Lf if it was set first and ell is being updated to match it
                if value > obj.ell
                    Lnew = Numerics.SampleData.sampleMatrix(obj.NLEVP.n,value-obj.ell);
                    obj.Lf = [obj.Lf,Lnew];
                else
                    obj.Lf = obj.Lf(:,1:value);
                end
            end
            obj.ell = value;
            obj.loaded = false;
        end

        function set.r(obj,value)
            Rsize = size(obj.Rf,2);
            if value ~= Rsize % don't mess with Rf if it was set first and r is being updated to match it
                if value > obj.r
                    Rnew = Numerics.SampleData.sampleMatrix(obj.NLEVP.n,value-obj.r);
                    obj.Rf = [obj.Rf,Rnew];
                else
                    obj.Rf = obj.Rf(:,1:value);
                end
            end
            obj.r = value;
            obj.loaded = false;
        end

        function set.L(obj,value)
            obj.Lf = value;
            obj.ell = size(value,2);
        end

        function set.R(obj,value)
            obj.Rf = value;
            obj.r = size(value,2);
        end

        function compute(obj)
            if ismissing(obj.Contour)
                error("Contour data required to sample %s. Please set a contour and try again.",obj.NLEVP.name);
            end
            if ~obj.loaded
                % seems possible to compare sT,sL,sR,squad BEFORE sampling
                % save some work if possible!
                [obj.Ql,obj.Qr,obj.Qlr] = Numerics.samplequadrature(obj.NLEVP.T,obj.Lf,obj.Rf,obj.Contour.z);
                obj.squad = obj.Contour.z;
                obj.sL = obj.Lf;
                obj.sR = obj.Rf;
                obj.sT = obj.NLEVP.T;
                obj.loaded = true;
            end
        end

    end

    methods (Static)

        function M = sampleMatrix(n,d)
            M = randn(n,d);
        end

    end

end

