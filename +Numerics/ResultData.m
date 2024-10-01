classdef ResultData < handle
    
    properties (SetObservable)
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
            addlistener(obj,'Dbsw','PostSet',@obj.update_sv_ax);
            addlistener(obj,'Dssw','PostSet',@obj.update_sv_ax);
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

        function plot_sv(obj,sw)
            ax = obj.SvAx;
            if ismissing(ax)
                ax = gca();
            end
            if ~isgraphics(ax), ax = axes(gcf); end
            if ~isempty(obj.SvAxphandles)
                obj.cla_sv();
            end
            if ~any(ismissing(ax))
                chold = ishold(ax);
                if ~ismissing(sw)
                    obj.SvAxphandles(end+1) = semilogy(ax,1:length(sw),sw,"->","MarkerSize",10);
                    ax.XLim = [0,length(sw)+1];
                end
                hold(ax,chold);
            end
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
                obj.plot_sv(obj.Dbsw);
            end
        end
       
    end

end

