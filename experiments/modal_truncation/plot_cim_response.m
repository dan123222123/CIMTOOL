function plot_cim_response(f,w,CIM,H,Hr,V,W,tol,lims)
    arguments
        f
        w
        CIM
        H
        Hr = []
        V = []
        W = []
        tol = 10^-2
        lims = {{[],[]},{[],[]},{[],[]},{[],[]}}
    end
    drawnow nocallbacks;
    axes(f); tiledlayout(2,3); nexttile(1,[2 1]);
    % these lines below should probably be moved to a "plot" function in CIM.m
    scatter(real(CIM.SampleData.NLEVP.refew),imag(CIM.SampleData.NLEVP.refew),50,"diamond","MarkerEdgeColor","#E66100","LineWidth",1.5,"DisplayName","$\lambda$");
    hold on;
    scatter(real(CIM.ResultData.ew),imag(CIM.ResultData.ew),15,"MarkerFaceColor","#1AFF1A",'DisplayName',"$\hat{\lambda}$");
    hold on;
    CIM.SampleData.Contour.plot(gca); hold on;
    CIM.RealizationData.plot(gca); hold on;
    hold off; grid;
    title(sprintf("Complex Plane (%d ew inside contour)",CIM.RealizationData.m));
    xlabel("$\bf{R}$",'Interpreter','latex'); ylabel("$i\bf{R}$",'Interpreter','latex');
    legend('Interpreter','latex','Location','northoutside','Orientation','horizontal')%,'NumColumns',2);
    limsetter(lims{1}); grid;
    %
    nexttile(2);
    if ~isempty(Hr)
        Nbode(w,H,Hr); legend('H','Hr','Location','northoutside','Orientation','horizontal');
        limsetter(lims{2});
    else
        Nbode(w,H); legend('H','Location','northoutside','Orientation','horizontal');
        limsetter(lims{2});
    end
    grid;
    %
    nexttile(5);
    if ~isempty(Hr)
        nboderelerr(H,Hr,w);
        limsetter(lims{3}); grid;
    end
    %
    nexttile(3,[2 1]);
    if ~(isempty(V) || isempty(W))
        plot_gdresidues(CIM.SampleData.NLEVP.refew,CIM.ResultData.ew,V,W,tol)
        limsetter(lims{4}); grid;
    end
end

function limsetter(lc)
    xl = lc{1}; yl = lc{2};
    if ~isempty(xl)
        xlim(xl)
    end
    if ~isempty(yl)
        ylim(yl)
    end
end