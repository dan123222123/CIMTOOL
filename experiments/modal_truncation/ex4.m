%% construct fn in tf and pole-residue form
load('./CDplayer.mat'); A = full(A); n = size(A,1);
[V,Lambda] = eig(A); ewref = diag(Lambda);
B = rand(size(A)); C = rand(size(A));
BB = V\B; CC = C*V;
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) iihml(z,n,ewref,BB,CC);
w = logspace(0,6); Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
contour = Numerics.Contour.Ellipse(-500,600,5e4,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-5 5]); ylim(CIM.MainAx,[-10 10]);
xlim(CIM.MainAx,[-1200 100]); ylim(CIM.MainAx,[-7e4 7e4]);
%% check initial bode
CIM.SampleData.Contour.N = 500;

nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
CIM.compute(); [~,V1,W1,M11,M12] = CIM.ResultData.rtf();
Hrhnk = @(z) V1*((-M11+z*M12)\W1);
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
K = 2*n; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;
CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf();
Hrmpl = @(z) V2*((M21-z*M22)\W2);
%
close all; Nbode(w,H,Hrhnk,Hrmpl); legend('H','Hhnk','Hmpl','Location','northoutside','Orientation','horizontal');
%% changing radius bode, fixed N
% sradius = norm(A)+d; CIM.SampleData.Contour.N = 64;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = 4;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = K;

for i=200:3:500
    CIM.SampleData.Contour.N = i;

    nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
    CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
    CIM.compute(); [~,V1,W1,M11,M12] = CIM.ResultData.rtf(nec);
    Hrhnk = @(z) V1*((-M11+z*M12)\W1);
    %
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    K = 180; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;
    CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf(nec);
    Hrmpl = @(z) V2*((M21-z*M22)\W2);
    %
    Nbode(w,H,Hrhnk,Hrmpl); legend('H','Hhnk','Hmpl','Location','northoutside','Orientation','horizontal');
    % CIM.SampleData.Contour.rho = x(i);
    % nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    % CIM.SampleData.ell = i; CIM.SampleData.r = i; CIM.RealizationData.K = i; CIM.RealizationData.m = i;
    % CIM.compute(); 
    drawnow;
end