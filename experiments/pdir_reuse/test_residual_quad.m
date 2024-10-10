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
legend(ax3,'Interpreter','Latex')
hold(ax3,"on")
%
f4 = figure(4);
clf(f4);
ax4 = axes(f4,'yscale','log');
cla(ax4);
title(ax4,"best relative rank drop ratio")
xlabel(ax4,"N")
ylabel(ax4,'argmin m $\frac{\sigma_{m+1}}{\sigma_m}$','Interpreter','latex')
legend(ax4,'Interpreter','Latex')
hold(ax4,"on")
%
f5 = figure(5);
clf(f5);
ax5 = axes(f5);
cla(ax5);
title(ax5,"best guess of m (based on relative rank drop ratio)")
xlabel(ax5,"N")
ylabel(ax5,"m")
legend(ax5,'Interpreter','Latex')
hold(ax5,"on")
%
prob = 'qep3';
nep = Numerics.NLEVPData(missing,prob,'5i');
nep.compute_reference = true;
N = 128; contour = Contour.Circle(0,2.25,N);
c = Numerics.CIM(nep,contour,ax1,ax2);
c.SampleData.Contour.plot_quadrature = true;
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
n = c.SampleData.NLEVP.n;
[theta,sigma] = Numerics.interlevedshifts(contour.z,2*n);
L = Numerics.SampleData.sampleMatrix(n,2*n);
R = Numerics.SampleData.sampleMatrix(n,2*n);
axis(ax1,"equal");
ColOrd = get(gca,'ColorOrder');
c.RealizationData.ShiftScale = 2;

%% exact MPLoewner realization using the exact transfer function
c.RealizationData.K = 10;
ylim(ax5,[0,c.RealizationData.K])
c.RealizationData.m = 2;
%
for j = 1:n
    Lt = L(:,1:j); Rt = R(:,1:j);
    c.SampleData.L = Lt;
    c.SampleData.R = Rt;
    Col = ColOrd(j,:);
    mresal = [];
    rrd = [];
    bgm = [];
    Nsteps = 10:1:100; steps = length(Nsteps);
    intN = [10,40,70,150];
    for i=1:length(Nsteps)
        title(ax1,sprintf("N = %d",Nsteps(i)));
        c.SampleData.Contour.N = Nsteps(i);
        if any(Nsteps(i) == intN(:))
            saveas(f2,sprintf("%s_m%d_pdir%d_DbDssw_N%d.png",prob,c.RealizationData.m,j,Nsteps(i)));
        end
        try
            c.compute();
        catch E
            warning("issue at N = %d",Nsteps(i));
            rethrow(E);
        end
        if any(Nsteps(i) == intN(:))
            saveas(f2,sprintf("%s_m%d_pdir%d_DbDssw_N%d.png",prob,c.RealizationData.m,j,Nsteps(i)));
        end
        mresal(i) = Numerics.maxrelresidual(c);
        chsv = c.ResultData.Dbsw;
        [m,d] = findrankdrop(chsv);
        rrd(i) = d;
        bgm(i) = m;
    end
    l = sprintf("$\\ell'=r'=%d$",j);
    plot(ax3,Nsteps,mresal,'DisplayName',l,'Color',Col);
    plot(ax4,Nsteps,rrd,'DisplayName',l,'Color',Col);
    plot(ax5,Nsteps,bgm,'DisplayName',l,'Color',Col);
end
axis(ax1,"equal");
saveas(f1,sprintf("%s_m%d_cplane.png",prob,c.RealizationData.m))
saveas(f3,sprintf("%s_m%d_rre.png",prob,c.RealizationData.m))
saveas(f4,sprintf("%s_m%d_rrd.png",prob,c.RealizationData.m))
saveas(f5,sprintf("%s_m%d_bgm.png",prob,c.RealizationData.m))