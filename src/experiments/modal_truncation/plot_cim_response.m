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
    axes(f); tiledlayout(2,3); nexttile(1,[2 1]); CIM.plot();
    limsetter(lims{1});
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