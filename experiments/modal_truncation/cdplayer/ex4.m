%% construct fn in tf and pole-residue form
load('./CDplayer.mat'); n = size(A,1);
[V,Lambda] = eig(full(A)); ewref = diag(Lambda);
BB = V\B; CC = C*V;
%
H = @(z) C*((z*speye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,3,500); Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(mean(ewref),800,6e4,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
xlim(CIM.MainAx,[-1100 100]); ylim(CIM.MainAx,[-6e4 6e4]);
%% changing radius bode, fixed N

CIM.SampleData.Contour.N = 2048;

x = linspace(75,5,5);
for i=1:length(x)
    CIM.SampleData.Contour.beta = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

    % CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    % K = 180; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;
    CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf(nec); Hrmpl = @(z) V2*((M21-z*M22)\W2);
    Her = @(z) H(z) - Hrmpl(z);
    Nbode(w,H,Hrmpl); legend('H','Hmpl','Location','northoutside','Orientation','horizontal');
    % Nbode(w,Her); legend('Her','Location','northoutside','Orientation','horizontal');
    %
    % Nbode(w,H,Hrhnk,Hrmpl); legend('H','Hhnk','Hmpl','Location','northoutside','Orientation','horizontal');
    % CIM.SampleData.Contour.rho = x(i);
    % nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    % CIM.SampleData.ell = i; CIM.SampleData.r = i; CIM.RealizationData.K = i; CIM.RealizationData.m = i;
    % CIM.compute(); 
    drawnow;
end