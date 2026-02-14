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
         cp.arglist = obj.arglist;
         cp.sample_mode = obj.sample_mode;
         cp.compute_reference = obj.compute_reference;
         cp.refew = obj.refew;
         cp.refev = obj.refev;
         cp.loaded = obj.loaded;
      end
   end
    
    methods

        function obj = OperatorData(T,name,arglist)
            arguments
                T = []
                name = []
                arglist = []
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

        function computeReference(obj,~,~)
            if obj.compute_reference && ~isempty(obj.coeffs) && any(contains(nlevp('query',obj.name),'pep'))
                obj.refew = polyeig(obj.coeffs{:});
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
            obj.computeReference([],[]);
            obj.loaded = true;
        end

    end

end

