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

nep = Numerics.NLEVPData(missing,'qep3');
nep.compute_reference = true;

N = 32; contour = Contour.Circle(0,2.25,N);

c = Numerics.CIM(nep,contour,ax1,ax2);

c.SampleData.ell = 5;
c.SampleData.r = 5;

c.RealizationData.K = 5;
c.RealizationData.m = 4;

%c.RealizationData.ShiftScale = 2;

% uncomment the line below to see the same trajectory using MPLoewner
%c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

c.compute()

c.auto = true;

pause(5);

steps = 200; plength=0.1; y = linspace(0,1.25,steps);
for i=1:length(y)
    title(ax1,sprintf("center = %d",y(i)));
    c.SampleData.Contour.center = y(i);
    pause(plength);
end
