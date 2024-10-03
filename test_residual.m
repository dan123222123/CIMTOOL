%% make main and sv axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1,DataAspectRatioMode="manual");
title(ax1,"Complex Plane")

f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);
title(ax2,"Db/Ds Singular Values")
legend(ax2);

f3 = figure(3);
clf(f3);
ax3 = axes(f3,'yscale','log');
cla(ax3);
title(ax3,"Relative Residual Error")
xlabel(ax3,"step")
mresal = animatedline(ax3);
%%
nep = Numerics.NLEVPData(missing,'qep3');
nep.compute_reference = true;
N = 128; contour = Contour.Circle(0,2.25,N);
c = Numerics.CIM(nep,contour,ax1,ax2);
c.SampleData.ell = 3;
c.SampleData.r = 3;
c.RealizationData.K = 2;
c.RealizationData.m = 4;
c.auto = true;
c.compute();
%%
c.auto = false;
c.SampleData.ell = 2;
c.SampleData.r = 2;
c.RealizationData.K = 3;
c.RealizationData.m = 4;
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
c.auto = true;

c.compute();

pause(3);

clearpoints(mresal);
steps = 100; plength=0.1; y = linspace(0,0.75,steps);
for i=1:length(y)
    title(ax1,sprintf("center = %d",y(i)));
    c.SampleData.Contour.center = y(i);
    pause(plength);
    addpoints(mresal,i,maxrelresidual(c));
end
%%
c.auto = false;
c.SampleData.Contour.center = 0;
%c.SampleData.ell = 6;
%c.SampleData.r = 6;
c.RealizationData.K = 6;
c.RealizationData.m = 4;
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
c.auto = true;

c.compute();

clearpoints(mresal);

pause(3);

steps = 100; plength=0.1; y = linspace(0,0.75,steps);
for i=1:length(y)
    title(ax1,sprintf("center = %d",y(i)));
    c.SampleData.Contour.center = y(i);
    pause(plength);
    addpoints(mresal,i,maxrelresidual(c));
end
% note that MPLoewner ev realization seems different than the paper,
% but the rel residual error is better (and evs are not zero vectors, etc.)