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

n = 5;
A = gallery('grcar',n);
T = @(z) A - z*eye(n);

%nep = Numerics.NLEVPData(missing,'qep3');
nep = Numerics.NLEVPData(T,'grcar_test');
nep.refew = eig(A);
%nep.compute_reference = true;

scenter = 0.5;
sradius = 1.5;

N = 16; contour = Contour.Circle(scenter,sradius,N);

c = Numerics.CIM(nep,contour,ax1,ax2);

c.SampleData.ell = 3;
c.SampleData.r = 3;

c.RealizationData.K = 1;
c.RealizationData.m = 3;

c.compute()

c.auto = true;

% uncomment the line below to see the same trajectory using MPLoewner
%c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

pause(5);

steps = 100; plength=0.1; y = linspace(scenter,scenter+0.75,steps);
for i=1:length(y)
    title(ax1,sprintf("center = %d",y(i)));
    c.SampleData.Contour.center = y(i);
    pause(plength);
end
