%% loading the problem+contour and starting the GUI

N = 506; Xi = 1.0001; nlevp = Numerics.NLEVPData(missing,'acoustic_wave_1d',sprintf("%f,%f",N,Xi));
contour = Numerics.Contour.Circle(0.8i,10);
CIM = Numerics.CIM(nlevp,contour);

nref = 50; refew = zeros(2*nref,1);
for k=-nref:nref
    refew(k+nref+1) = atan(1i*Xi)/(2*pi) + k/2;
end
CIM.SampleData.NLEVP.refew = refew;

c = CIMTOOL(CIM);
%%
CIM.SampleData.Contour.N = 512;
CIM.RealizationData.m = 42;
p = 15; CIM.SampleData.ell = p; CIM.SampleData.r = p;
%%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.RealizationData.K = 4;
CIM.compute();
max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.rev))
%%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.RealizationData.K = 4*p;
CIM.compute();
max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.rev))