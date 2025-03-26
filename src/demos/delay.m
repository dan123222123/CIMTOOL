%% loading the problem+contour and starting the GUI
n=50; c=0.015; tau=8; E0 = diag(-1*logspace(-4,10));
T = @(z) z*eye(n) + c*exp(-tau*z)*eye(n) - E0;

nlevp = Numerics.NLEVPData(T,'delay');
contour = Numerics.Contour.Circle(-0.5,0.2,8);

CIM = Numerics.CIM(nlevp,contour);
CIM.RealizationData.m = 11;
CIM.SampleData.Contour.N = 64;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;

% need to compute reference with w fun

c = CIMTOOL(CIM);
%% S1
CIM.SampleData.ell = 11;
CIM.SampleData.r = 11;
CIM.RealizationData.K = 1;
CIM.compute();