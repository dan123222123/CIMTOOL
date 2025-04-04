classdef SampleData < matlab.mixin.Copyable

    properties
        Ql      (:,:,:) double = [] % Left Quadrature Samples
        Qr      (:,:,:) double = [] % Right Quadrature Samples
        Qlr     (:,:,:) double = [] % Two-Sided Quadrature Samples
    end
    
    properties (SetObservable)
        ell      (1,1) double       % # of left directions
        r        (1,1) double       % # of right directions
        Lf       (:,:) double       % "full" matrix of left directions
        Rf       (:,:) double       % "full" matrix of right directions
    end

    properties (SetObservable)
        loaded = false              % internal/broadcasted state of SampleData
        show_progress = true        % progress bar toggle -- only works for serial/Process-based pools
        ax = []                     % internal tracking of axes associated with SampleData
    end

    properties (SetObservable,Access = public)
        NLEVPData   Numerics.NLEVPData
        Contour     Numerics.Contour.Quad
    end

    properties (Dependent)
        L
        R
    end

    methods (Access = public)
        refineQuadrature(obj);
    end

    methods (Access = protected)
        function cp = copyElement(obj)
            cp = SampleData.SampleData(copy(obj.NLEVPData),copy(obj.Contour),obj.ell,obj.r,[]);
            cp.Lf = obj.Lf; cp.Rf = obj.Rf;
            cp.show_progress = obj.show_progress;
            cp.loaded = obj.loaded;
            %
            cp.Ql = []; cp.Qr = []; cp.Qlr = [];
        end
    end
    
    methods

        function obj = SampleData(NLEVPData,Contour,ell,r,ax)
            arguments
                NLEVPData
                Contour
                ell = 0
                r = 0
                ax = []
            end
            obj.NLEVPData = NLEVPData;
            obj.Contour = Contour;
            obj.ell = ell;
            obj.r = r;
            obj.ax = ax;
            addlistener(obj.NLEVPData,'loaded','PostSet',@obj.NLEVPDataChanged);
            addlistener(obj.Contour,'z','PostSet',@obj.ContourChanged);
            addlistener(obj,'Contour','PostSet',@obj.updateContourListeners);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
        end

        function update_plot(obj,~,~)
            obj.Contour.ax = obj.ax; obj.NLEVPData.ax = obj.ax;
            if ~isempty(obj.ax)
                obj.Contour.plot();
                obj.NLEVPData.plot();
            end
        end

        function updateContourListeners(obj,~,~)
            addlistener(obj.Contour,'z','PostSet',@obj.ContourChanged);
            obj.loaded = false;
        end

        function NLEVPDataChanged(obj,~,~)
            if obj.NLEVPData.loaded
                nold = size(obj.Lf,1);
                n = obj.NLEVPData.n;
                if n ~= nold
                    obj.Lf = Numerics.SampleData.sampleMatrix(n,obj.ell);
                    obj.Rf = Numerics.SampleData.sampleMatrix(n,obj.r);
                end
                obj.ell = min(obj.ell,n); obj.r = min(obj.r,n);
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
                    Lnew = obj.sampleMatrix(obj.NLEVPData.n,value-obj.ell);
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
                    Rnew = obj.sampleMatrix(obj.NLEVPData.n,value-obj.r);
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
            if isempty(obj.Contour)
                error("Contour data required to sample %s. Please set a contour and try again.",obj.NLEVPData.name);
            end
            if ~obj.NLEVPData.loaded
                error("Please load a problem before computing.");
            end
            if ~obj.loaded
                [obj.Ql,obj.Qr,obj.Qlr] = obj.samplequadrature(obj.NLEVPData.T,obj.Lf,obj.Rf,obj.Contour.z,obj.show_progress,obj.NLEVPData.sample_mode);
                obj.loaded = true;
            end
        end

    end

    methods (Static, Access = public)
        M = sampleMatrix(n,d);
        [Ql,Qr,Qlr] = samplequadrature(T,L,R,z,show_progress,sample_mode);
    end

end

