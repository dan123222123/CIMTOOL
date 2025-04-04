% nlevp = Numerics.NLEVPData([],'plasma_drift');
% contour = Numerics.Contour.Ellipse(0.3i,3,0.4,32);

nlevp = Numerics.NLEVPData([],'omnicam1');
contour = Numerics.Contour.Circle(0.4,0.2,8);

% nlevp = Numerics.NLEVPData([],'gun');
% contour = Numerics.Contour.Circle(141000,30000);

CIM = Numerics.CIM(nlevp,contour);

% % % plasma_drift
% CIM.SampleData.ell = 100; CIM.SampleData.r = 100;
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% % CIM.RealizationData.m = floor(length(nlevp.refew(CIM.SampleData.Contour.inside(nlevp.refew)))/2);
% CIM.RealizationData.m = 143;
% % CIM.RealizationData.K = 2*CIM.RealizationData.m;
% CIM.RealizationData.K = 200;

% omnicam1
CIM.SampleData.ell = 3;
CIM.SampleData.r = 3;
CIM.RealizationData.m = 3;
CIM.RealizationData.K = 3;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

% % gun
% CIM.SampleData.Contour.N = 64;
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% CIM.RealizationData.K = 32;
% CIM.RealizationData.m = 17;
% CIM.SampleData.ell = 32;
% CIM.SampleData.r = 32;

CIM.compute();

c = CIMTOOL(CIM);