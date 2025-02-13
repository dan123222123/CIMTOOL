%% construct fn in tf and pole-residue form
n = 4; m = n; p = n;
um = 2; % set unstable pole multiplicity
ewref = [(-1:-1:-n+um) ones(1,2)]; A = diag(ewref);
%
B = randn(n,m); C = randn(p,n);
% B = eye(n,m); C = eye(p,n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) inv(ihml(z,n,ewref,B,C));
s = tf('s'); bode(Th(s),Tg(s));
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
contour = Numerics.Contour.Ellipse(-1,n+0.1,0.5,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
% c = CIMTOOL(CIM);
%% check initial bode
% CIM.SampleData.Lf = eye(n); CIM.SampleData.Rf = eye(n);
% CIM.SampleData.Lf = randn(n,CIM.SampleData.ell); CIM.SampleData.Rf = randn(n,CIM.SampleData.r);

% CIM.SampleData.Contour.alpha = n-1.5;
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
close all;
nyquistplot(H(s),Hrhnk(s),Hrmpl(s));
figure;
bode(H(s),Hrhnk(s),Hrmpl(s));
%% changing radius bode, fixed N
CIM.SampleData.Contour.gamma = -1.5; alphas = 3; CIM.SampleData.Contour.N = 64;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;

x = linspace(alphas,1.5,30);
for i=1:length(x)
    CIM.SampleData.Contour.alpha = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec;
    try
        CIM.compute();
    catch
        warning("failed at alpha=%d",x(i))
    end
    Hr = CIM.ResultData.rtf(); nyquist(H(s),Hr(s));
    drawnow;
end