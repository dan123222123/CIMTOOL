classdef NLEVPData < handle

    properties (SetObservable)
        T = missing
        coeffs = missing
        name = missing
        helpstr = missing
        loaded = false
        compute_reference = false
        plot_reference = true
        refew = missing
        refev = missing
        ax = missing
    end
    
    properties
        n = missing
        arglist = missing
        phandles = gobjects(0);
    end
    
    methods

        function obj = NLEVPData(T,name,arglist,ax)
            arguments
                T = missing
                name = missing
                arglist = missing
                ax = missing
            end
            obj.T = T;
            obj.name = name;
            obj.arglist = arglist;
            if any(ismissing(T)) && ~any(ismissing(name))
                obj.loadNLEVPpack(name,arglist)
            end
            if ~ismissing(ax)
                obj.plot(ax)
            end
            addlistener(obj,'coeffs','PostSet',@obj.computeReference);
            addlistener(obj,'compute_reference','PostSet',@obj.computeReference);
            addlistener(obj,'refew','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
            addlistener(obj,'plot_reference','PostSet',@obj.update_plot);
        end

        function cla(obj)
            for i=1:length(obj.phandles)
                  delete(obj.phandles(i));
            end
            obj.phandles = gobjects(0);
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
            if obj.plot_reference
                if ~any(ismissing(obj.ax)) && ~any(ismissing(obj.refew))
                    obj.phandles(end+1) = scatter(obj.ax,real(obj.refew),imag(obj.refew),200,"blue","diamond",'Tag',"refew");
                end
            end
            obj.ax = ax;
        end

        function update_plot(obj,~,~)
            obj.cla();
            if ~ismissing(obj.ax)
                obj.plot(obj.ax);
            end
        end

        function computeReference(obj,~,~)
            if obj.compute_reference && ~any(ismissing(obj.coeffs))
                obj.refew = polyeig(obj.coeffs{:});
            end
        end
        
        function loadNLEVPpack(obj,probstr,arglist)
            arguments
                obj 
                probstr 
                arglist = missing
            end

            % disable while we attempt to load in the new NLEVP
            obj.loaded = false;

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
                warndlg("One or more of passed NLEVP parameters is not finite. Please ensure that the passed argument list is correct!")
            end
            obj.loaded = true;
        end

        function delete(obj)
            obj.cla();
        end

    end

end

