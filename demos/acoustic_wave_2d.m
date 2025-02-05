%% loading the problem+contour and starting the GUI

N = 506; Xi = 1; nlevp = Numerics.NLEVPData(missing,'acoustic_wave_2d',sprintf("%f,%f",N,Xi));
contour = Numerics.Contour.Circle(5+0.5,0.5,10);
CIM = Numerics.CIM(nlevp,contour);

c = CIMTOOL(CIM);
%%
CIM.SampleData.Contour.N = 512;
CIM.RealizationData.m = 42;
p = 15; CIM.SampleData.ell = p; CIM.SampleData.r = p;
%%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.RealizationData.K = 4;
CIM.compute();
max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev))
%%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 4*p;
CIM.compute();
max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev))