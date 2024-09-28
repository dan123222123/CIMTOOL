classdef NLEVPData < handle

    properties (SetObservable)
        T = missing
        name = missing
        loaded Numerics.IsLoaded = Numerics.IsLoaded.NotLoaded
        compute_reference = false
        refew = missing
        refev = missing
    end
    
    properties
        n = missing
        arglist = missing
        coeffs = missing
        helpstr = missing
        NLEVPphandles = gobjects(0);
        Referencephandles = gobjects(0);
    end
    
    methods

        function obj = NLEVPData(T,name,arglist)
            arguments
                T = missing
                name = missing
                arglist = missing
            end
            obj.T = T;
            obj.name = name;
            obj.arglist = arglist;
        end

        function loadNLEVPpack(obj,probstr,arglist)
            arguments
                obj 
                probstr 
                arglist = missing
            end

            % disable while we attempt to load in the new NLEVP
            obj.loaded = Numerics.IsLoaded.NotLoaded;

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

            % now deal with any NLEVP arguments, if not missing
            allfinite=true;
            if ismissing(arglist)
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
                obj.loaded = Numerics.IsLoaded.LoadedButWarning;
            else
                obj.loaded = Numerics.IsLoaded.Loaded;
            end
        end

    end

end

