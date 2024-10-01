% make main and sv axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1,DataAspectRatioMode="manual");

f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);

nep = Numerics.NLEVPData(missing,'qep3');
nep.compute_reference = true;

N = 8; contour = Contour.Circle(0,2.25,N);

c = Numerics.CIM(nep,contour,ax1,ax2);

c.SampleData.ell = 1;
c.SampleData.r = 1;

c.RealizationData.K = 4;
c.RealizationData.m = 4;

c.compute()

c.auto = true;

% uncomment the line below to see the same trajectory using MPLoewner
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

pause(5);

steps = 200; plength=0.1; y = linspace(1.25,5,steps);
for i=1:length(y)
    title(ax1,sprintf("Shift Scale = %d",y(i)));
    c.RealizationData.ShiftScale = y(i);
    pause(plength);
end
