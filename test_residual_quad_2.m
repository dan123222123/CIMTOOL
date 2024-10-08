%% make main and sv axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1);
title(ax1,"Complex Plane")
%
f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);
title(ax2,"Db/Ds Singular Values")
legend(ax2);
%
f3 = figure(3);
clf(f3);
ax3 = axes(f3,'yscale','log');
cla(ax3);
title(ax3,"Relative Residual Error")
xlabel(ax3,"N")
%mresal = animatedline(ax3);
%
f4 = figure(4);
clf(f4);
ax4 = axes(f4,'yscale','log');
cla(ax4);
title(ax4,"best relative rank drop ratio")
xlabel(ax4,"N")
%rrd = animatedline(ax4);
%
f5 = figure(5);
clf(f5);
ax5 = axes(f5);
cla(ax5);
title(ax5,"best guess of m (based on relative rank drop ratio)")
xlabel(ax5,"N")
%bgm = animatedline(ax5,"Marker","o");
%
nep = Numerics.NLEVPData(missing,'plasma_drift');
nep.compute_reference = true;
N = 128; contour = Contour.Circle(-0.4+0.16i,0.3,N);
c = Numerics.CIM(nep,contour,ax1,ax2);
c.SampleData.Contour.plot_quadrature = true;
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
n = c.SampleData.NLEVP.n;
[theta,sigma] = Numerics.interlevedshifts(contour.z,2*n);
L = Numerics.SampleData.sampleMatrix(n,n);
R = Numerics.SampleData.sampleMatrix(n,n);
axis(ax1,"equal");
ColOrd = get(gca,'ColorOrder');
c.RealizationData.ShiftScale = 1.25;

%% exact MPLoewner realization using the exact transfer function
ell = 3; r = ell;
Lt = L(:,1:ell); Rt = R(:,1:r);
c.SampleData.L = Lt;
c.SampleData.R = Rt;
c.RealizationData.K = 6;
ylim(ax5,[0,c.RealizationData.K])
c.RealizationData.m = 6;
c.compute();
%
Col = ColOrd(ell,:);
mresal = animatedline(ax3,Color=Col);
rrd = animatedline(ax4,Color=Col);
bgm = animatedline(ax5,Color=Col);
%
plength=0; y = 10:5:100; steps = length(y);
for i=1:length(y)
    title(ax1,sprintf("N = %d",y(i)));
    c.SampleData.Contour.N = y(i);
    axis(ax1,"equal");
    if mod(y(i),2*c.RealizationData.K)==0
        xline(ax3,y(i));
        xline(ax4,y(i));
        xline(ax5,y(i));
    end
    try
        c.compute();
    catch E
        warning("issue at N = %d",y(i));
        rethrow(E);
    end
    pause(plength);
    addpoints(mresal,y(i),Numerics.maxrelresidual(c));
    chsv = c.ResultData.Dbsw;
    [m,d] = findrankdrop(chsv);
    addpoints(rrd,y(i),d);
    addpoints(bgm,y(i),m);
    drawnow limitrate
end