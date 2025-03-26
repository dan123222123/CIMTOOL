cd("/home/dan1345/CIMTOOL/experiments/modal_truncation")
addpath("/home/dan1345/CIMTOOL/")
parpool("Threads")

%% construct fn in tf form
load('./iss.mat'); n = size(A,1); [V,Lambda] = eig(full(A)); ewref = diag(Lambda);
H = @(z) full(C*((z*speye(n) - A) \ B)); w = logspace(-1,3,5000);

%% setup CIM
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
s = 1.2;
contour = Numerics.Contour.Ellipse(0,2*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,5e2);
tc =      Numerics.Contour.Ellipse(0,2*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,5e2);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.NLEVP.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 3; CIM.SampleData.r = 3; CIM.RealizationData.K = 1000;
CIM.SampleData.show_progress = false;

%% CIMTOOl investigation (if necessary)
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-1.5 1.5]); ylim(CIM.MainAx,[-125 125]);

%% contour conga
gx = linspace(2*max(abs(real(ewref)))*s,min(abs(real(ewref)))*s,500);

f = figure(1); f.Visible = false; f.Position = [100 100 1920 1080];
% the line along which gamma evolves
% axes(f.Children(end)); hold on; plot(real(gls),imag(gls)); hold off;

wobj = sprintf('cc_iss_centered-N%d.gif',CIM.SampleData.Contour.N); delete(wobj);
for i=1:length(gx)
    clf(f);
    % test if there are ew inside the contour
    tc.alpha = gx(i); nec = length(ewref(tc.inside(ewref)));
    % compute and plot realized tf response
    if nec ~= 0
        CIM.SampleData.Contour.alpha = gx(i); CIM.RealizationData.m = nec;
        CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf(nec); Hrmpl = @(z) V2*((M21-z*M22)\W2);
        plot_cim_response(f,w,CIM,H,Hrmpl);
    else
        plot_cim_response(f,w,CIM,H,[]); sgtitle(f,fprintf("at i=%d, nec was %d\n",i,nec))
    end
    exportgraphics(gcf,wobj,'Append',true,'Resolution',100)
end

function plot_cim_response(f,w,CIM,H,Hr)
    arguments
        f
        w
        CIM
        H
        Hr = []
    end
    drawnow nocallbacks;
    axes(f); subplot(1,3,1);
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
    xlim([-0.4 0.05]); ylim([-100 100]);
    %
    subplot(1,3,2);
    if ~isempty(Hr)
        Nbode(w,H,Hr); legend('H','Hr','Location','northoutside','Orientation','horizontal');
        ylim([1e-10,1]); grid;
        %
        subplot(1,3,3);
        nboderelerr(H,Hr,w);
        ylim([1e-5,5e1]);
        grid;
    else
        Nbode(w,H); legend('H','Location','northoutside','Orientation','horizontal');
        ylim([1e-10,1]); grid;
        subplot(1,3,3);
    end

end