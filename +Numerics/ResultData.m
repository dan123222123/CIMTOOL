classdef ResultData < handle
    
    properties (SetObservable)
        Db      = missing
        Ds      = missing
        ew      = missing % computed eigenvalues
        ev      = missing % computed eigenvectors
        Dbsw    = missing % singular values of base data matrix
        Dssw    = missing % singular values of base data matrix
        MainAx  = missing
        SvAx    = missing
    end

    properties
        MainAxphandles = gobjects(0);
        SvAxphandles = gobjects(0);
    end

    properties (Dependent)
        Dbsize
        Dssize
    end
    
    methods

        function obj = ResultData(MainAx,SvAx)
            arguments
                MainAx = missing
                SvAx = missing
            end
            obj.MainAx = MainAx;
            obj.SvAx = SvAx;
            addlistener(obj,'MainAx','PostSet',@obj.update_main_ax);
            addlistener(obj,'SvAx','PostSet',@obj.update_sv_ax);

            addlistener(obj,'ew','PostSet',@obj.update_main_ax);
            addlistener(obj,'Db','PostSet',@obj.update_sv_ax);
            addlistener(obj,'Ds','PostSet',@obj.update_sv_ax);
        end

        function value = get.Dbsize(obj)
            value = size(obj.Db);
        end

        function value = get.Dssize(obj)
            value = size(obj.Ds);
        end

        function plot_main(obj)
            ax = obj.MainAx;
            if ismissing(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.MainAxphandles)
                obj.cla_main();
            end
            if ~any(ismissing(ax))
                chold = ishold(ax);
                hold(ax,"on");
                if ~ismissing(obj.ew)
                    obj.MainAxphandles(end+1) = scatter(ax,real(obj.ew),imag(obj.ew),50,"red");
                end
                hold(ax,chold);
            end
            obj.MainAx = ax;
        end

        function plot_sv(obj)
            ax = obj.SvAx;
            if ismissing(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.SvAxphandles)
                obj.cla_sv();
            end
            tstring = "";
            if ~any(ismissing(ax))
                chold = ishold(ax);
                if ~ismissing(obj.Dbsw)
                    obj.SvAxphandles(end+1) = semilogy(ax,1:length(obj.Dbsw),obj.Dbsw,"->","MarkerSize",10,'DisplayName','Dbsw');
                    tstring = strcat(tstring,sprintf("size(Db) = %d, %d",obj.Dbsize(1),obj.Dbsize(2)));
                end
                if ~ismissing(obj.Dbsw)
                    obj.SvAxphandles(end+1) = semilogy(ax,1:length(obj.Dssw),obj.Dssw,"->","MarkerSize",10,'DisplayName','Dssw');
                    tstring = strcat(tstring,sprintf("\t||\tsize(Ds) = %d, %d",obj.Dssize(1),obj.Dssize(2)));
                end
                ax.XLim = [0,max(length(obj.Dbsw),length(obj.Dssw))+1];
                hold(ax,chold);
            end
            title(ax,tstring);
            obj.SvAx = ax;
        end

        function cla_main(obj)
            for i=1:length(obj.MainAxphandles)
                  delete(obj.MainAxphandles(i));
            end
            obj.MainAxphandles = gobjects(0);
        end
        
        function cla_sv(obj)
            for i=1:length(obj.SvAxphandles)
                  delete(obj.SvAxphandles(i));
            end
            obj.SvAxphandles = gobjects(0);
        end

        function cla(obj)
            obj.cla_main();
            obj.cla_sv();
        end

        function update_main_ax(obj,~,~)
            obj.cla_main();
            if ~ismissing(obj.MainAx)
                obj.plot_main();
            end
        end

        function update_sv_ax(obj,~,~)
            obj.cla_sv();
            if ~ismissing(obj.SvAx)
                obj.plot_sv();
            end
        end
       
    end

end

