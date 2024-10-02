% make main and sv axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1,DataAspectRatioMode="manual");

f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);

n = 3; A = diag(1:n); T = @(z) A - z*eye(n);

%nep = Numerics.NLEVPData(missing,'qep3');
nep = Numerics.NLEVPData(T,'linear_test');
nep.refew = 1:n;
%nep.compute_reference = true;

N = 8; contour = Contour.Circle(0,2.25,N);

c = Numerics.CIM(nep,contour,ax1,ax2);

c.SampleData.ell = 2;
c.SampleData.r = 2;

c.RealizationData.K = 1;
c.RealizationData.m = 2;

c.compute()

c.auto = true;

% uncomment the line below to see the same trajectory using MPLoewner
%c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

pause(5);

steps = 100; plength=0.1; y = linspace(0,0.75,steps);
for i=1:length(y)
    title(ax1,sprintf("center = %d",y(i)));
    c.SampleData.Contour.center = y(i);
    pause(plength);
end
