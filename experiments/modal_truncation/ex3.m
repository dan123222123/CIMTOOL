%% chebfun example code
n = 200; d = [0,1];

x = chebpts(n,d); L = diffmat(n,2,'dirichlet','dirichlet');

% a = @(x) (1 - sin(pi*x));
a = @(x) 1/2 + exp(-256*(0.5 - x).^2);
% a = @(x) (1 - sin((11*pi)*x).*exp(-10*(x - 1/2).^2));

Aref = [zeros(n) eye(n);L -2*diag(a(x))]; ewref = eig(Aref);

scatter(real(ewref),imag(ewref));
xlim([-1.3 0]); ylim([0 50]); grid;

% plot(chebfun(a,[0,1],n))
%% tf
contour = Numerics.Contour.Circle(0,50,1e2);
ewref = ewref(contour.inside(ewref));
%
n = length(ewref);
[~,ewsidx] = sort(abs(ewref)); ewref = ewref(ewsidx);
A = diag(ewref); B = eye(n); C = eye(n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) iihml(z,n,ewref,B,C);
w = logspace(-1,4); Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
CIM = Numerics.CIM(nlevp,contour);
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
close all; Nbode(w,H,Hrhnk,Hrmpl); legend('H','HrHankel','HrMPL','Location','northoutside','Orientation','horizontal');
%% changing radius bode, fixed N
CIM.SampleData.show_progress = false;
sradius = norm(A)*1.1; CIM.SampleData.Contour.N = 128;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = 4;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% K = n; CIM.SampleData.ell = 25; CIM.SampleData.r = 25; CIM.RealizationData.K = K;

x = linspace(sradius,1,50);
for i=1:length(x)
    CIM.SampleData.Contour.rho = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    G = @(z) ihml(z,nec,ewref,B,C); Hr = CIM.ResultData.rtf();
    GHre = @(z) G(z) - Hr(z);
    Nbode(w,H,G,Hr); legend('H','Gr','Hr','Location','northoutside','Orientation','horizontal');
    % Nbode(w,GHre); legend('GHre','Location','northoutside','Orientation','horizontal');    
    drawnow; pause(0.1)
end