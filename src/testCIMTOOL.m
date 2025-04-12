import Visual.*
% nlevp = Numerics.NLEVPData([],'plasma_drift');
% contour = Numerics.Contour.Ellipse(0.3i,3,0.4,32);
nlevp = OperatorData([],'omnicam1');
contour = Contour.Circle(0.4,0.2,8);

% nlevp = Numerics.NLEVPData([],'gun');
% contour = Numerics.Contour.Circle(141000,30000);

c = CIM(nlevp,contour);
c.SampleData.ell = 3; c.SampleData.r = 3;
c.RealizationData.RealizationSize = Numerics.RealizationSize(3,3);
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

CTOOL = CIMTOOL(c);

% % % plasma_drift
% CIM.SampleData.ell = 100; CIM.SampleData.r = 100;
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% % CIM.RealizationData.m = floor(length(nlevp.refew(CIM.SampleData.Contour.inside(nlevp.refew)))/2);
% CIM.RealizationData.m = 143;
% % CIM.RealizationData.K = 2*CIM.RealizationData.m;
% CIM.RealizationData.K = 200;

% omnicam1
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% CIM.RealizationData.RealizationSize = Numerics.RealizationSize(3,3);

% % gun
% CIM.SampleData.Contour.N = 64;
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% CIM.RealizationData.K = 32;
% CIM.RealizationData.m = 17;
% CIM.SampleData.ell = 32;
% CIM.SampleData.r = 32;

% CIM.compute();

