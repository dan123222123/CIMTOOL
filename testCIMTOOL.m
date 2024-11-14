% nlevp = Numerics.NLEVPData(missing,'plasma_drift');
% contour = Numerics.Contour.Ellipse(0.3i,3,0.4,256);
nlevp = Numerics.NLEVPData(missing,'omnicam1');
contour = Numerics.Contour.Circle(0.4,0.2,8);

CIM = Numerics.CIM(nlevp,contour);

% % plasma_drift
% CIM.SampleData.ell = 20; CIM.SampleData.r = 20;
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% CIM.RealizationData.m = floor(length(nlevp.refew(CIM.SampleData.Contour.inside(nlevp.refew)))/2);
% CIM.RealizationData.K = 2*CIM.RealizationData.m;

% omnicam1
CIM.SampleData.ell = 3; CIM.SampleData.r = 3; CIM.RealizationData.m = 3; CIM.RealizationData.K = 2;

c = CIMTOOL(CIM);

CIM.compute();