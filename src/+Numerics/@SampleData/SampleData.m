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
        show_progress = false       % progress bar toggle -- only works for serial/Process-based pools
    end

    properties (SetObservable,Access = public)
        OperatorData
        Contour
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
            cp = feval(class(obj));
            cp.OperatorData = copy(obj.OperatorData);
            cp.Contour = copy(obj.Contour);
            cp.ell = obj.ell; cp.r = obj.r;
            addlistener(cp.OperatorData,'loaded','PostSet',@cp.OperatorDataChanged);
            addlistener(cp.Contour,'z','PostSet',@cp.ContourChanged);
            addlistener(cp,'Contour','PostSet',@cp.updateContourListeners);
            %
            cp.Lf = obj.Lf; cp.Rf = obj.Rf;
            cp.show_progress = obj.show_progress;
            %
            cp.Ql = obj.Ql; cp.Qr = obj.Qr; cp.Qlr = obj.Qlr;
            cp.loaded = obj.loaded;
        end
    end
    
    methods

        function obj = SampleData(OperatorData,Contour,ell,r)
            arguments
                OperatorData = Numerics.OperatorData()
                Contour = Numerics.Contour.Circle()
                ell = OperatorData.n
                r = OperatorData.n
            end
            obj.OperatorData = OperatorData;
            obj.Contour = Contour;
            obj.ell = ell; obj.r = r;
            addlistener(obj.OperatorData,'loaded','PostSet',@obj.OperatorDataChanged);
            addlistener(obj.Contour,'z','PostSet',@obj.ContourChanged);
            addlistener(obj,'Contour','PostSet',@obj.updateContourListeners);
        end

        function updateContourListeners(obj,~,~)
            addlistener(obj.Contour,'z','PostSet',@obj.ContourChanged);
            obj.loaded = false;
        end

        function OperatorDataChanged(obj,~,~)
            if obj.OperatorData.loaded
                nold = size(obj.Lf,1);
                n = obj.OperatorData.n;
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
                    Lnew = obj.sampleMatrix(obj.OperatorData.n,value-obj.ell);
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
                    Rnew = obj.sampleMatrix(obj.OperatorData.n,value-obj.r);
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
                error("Contour data required to sample %s. Please set a contour and try again.",obj.OperatorData.name);
            end
            if ~obj.OperatorData.loaded
                error("Please load a problem before computing.");
            end
            if ~obj.loaded
                [obj.Ql,obj.Qr,obj.Qlr] = obj.samplequadrature(obj.OperatorData.T,obj.Lf,obj.Rf,obj.Contour.z,obj.show_progress,obj.OperatorData.sample_mode);
                obj.loaded = true;
            end
        end

    end

    methods (Static, Access = public)
        M = sampleMatrix(n,d);
        [Ql,Qr,Qlr] = samplequadrature(T,L,R,z,show_progress,sample_mode);
    end

end

