classdef ResultData < handle
    
    properties (SetObservable)
        ComputationalMode = missing
        Db      = missing
        Ds      = missing
        B       = missing
        C       = missing
        X       = missing
        Sigma   = missing
        Y       = missing
        ew      = missing % computed eigenvalues
        rev     = missing % computed right eigenvectors
        lev     = missing % computed left eigenvectors
        MainAx  = missing
        SvAx    = missing
        loaded  = false
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
            addlistener(obj,'Sigma','PostSet',@obj.update_sv_ax);
        end

        function value = get.Dbsize(obj)
            value = size(obj.Db);
        end

        function value = get.Dssize(obj)
            value = size(obj.Ds);
        end

        function [Lambda,V,W] = rtfm(obj,m,abstol)
            arguments
                obj
                m = Inf
                abstol = NaN
            end
            if m == length(obj.ew)
                Lambda = diag(obj.ew); V = obj.rev; W = obj.lev;
            else % need to do realization for m
                if isnan(abstol)
                    tol = max(size(obj.Sigma))*eps(obj.Sigma(1,1));
                else
                    tol = abstol;
                end
                r = sum(diag(obj.Sigma)>=tol);
                if r < m
                    error("Db has numerical rank %d < %d. Cannot recover TF!",r,m);
                end
                X=obj.X(:,1:m); Sigma=obj.Sigma(1:m,1:m); Y=obj.Y(:,1:m);
                [S,Lambda] = eig(X'*obj.Ds*Y,Sigma);
                Lambda = diag(Lambda); V = obj.C*Y*(Sigma\S); W = S\(X'*obj.B);
            end
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
                hold(ax,"on");
                if ~ismissing(obj.ew)
                    obj.MainAxphandles(end+1) = scatter(ax,real(obj.ew),imag(obj.ew),30,"Tag","computed_eigenvalues","MarkerFaceColor","#1AFF1A","DisplayName","Computed Eigenvalues",'Linewidth',1.5);
                end
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
            if ~any(ismissing(ax))
                chold = ishold(ax);
                if ~all(ismissing(obj.Sigma))
                    Dbsw = diag(obj.Sigma) / obj.Sigma(1,1);
                    obj.SvAxphandles(end+1) = semilogy(ax,1:length(Dbsw),Dbsw,"->","MarkerSize",10,'DisplayName','Base Data Matrix (Db)','Color',"r");
                    ax.XLim = [0,length(Dbsw)+1];
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
                obj.plot_sv();
            end
        end
       
    end

end

