import Visual.*
% n = OperatorData([],'plasma_drift');
% c = Contour.Ellipse(0.3i,3,0.4,32);
n = OperatorData([],'omnicam1');
c = Contour.Circle(0.4,0.2,8);

% n = OperatorData([],'gun');
% c = Contour.Circle(141000,30000);

cim = CIM(n,c);
cim.SampleData.ell = 3; cim.SampleData.r = 3;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(3,3);
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

CTOOL = CIMTOOL(cim);

% % % plasma_drift
% cim.SampleData.ell = 100; cim.SampleData.r = 100;
% cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% % cim.RealizationData.m = floor(length(n.refew(cim.SampleData.Contour.inside(n.refew)))/2);
% cim.RealizationData.m = 143;
% % cim.RealizationData.K = 2*cim.RealizationData.m;
% cim.RealizationData.K = 200;

% omnicam1
% cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% cim.RealizationData.RealizationSize = Numerics.RealizationSize(3,3);

% % gun
% cim.SampleData.Contour.N = 64;
% cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% cim.RealizationData.K = 32;
% cim.RealizationData.m = 17;
% cim.SampleData.ell = 32;
% cim.SampleData.r = 32;

% cim.compute();
