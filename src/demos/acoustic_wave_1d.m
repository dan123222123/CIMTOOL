%% loading the problem+contour and starting the GUI

N = 506; Xi = 1.0001;
n = Visual.OperatorData([],'acoustic_wave_1d',sprintf("%f,%f",N,Xi));
c = Visual.Contour.Circle(0.8i,10);
cim = Visual.CIM(n,c);

nref = 50; refew = zeros(2*nref,1);
for k=-nref:nref
    refew(k+nref+1) = atan(1i*Xi)/(2*pi) + k/2;
end
CIM.SampleData.OperatorData.refew = refew;

cimtool = CIMTOOL(cim);
%%
cim.SampleData.Contour.N = 128;
p = 15; cim.SampleData.ell = p; cim.SampleData.r = p;
cim.RealizationData.m = 42;
%%
cim.setComputationalMode(Numerics.ComputationalMode.Hankel)
cim.RealizationData.K = 4;
cim.compute();
max(Numerics.relres(n.T,cim.ResultData.ew,cim.ResultData.rev,Numerics.SampleMode.Inverse))
%%
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner)
cim.RealizationData.K = 4*p;
cim.compute();
max(Numerics.relres(n.T,cim.ResultData.ew,cim.ResultData.rev,Numerics.SampleMode.Inverse))
