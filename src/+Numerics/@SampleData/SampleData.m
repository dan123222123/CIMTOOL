classdef SampleData < matlab.mixin.Copyable

    properties
        Ql      (:,:,:) double = [] % Left Quadrature Samples, one row per sampled left direction (activeSamples selects the leading ell)
        Qr      (:,:,:) double = [] % Right Quadrature Samples, one column per sampled right direction (activeSamples selects the leading r)
        Qlr     (:,:,:) double = [] % Two-Sided Quadrature Samples
    end

    properties (SetObservable)
        ell      (1,1) double       % # of left directions: the leading ell columns of Lf and rows of Ql
        r        (1,1) double       % # of right directions: the leading r columns of Rf and columns of Qr
        Lf       (:,:) double       % "full" matrix of left directions, drawn lazily (drawDirections); may hold more than ell columns
        Rf       (:,:) double       % "full" matrix of right directions, drawn lazily (drawDirections); may hold more than r columns
    end

    properties (SetObservable)
        % declared after Lf and Rf: a load sets properties in declaration order, and set.Lf/set.Rf clear loaded, so the saved value must come last
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

    properties (Access = private, Transient)
        OperatorDataListener    = event.proplistener.empty
        ContourListener         = event.proplistener.empty
    end

    methods (Access = public)
        refineQuadrature(obj);
    end

    methods (Access = protected)
        function cp = copyElement(obj)
            if obj.OperatorData.loaded; obj.drawDirections(); end
            cp = feval(class(obj));
            cp.OperatorData = copy(obj.OperatorData);
            cp.Contour = copy(obj.Contour);
            cp.Lf = obj.Lf; cp.Rf = obj.Rf;
            cp.ell = obj.ell; cp.r = obj.r;
            %
            cp.show_progress = obj.show_progress;
            %
            cp.Ql = obj.Ql; cp.Qr = obj.Qr; cp.Qlr = obj.Qlr;
            cp.loaded = obj.loaded;
        end

        function reattachListeners(obj)
            obj.installListeners();
        end
    end

    methods (Access = private)
        function installListeners(obj)
            addlistener(obj,'OperatorData','PreSet',@obj.invalidateSamples);
            addlistener(obj,'Contour','PreSet',@obj.invalidateSamples);
            addlistener(obj,'OperatorData','PostSet',@obj.updateOperatorDataListeners);
            addlistener(obj,'Contour','PostSet',@obj.updateContourListeners);
            obj.wireOperatorData();
            obj.wireContour();
        end

        % The listeners on the operator and contour hold the SampleData weakly (Numerics.weakListener),
        % so a shared operator or contour does not keep it alive.
        function wireOperatorData(obj)
            delete(obj.OperatorDataListener(isvalid(obj.OperatorDataListener)));
            op = obj.OperatorData;
            obj.OperatorDataListener = [
                Numerics.weakListener(op,'loaded',obj,@(o,s,e) o.OperatorDataChanged(s,e))
                Numerics.weakListener(op,'T',obj,@(o,s,e) o.OperatorDefinitionChanged(s,e))
                Numerics.weakListener(op,'sample_mode',obj,@(o,s,e) o.OperatorDefinitionChanged(s,e))
            ];
        end

        function wireContour(obj)
            delete(obj.ContourListener(isvalid(obj.ContourListener)));
            obj.ContourListener = Numerics.weakListener(obj.Contour,'z',obj,@(o,s,e) o.ContourChanged(s,e));
        end

        function checkDirections(obj)
            if obj.ell == 0 || obj.r == 0
                error("Numerics:SampleData:noDirections", ...
                    "ell and r must be positive to sample or realize; got ell = %d, r = %d.", obj.ell, obj.r);
            end
        end

        function invalidateSamples(obj,~,~)
            obj.loaded = false;
        end

        function OperatorDefinitionChanged(obj,~,~)
            % a new T or sample_mode invalidates the samples, and the directions too if the size changed
            obj.OperatorDataChanged();
            obj.loaded = false;
        end
    end

    methods

        function delete(obj)
            listeners = [obj.OperatorDataListener; obj.ContourListener];
            delete(listeners(isvalid(listeners)));
        end

        function obj = SampleData(OperatorData,Contour,ell,r)
            arguments
                OperatorData (1,1) {mustBeA(OperatorData,'Numerics.OperatorData')} = Numerics.OperatorData()
                Contour {mustBeScalarOrEmpty, mustBeA(Contour,'Numerics.Contour.Quad')} = Numerics.Contour.Quad.empty   % compute() asks for one
                ell (1,1) double {mustBeNonnegative, mustBeInteger} = OperatorData.n
                r (1,1) double {mustBeNonnegative, mustBeInteger} = OperatorData.n
            end
            obj.OperatorData = OperatorData;
            obj.Contour = Contour;
            obj.ell = ell; obj.r = r;
            obj.installListeners();
        end

        function updateContourListeners(obj,~,~)
            obj.wireContour();
            obj.loaded = false;
        end

        function updateOperatorDataListeners(obj,~,~)
            obj.wireOperatorData();
            if size(obj.Lf,1) ~= obj.OperatorData.n
                obj.Lf = []; obj.Rf = [];
            end
            obj.loaded = false;
        end

        function OperatorDataChanged(obj,~,~)
            if obj.OperatorData.loaded
                n = obj.OperatorData.n;
                if size(obj.Lf,1) ~= n
                    obj.Lf = []; obj.Rf = [];
                end
                obj.ell = min(obj.ell,n); obj.r = min(obj.r,n);
                obj.loaded = false;
            end
        end

        function ContourChanged(obj,~,~)
            obj.loaded = false;
        end

        function value = atMostN(obj,value,name)
            % more probing directions than the operator dimension n add nothing, so ell and r never exceed n, here as in
            % OperatorDataChanged; during a load the operator is not set yet, and the saved values already respect n
            if ~isempty(obj.OperatorData) && obj.OperatorData.loaded && value > obj.OperatorData.n
                n = obj.OperatorData.n;
                warning("Numerics:SampleData:directionsClamped", "%s = %d exceeds the operator dimension n = %d; using %d.",name,value,n,n);
                value = n;
            end
        end

        function drawDirections(obj)
        % Draws the random probing directions that ell and r ask for and Lf and Rf do not hold yet, left before right.
        % compute() calls it before sampling; construction, copy, set.ell/set.r and reading L or R draw nothing.
            n = obj.OperatorData.n;
            if size(obj.Lf,2) < obj.ell
                Lf0 = obj.Lf; if isempty(Lf0); Lf0 = zeros(n,0); end
                obj.Lf = [Lf0, obj.sampleMatrix(n,obj.ell-size(Lf0,2))];
            end
            if size(obj.Rf,2) < obj.r
                Rf0 = obj.Rf; if isempty(Rf0); Rf0 = zeros(n,0); end
                obj.Rf = [Rf0, obj.sampleMatrix(n,obj.r-size(Rf0,2))];
            end
        end

        function value = get.L(obj)
        % The leading ell left directions drawn so far; drawDirections() fills Lf to ell columns.
            value = obj.Lf(:,1:min(obj.ell,size(obj.Lf,2)));
        end

        function value = get.R(obj)
        % The leading r right directions drawn so far; drawDirections() fills Rf to r columns.
            value = obj.Rf(:,1:min(obj.r,size(obj.Rf,2)));
        end

        function set.ell(obj,value)
            if ~(isscalar(value) && isreal(value) && value >= 0 && value == floor(value))
                error("Numerics:SampleData:badEll", ...
                    "ell (number of left directions) must be a nonnegative integer.");
            end
            % Lf and the samples keep all their columns; only more directions than were sampled need sampling again
            obj.ell = obj.atMostN(value,"ell");
            if obj.ell > size(obj.Ql,1)
                obj.loaded = false;
            end
        end

        function set.r(obj,value)
            if ~(isscalar(value) && isreal(value) && value >= 0 && value == floor(value))
                error("Numerics:SampleData:badR", ...
                    "r (number of right directions) must be a nonnegative integer.");
            end
            % Rf and the samples keep all their columns; only more directions than were sampled need sampling again
            obj.r = obj.atMostN(value,"r");
            if obj.r > size(obj.Qr,2)
                obj.loaded = false;
            end
        end

        function set.Lf(obj,value)
            % new directions invalidate the samples; drawDirections only appends while loaded is already false
            obj.Lf = value;
            obj.loaded = false;
        end

        function set.Rf(obj,value)
            obj.Rf = value;
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

        function checkSamples(obj)
        % Errors unless the stored samples are current and cover the leading ell left and r right directions.
            obj.checkDirections();
            if ~obj.loaded || size(obj.Ql,1) < obj.ell || size(obj.Qr,2) < obj.r
                error("Numerics:SampleData:stale", ...
                    "The samples do not match the SampleData (ell = %d, r = %d; %d x %d directions sampled, loaded = %d); call compute() first.", ...
                    obj.ell, obj.r, size(obj.Ql,1), size(obj.Qr,2), obj.loaded);
            end
        end

        function [Ql,Qr,Qlr] = activeSamples(obj)
        % The samples for the leading ell left and r right directions; Ql, Qr and Qlr may hold more.
            obj.checkSamples();
            Ql = obj.Ql; Qr = obj.Qr; Qlr = obj.Qlr;
            if size(Ql,1) > obj.ell
                Ql = Ql(1:obj.ell,:,:); Qlr = Qlr(1:obj.ell,:,:);
            end
            if size(Qr,2) > obj.r
                Qr = Qr(:,1:obj.r,:); Qlr = Qlr(:,1:obj.r,:);
            end
        end

        function compute(obj)
            if isempty(obj.Contour)
                error("Contour data required to sample %s. Please set a contour and try again.",obj.OperatorData.name);
            end
            if ~obj.OperatorData.loaded
                error("Please load a problem before computing.");
            end
            obj.checkDirections();
            if ~obj.loaded
                obj.drawDirections();
                [obj.Ql,obj.Qr,obj.Qlr] = obj.samplequadrature(obj.OperatorData.T,obj.L,obj.R,obj.Contour.z,obj.show_progress,obj.OperatorData.sample_mode);
                obj.loaded = true;
            end
        end

    end

    methods (Static, Access = public)
        function obj = loadobj(obj)
        % Listeners are not saved: a SampleData loaded from a MAT file, or received by a parfor worker, installs them again.
            if isstruct(obj)
                warning("Numerics:SampleData:loadobj", "A SampleData could not be loaded as an object and is returned as a struct.");
                return;
            end
            obj.reattachListeners();
        end
        M = sampleMatrix(n,d);
        [Ql,Qr,Qlr] = samplequadrature(T,L,R,z,show_progress,sample_mode);
    end

end
