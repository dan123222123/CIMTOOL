import Numerics.*
% Build GUI-reactive (Visual.*) objects so the handle we keep in `cim` is the
% SAME one CIMTOOL drives. CIMTOOL only shares the handle when it is already a
% Visual.CIM; a Numerics.CIM gets converted to a fresh Visual.CIM (via
% Visual.CIM.fromNumerics), which severs the link so later programmatic edits
% and cim.compute() would no longer affect the GUI. (RealizationSize and
% ComputationalMode below stay Numerics.* -- they have no Visual counterpart.)
n = Visual.OperatorData([],'plasma_drift');
c = Visual.Contour.Ellipse(0.3i,3,0.4,32);
% n = Visual.OperatorData([],'omnicam1');
% c = Visual.Contour.Circle(0.4,0.2,8);

% n = Visual.OperatorData([],'gun');
% c = Visual.Contour.Circle(141000,30000);

cim = Visual.CIM(n,c);
cim.SampleData.ell = 3; cim.SampleData.r = 3;
cim.RealizationData.RealizationSize = RealizationSize(3,3);
cim.RealizationData.ComputationalMode = ComputationalMode.MPLoewner;

CTOOL = CIMTOOL(cim);

% % plasma_drift
cim.SampleData.ell = 100; cim.SampleData.r = 100;
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% cim.RealizationData.m = floor(length(n.refew(cim.SampleData.Contour.inside(n.refew)))/2);
cim.RealizationData.m = 143;
% cim.RealizationData.K = 2*cim.RealizationData.m;
cim.RealizationData.K = 200;

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

cim.compute();
