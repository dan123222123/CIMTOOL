classdef NLEVPData < matlab.mixin.Copyable

    properties (SetObservable)
        T = []
        coeffs = []
        name = []
        helpstr = []
        loaded = false
        compute_reference = true
        plot_reference = true
        sample_mode = Numerics.SampleMode.Inverse
        refew = []
        refev = []
        ax = []
    end

    properties (Dependent)
        n
    end
    
    properties
        arglist = []
        phandles = gobjects(0);
    end

    methods(Access = protected)
      function cp = copyElement(obj)
         cp = Numerics.NLEVPData(obj.T,obj.name,obj.arglist,[]);
         cp.sample_mode = obj.sample_mode;
         cp.plot_reference = obj.plot_reference;
         cp.compute_reference = obj.compute_reference;
         cp.refew = obj.refew; cp.refev = obj.refev;
         cp.loaded = obj.loaded;
      end
   end
    
    methods

        function obj = NLEVPData(T,name,arglist,ax)
            arguments
                T = []
                name = []
                arglist = []
                ax = []
            end
            obj.T = T;
            obj.name = name;
            obj.arglist = arglist;
            if ~isempty(T)
                obj.loaded = true;
            elseif isempty(T) && ~isempty(name)
                obj.loadNLEVPpack(name,arglist)
            end
            if ~isempty(ax)
                obj.plot(ax)
            end
            addlistener(obj,'coeffs','PostSet',@obj.computeReference);
            addlistener(obj,'compute_reference','PostSet',@obj.computeReference);
            addlistener(obj,'refew','PostSet',@obj.update_plot);
            addlistener(obj,'ax','PostSet',@obj.update_plot);
            addlistener(obj,'plot_reference','PostSet',@obj.update_plot);
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
            if isempty(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.phandles)
                obj.cla();
            end
            if obj.plot_reference
                if ~isempty(obj.ax) && ~isempty(obj.refew)
                    obj.phandles(end+1) = scatter(obj.ax,real(obj.refew),imag(obj.refew),100,"diamond","MarkerEdgeColor","#E66100","LineWidth",1.5,'Tag',"reference_eigenvalues","DisplayName","Reference Eigenvalues");
                end
            end
        end

        function update_plot(obj,~,~)
            obj.cla();
            if ~isempty(obj.ax)
                obj.plot(obj.ax);
            end
        end

        function computeReference(obj,~,~)
            if obj.compute_reference && ~isempty(obj.coeffs) && any(contains(nlevp('query',obj.name),'pep'))
                obj.refew = polyeig(obj.coeffs{:});
            end
        end
        
        function loadNLEVPpack(obj,probstr,arglist)
            arguments
                obj 
                probstr 
                arglist = []
            end

            obj.clearNLEVP();

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

        function delete(obj)
            obj.cla();
        end

        function clearNLEVP(obj)
            obj.loaded = false;
            obj.T = [];
            obj.name = [];
            obj.arglist = [];
            obj.helpstr = [];
            obj.refew = [];
            obj.refev = [];
        end

    end

end

