%% roots of T
T = @(s) tan(s) - s;

tol = 10^-6; Ni = 2000; x = linspace(0,20,Ni); ew = zeros(size(x));
for i = 1:length(x)
    ew(i) = fsolve(T,x(i));
end
ew = ew(ew > 2); ew = ew(abs(T(ew)) < tol); ew = uniquetol(ew,sqrt(tol));
%% singularities of tan(x)
scatter(ew,0,'b'); hold on;
scatter((pi/2)*2*(0:10 + 1),0,'r');

%%
nlevp = Numerics.NLEVPData(T);
contour = Numerics.Contour.Ellipse(ew(2),4,1);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ew;
c = CIMTOOL(CIM);
%%
CIM.RealizationData.m = 3; CIM.RealizationData.K = 10; CIM.compute();
%%
for i = 4:32
    CIM.SampleData.Contour.N = i; CIM.compute();
    drawnow; pause(0.1);
end