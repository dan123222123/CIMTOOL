%% construct fn in tf and pole-residue form
n = 100; d = 50; m = n; p = n;
ewref = d*((2*rand(n,1)-1) + 1i*((2*rand(n,1)-1)));
[~,ewsidx] = sort(abs(ewref)); ewref = ewref(ewsidx);
A = diag(ewref);
%
B = randn(n,m); C = randn(p,n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) iihml(z,n,ewref,B,C);
w = logspace(-1,4); Nbode(w,H,G);
%
Hw = arrayfun(G,1i*w,'UniformOutput',false);
Hw = cat(3,Hw{:}); Hw = pagenorm(Hw); Hw = Hw(:);
fp = max(Hw);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
contour = Numerics.Contour.Circle(0,norm(A)*1.05,1e2);
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
figure; Nbode(w,H,Hrhnk,Hrmpl);
%% changing radius bode, fixed N
sradius = norm(A)*1.05; CIM.SampleData.Contour.N = 64;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
% CIM.SampleData.ell = 34; CIM.SampleData.r = 34; CIM.RealizationData.K = 3;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = 7; CIM.SampleData.r = 7; CIM.RealizationData.K = K;

x = linspace(sradius,15,50); mnmm = zeros(length(x),1);
for i=1:length(x)
    CIM.SampleData.Contour.rho = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    Gr = @(z) ihml(z,nec,ewref,B,C); Hr = CIM.ResultData.rtf();
    GrHre = @(z) Gr(z) - Hr(z);
    % Nbode(w,H,Gr,Hr); legend('H','Gr','Hr','Location','northoutside','Orientation','horizontal');
    Nbode(w,GrHre);
    % Hw = arrayfun(GrHre,1i*w,'UniformOutput',false);
    % Hw = cat(3,Hw{:}); Hw = pagenorm(Hw); Hw = Hw(:);
    % mnmm(i) = max(Hw);
    drawnow; pause(0.1);
end
% figure; semilogy(x,mnmm/fp);
%% changing N bode, fixed radius
CIM.SampleData.Contour.rho = 10; CIM.SampleData.Contour.N = 8;
% %
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
% CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = 4;
% CIM.SampleData.ell = 10; CIM.SampleData.r = 10; CIM.RealizationData.K = 5;
% CIM.SampleData.ell = 6; CIM.SampleData.r = 6; CIM.RealizationData.K = 7;
% %
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = K;

CIM.compute();

for i=1:8
    CIM.refineQuadrature();
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    Gr = @(z) ihml(z,nec,ewref,B,C); Hr = CIM.ResultData.rtf();
    GrHe = @(z) H(z) - Gr(z); GrHre = @(z) Gr(z) - Hr(z);
    % Nbode(w,H,Gr,Hr); legend('H','Gr','Hr','Location','northoutside','Orientation','horizontal'); drawnow; pause(0.1)
    Nbode(w,GrHre); hold on;
    drawnow;
end
hold off;