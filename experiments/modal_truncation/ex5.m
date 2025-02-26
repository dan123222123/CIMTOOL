%% construct fn in tf and pole-residue form
load('./iss.mat'); n = size(A,1);
A = full(A); B = full(B); C = full(C);
[V,Lambda] = eig(A); ewref = diag(Lambda);
BB = V\B; CC = C*V;
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
Th = @(z) pinv(H(z)); Tg = @(z) iihml(z,n,ewref,BB,CC);
w = logspace(-1,3,500);
% Nbode(w,H,G);
Nbode(w,Th,Tg);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
contour = Numerics.Contour.Ellipse(mean(ewref),1,norm(Lambda)*2,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
xlim(CIM.MainAx,[-1.5 1.5]); ylim(CIM.MainAx,[-125 125]);
%% check initial bode
CIM.SampleData.Contour.N = 2048;

nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.SampleData.ell = 3; CIM.SampleData.r = 3; CIM.RealizationData.K = n;
% CIM.compute(); [~,V1,W1,M11,M12] = CIM.ResultData.rtf();
% Hrhnk = @(z) V1*((-M11+z*M12)\W1);
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
K = 2*n; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;
CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf();
Hrmpl = @(z) V2*((M21-z*M22)\W2);
%
close all; Nbode(w,H,Hrmpl); legend('H','Hmpl','Location','northoutside','Orientation','horizontal');
%% changing radius bode, fixed N

CIM.SampleData.Contour.N = 1028;

x = linspace(75,5,5);
for i=1:length(x)
    % CIM.RealizationData.ShiftScale = x(i);
    CIM.SampleData.Contour.beta = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

    % CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
    % CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
    % CIM.compute(); [~,V1,W1,M11,M12] = CIM.ResultData.rtf(nec);
    % Hrhnk = @(z) V1*((-M11+z*M12)\W1);
    % %
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