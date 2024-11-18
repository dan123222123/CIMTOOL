%% loading the problem+contour and starting the GUI
nlevp = Numerics.NLEVPData(missing,'gun');
contour = Numerics.Contour.Circle(141000,30000);

CIM = Numerics.CIM(nlevp,contour);
CIM.RealizationData.m = 17;

c = CIMTOOL(CIM);
%% extra parameters before running scenarios
CIM.SampleData.Contour.N = 64;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 32;
%% S1
CIM.SampleData.ell = 32;
CIM.SampleData.r = 32;
% CIM.RealizationData.K = 1;
CIM.compute();
%% S2
CIM.SampleData.ell = 16;
CIM.SampleData.r = 16;
% CIM.RealizationData.K = 2;
CIM.compute();
%% S3 -- does not work due to limited rank of constructed data matrices
CIM.SampleData.ell = 8;
CIM.SampleData.r = 8;
% CIM.RealizationData.K = 4;
CIM.compute();