classdef OperatorData < matlab.mixin.Copyable

    properties (SetObservable)
        T = []
        loaded = false
        sample_mode = Numerics.SampleMode.Inverse
        refew = []
        refev = []
    end

    % for NLEVPack problems
    properties (SetObservable)
        coeffs = []
        compute_reference = true
        name = []
        helpstr = []
    end

    % the reference of an NLEVP PEP (polyeig) runs in the background, see computeReference
    properties
        ReferenceWait (1,1) double {mustBeNonnegative} = 5           % seconds computeReference waits for the result
        MaxReferenceSize (1,1) double {mustBeNonnegative} = 500      % no automatic reference when n*d exceeds this
    end

    properties (SetObservable, SetAccess = protected)
        % none, computing, done, skipped (n*d > MaxReferenceSize), cancelled or failed
        ReferenceStatus (1,1) string {mustBeMember(ReferenceStatus,["none","computing","done","skipped","cancelled","failed"])} = "none"
    end

    properties (Access = private, Transient)
        ReferenceFuture = []    % the running polyeig, never copied or saved
        ReferenceCallback = []  % its afterEach future
    end

    properties (Dependent)
        n
    end

    properties
        arglist = []
    end

    methods(Access = protected)
      function cp = copyElement(obj)
         cp = feval(class(obj));
         cp.T = obj.T;
         cp.name = obj.name;
         cp.coeffs = obj.coeffs;
         cp.helpstr = obj.helpstr;
         cp.arglist = obj.arglist;
         cp.sample_mode = obj.sample_mode;
         cp.compute_reference = obj.compute_reference;
         cp.refew = obj.refew;
         cp.refev = obj.refev;
         cp.ReferenceWait = obj.ReferenceWait;
         cp.MaxReferenceSize = obj.MaxReferenceSize;
         cp.ReferenceStatus = Numerics.OperatorData.settledStatus(obj.ReferenceStatus);
         cp.loaded = obj.loaded;
      end

      function reattachListeners(~)
      end
   end

    methods (Static)
        function obj = loadobj(obj)
            if isstruct(obj)
                warning("Numerics:OperatorData:loadobj", "A OperatorData could not be loaded as an object and is returned as a struct.");
                return;
            end
            obj.ReferenceStatus = Numerics.OperatorData.settledStatus(obj.ReferenceStatus);
            obj.reattachListeners();
        end
    end

    methods (Static, Access = protected)
        function s = settledStatus(s)
            % a copy or a load carries no running computation, so one saved while computing is cancelled
            if s == "computing"
                s = "cancelled";
            end
        end
    end

    methods (Static, Access = private)
        function referenceArrived(ref,F)
            % afterEach callback; holds the operator weakly, so dropping it cancels the computation (delete)
            obj = ref.Handle;
            if isvalid(obj)
                obj.referenceFinished(F);
            end
        end
    end

    methods

        function obj = OperatorData(T,name,arglist)
            arguments
                T = []
                name = []
                arglist = []
            end
            % T is either a transfer-function / operator handle, or empty when
            % loading an NLEVP problem by name
            if ~isempty(T) && ~isa(T,'function_handle')
                error("Numerics:OperatorData:badT", ...
                    "T must be a function handle (or empty to load an NLEVP problem by name); got %s.", class(T));
            end
            if ~isempty(name) && ~(ischar(name) || isstring(name))
                error("Numerics:OperatorData:badName", ...
                    "name must be a string or char NLEVP problem name; got %s.", class(name));
            end
            obj.T = T;
            if ~isempty(T)
                obj.loaded = true;
            elseif isempty(T) && ~isempty(name)
                obj.loadNLEVPPACK(name,arglist)
            end
        end

        function addNLEVPACKListeners(obj)
            addlistener(obj,'coeffs','PostSet',@obj.computeReference);
            addlistener(obj,'compute_reference','PostSet',@obj.computeReference);
        end

        function value = get.n(obj)
            if obj.loaded
                orig_state = warning;
                warning('off','all');
                value = size(obj.T(0),1);
                warning(orig_state);
            else
                value = 0;
            end
        end

        function set.refew(obj,value)
            % a reference set by hand cancels a running computation, whose result would overwrite it, and replaces
            % a skipped, cancelled or failed one, so no status is left to report
            obj.refew = value;
            if ~isempty(obj.ReferenceFuture) %#ok<MCSUP>
                obj.cancelReference();
            end
            if ~isempty(value) && ismember(obj.ReferenceStatus,["skipped","cancelled","failed"]) %#ok<MCSUP>
                obj.ReferenceStatus = "none"; %#ok<MCSUP>
            end
        end

        function delete(obj)
            obj.stopReference();
        end

        function computeReference(obj,~,~)
            % refew of an NLEVP PEP by polyeig on the background pool: a result within ReferenceWait seconds is set
            % before the return, a later one when it arrives; ReferenceStatus follows, and a new call cancels a running one
            obj.stopReference();
            if ~(obj.compute_reference && ~isempty(obj.coeffs) && any(contains(nlevp('query',obj.name),'pep')))
                obj.ReferenceStatus = "none";
                return;
            end
            obj.refew = [];
            if size(obj.coeffs{1},1)*(numel(obj.coeffs) - 1) > obj.MaxReferenceSize
                obj.ReferenceStatus = "skipped";
                return;
            end
            F = parfeval(backgroundPool,@polyeig,1,obj.coeffs{:});
            ref = matlab.lang.WeakReference(obj);
            obj.ReferenceCallback = afterEach(F,@(f) Numerics.OperatorData.referenceArrived(ref,f),0,'PassFuture',true);
            obj.ReferenceFuture = F;
            obj.ReferenceStatus = "computing";
            obj.waitReference(obj.ReferenceWait);
        end

        function tf = waitReference(obj,timeout)
            % Waits up to timeout seconds (default Inf) for a running reference computation and sets its result.
            % tf is false while it is still computing.
            arguments
                obj
                timeout (1,1) double {mustBeNonnegative} = Inf
            end
            F = obj.ReferenceFuture;
            if ~isempty(F) && wait(F,'finished',timeout)
                obj.referenceFinished(F);
            end
            tf = obj.ReferenceStatus ~= "computing";
        end

        function cancelReference(obj)
            % Stops a running reference computation; refew stays empty.
            if obj.stopReference()
                obj.ReferenceStatus = "cancelled";
            end
        end

        function loadNLEVPPACK(obj,probstr,arglist)
            arguments
                obj
                probstr
                arglist = []
            end

            % check if the given problem exists in the NLEVP pack
            nlevp(probstr);
            obj.name = probstr;

            % if so, get the NLEVP pack help string
            nlevp_home = which('nlevp');
            nlevp_home = strrep(nlevp_home, 'nlevp.m', '');
            if ispc
                obj.helpstr = help(sprintf('%sprivate\\%s', nlevp_home, probstr));
            else
                obj.helpstr = help(sprintf('%sprivate/%s', nlevp_home, probstr));
            end

            % now deal with any NLEVP arguments, if not empty
            allfinite=true;
            if isempty(arglist)
                [obj.coeffs,~,obj.T] = nlevp(probstr);
            else
                strarglist = split(arglist,",");
                % check that there isn't something like an extra comma,
                % which could incorrectly set an NLEVP parameter
                numarglist=num2cell(str2double(strarglist));
                for i=1:length(numarglist)
                    if ~isfinite(numarglist{i})
                        allfinite=false;
                        warning("The passed NLEVP argument %d is not finite.", i)
                    end
                end
                % as far as I can tell, there is no simple way to check
                % that arglist doesn't contain MORE parameters than the
                % nlevp uses...the help string for each nlevp shows the
                % calling convention, but there is no "number" to check
                % against...
                try
                    [obj.coeffs,~,obj.T] = nlevp(probstr,numarglist{:});
                catch AE
                    uialert(gcf,'NLEVP exists, but passed argument list caused an error. Check NLEVP help string and try again.','Error Setting NLEVP');
                    rethrow(AE)
                end
                obj.arglist = numarglist;
            end
            % now that the NLEVP is essentially loaded, set other params
            if ~allfinite
                warndlg("One or more of passed NLEVP parameters is not finite. Please ensure that the passed argument list is correct!")
            end
            obj.refew = []; obj.refev = [];   % the previous problem's
            obj.computeReference([],[]);
            obj.loaded = true;
        end

    end

    methods (Access = private)

        function running = stopReference(obj)
            % cancels the running computation, if any; true when there was one
            F = obj.ReferenceFuture;
            running = ~isempty(F);
            if running
                % the callback first: a callback queued by the cancel crashes MATLAB when this runs at exit (delete)
                cancel(obj.ReferenceCallback);
                cancel(F);
            end
            obj.ReferenceFuture = [];
            obj.ReferenceCallback = [];
        end

        function referenceFinished(obj,F)
            % only the current computation's result is kept: a cancelled or superseded one is dropped
            % (afterEach passes another handle to the same future, so the IDs are compared)
            if isempty(obj.ReferenceFuture) || obj.ReferenceFuture.ID ~= F.ID
                return;
            end
            obj.ReferenceFuture = [];
            obj.ReferenceCallback = [];
            if isempty(F.Error)
                obj.refew = fetchOutputs(F);
                obj.ReferenceStatus = "done";
            else
                obj.ReferenceStatus = "failed";
                warning("Numerics:OperatorData:referenceFailed", ...
                    "The reference eigenvalues of %s could not be computed, refew stays empty: %s", obj.name, F.Error.message);
            end
        end

    end

end
