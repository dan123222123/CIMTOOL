nlevp = Numerics.NLEVPData(missing,'plasma_drift');
contour = Numerics.Contour.Ellipse(0.3i,3,0.4,256);
CIM = Numerics.CIM(nlevp,contour);

% changing the method parameters
CIM.SampleData.ell = 20; CIM.SampleData.r = 20;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.m = floor(length(nlevp.refew(CIM.SampleData.Contour.inside(nlevp.refew)))/2);
CIM.RealizationData.K = 2*CIM.RealizationData.m;

c = CIMTOOL(CIM);

CIM.compute();