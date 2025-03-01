function plot_cim_response(f,CIM,H,Hr,w,x,y)
    drawnow nocallbacks;
    axes(f); subplot(2,2,1);
    % these lines below should probably be moved to a "plot" function in CIM.m
    scatter(real(CIM.SampleData.NLEVP.refew),imag(CIM.SampleData.NLEVP.refew),50,"diamond","MarkerEdgeColor","#E66100","LineWidth",1.5,"DisplayName","$\lambda$");
    hold on;
    scatter(real(CIM.ResultData.ew),imag(CIM.ResultData.ew),15,"MarkerFaceColor","#1AFF1A",'DisplayName',"$\hat{\lambda}$");
    hold on;
    CIM.SampleData.Contour.plot(gca); hold on;
    CIM.RealizationData.plot(gca); hold on;
    hold off; grid;
    title("Complex Plane");
    xlabel("$\bf{R}$",'Interpreter','latex'); ylabel("$i\bf{R}$",'Interpreter','latex');
    legend('Interpreter','latex','Location','northoutside','Orientation','horizontal')%,'NumColumns',2);
    %
    subplot(2,2,2);
    Nbode(w,H,Hr); legend('H','Hr','Location','northoutside','Orientation','horizontal');
    grid;
    %
    subplot(2,2,3);
    nboderelerr(H,Hr,w);
    grid;
    %
    subplot(2,2,4);
    nboderelerr_surf(H,Hr,x,y);
end