%% construct fn in tf and pole-residue form
n = 100; d = 10; m = n; p = n;
ewref = (d*(randn(n,1) + 1i*randn(n,1)));
[~,ewsidx] = sort(abs(ewref)); ewref = ewref(ewsidx);
A = diag(ewref);
%
B = randn(n,m); C = randn(p,n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) iihml(z,n,ewref,B,C);
w = logspace(-1,4); Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
contour = Numerics.Contour.Circle(0,norm(A)+d,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
c = CIMTOOL(CIM);
%% check initial bode

nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
CIM.compute(); [~,V1,W1,M11,M12] = CIM.ResultData.rtf();
Hrhnk = @(z) V1*((-M11+z*M12)\W1);
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = n;
CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf();
Hrmpl = @(z) V2*((M21-z*M22)\W2);
%
close all; Nbode(w,H,Hrhnk,Hrmpl);
%% changing radius bode, fixed N
sradius = norm(A)+d; CIM.SampleData.Contour.N = 256;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = 4;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
K = n; CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = K;

x = linspace(sradius,5,30);
for i=1:length(x)
    CIM.SampleData.Contour.rho = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    G = @(z) ihml(z,nec,ewref,B,C); Hr = CIM.ResultData.rtf();
    Nbode(w,H,G,Hr); legend('H','Gr','Hr','Location','northoutside','Orientation','horizontal'); drawnow; pause(0.1)
end
%% changing N bode, fixed radius
CIM.SampleData.Contour.rho = 10; CIM.SampleData.Contour.N = 8;
% %
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = 4;
% %
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = K;

for i=25:25:300
    CIM.SampleData.Contour.N = i;
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    G = @(z) ihml(z,nec,ewref,B,C); Hr = CIM.ResultData.rtf();
    Nbode(w,H,G,Hr); legend('H','Gr','Hr','Location','northoutside','Orientation','horizontal'); drawnow; pause(0.1)
end