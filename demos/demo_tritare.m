%%
theta = 2*pi/3;
[T,TV,gamma,nodes,edges,ew] = tritare(theta);% T = @(s) inv(H(s));

nlevp = Numerics.NLEVPData(T);
contour = Numerics.Contour.Ellipse(0,0.5,4);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;

CIM.SampleData.NLEVP.refew = ew;

c = CIMTOOL(CIM);
%%
CIM.SampleData.Contour.N = 64;
CIM.SampleData.Contour.gamma = 2.25i;
CIM.SampleData.Contour.alpha = 0.5;
CIM.SampleData.Contour.beta = 2;
CIM.SampleData.ell = 64; CIM.SampleData.r = 64;
CIM.RealizationData.m = 11;

% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.RealizationData.K = 4;

CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 64;

CIM.compute();
%%
x = linspace(2.25,3.75,200);
for i=1:length(x)
    CIM.SampleData.Contour.gamma = 1i*x(i);
    CIM.SampleData.Contour.beta = 4.25 - x(i);
    CIM.RealizationData.m = length(ew(CIM.SampleData.Contour.inside(ew)));
    CIM.compute();
    drawnow
end
