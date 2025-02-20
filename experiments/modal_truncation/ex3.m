%% chebfun example code
n = 200; d = [0,1];

x = chebpts(n,d); L = diffmat(n,2,d,'dirichlet','dirichlet');

a = @(x) (1 - sin(pi*x));
% a = @(x) 1/2 + exp(-256*(0.5 - x).^2);
% a = @(x) (1 - sin((11*pi)*x).*exp(-10*(x - 1/2).^2));

Aref = [zeros(n) eye(n);L -2*diag(a(x))];

ewref = eig(Aref);

% sort by magnitude
[~,ewidx] = sort(abs(ewref)); ewref = ewref(ewidx);
% filter 0 < imag(ewref) <= 50, note "real" eig are not included
ewref = ewref(imag(ewref) > 0); ewref = ewref(imag(ewref) <= 150);

scatter(real(ewref),imag(ewref)); grid;
[~,lmidx] = max(abs(ewref)); a0 = - real(ewref(lmidx));
hold on; xline(-a0); hold off;
xlim([-1.3 0]); ylim([0 50]); 

% aa = @(x) aaprox(ewref,x);
% plot(x,a(x)); hold on; plot(x,aa(x)); hold off;
% plot(x,abs(a(x)-aa(x)));

% plot(chebfun(a,[0,1],n))
%% reproducing 
contour = Numerics.Contour.Ellipse(-a0,0.5,100,1e2);

ewin = ewref(contour.inside(ewref));

aa = @(x) aaprox(ewin,x);
plot(x,a(x)); hold on; plot(x,aa(x)); hold off;
%% tf
n = length(ewref);
[~,ewsidx] = sort(abs(ewref)); ewref = ewref(ewsidx);
A = diag(ewref); B = eye(n); C = eye(n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
Th = @(z) pinv(B)*(z*eye(n) - A)*pinv(C); Tg = @(z) iihml(z,n,ewref,B,C);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Tg);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.NLEVP.refew = ewref;
c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto')
xlim(CIM.MainAx,[-2 0]); ylim(CIM.MainAx,[0 160]);
%% check initial bode
nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = 1;
% CIM.compute(); ewc = CIM.ResultData.ew; [~,ewcidx] = sort(abs(ewc)); ewc = ewc(ewcidx);
% aa = @(x) aaprox(ewc,x); plot(x,a(x)); hold on; plot(x,aa(x)); hold off;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = n; CIM.SampleData.r = n; CIM.RealizationData.K = n;
CIM.compute(); ewc = CIM.ResultData.ew; [~,ewcidx] = sort(abs(ewc)); ewc = ewc(ewcidx);
aa = @(x) aaprox(ewc,x); plot(x,a(x)); hold on; plot(x,aa(x)); hold off;
%% changing radius bode, fixed N
CIM.SampleData.show_progress = false;
sradius = 50; CIM.SampleData.Contour.N = 128;
%
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
% CIM.SampleData.ell = 32; CIM.SampleData.r = 32; CIM.RealizationData.K = 1;
% CIM.SampleData.ell = 16; CIM.SampleData.r = 16; CIM.RealizationData.K = 2;
% CIM.SampleData.ell = 8; CIM.SampleData.r = 8; CIM.RealizationData.K = 4;
% CIM.SampleData.ell = 4; CIM.SampleData.r = 4; CIM.RealizationData.K = 4;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
K = 32; CIM.SampleData.ell = K; CIM.SampleData.r = K; CIM.RealizationData.K = K;
% K = 32; CIM.SampleData.ell = 5; CIM.SampleData.r = 5; CIM.RealizationData.K = K;
% K = 16; CIM.SampleData.ell = 2; CIM.SampleData.r = 2; CIM.RealizationData.K = K;

rls = linspace(sradius,5,200);
for i=1:length(rls)
    CIM.SampleData.Contour.beta = rls(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    ewc = CIM.ResultData.ew; [~,ewcidx] = sort(abs(ewc)); ewc = ewc(ewcidx);
    aa = @(x) aaprox(ewc,x); plot(x,a(x)); hold on; plot(x,aa(x)); hold off;
    drawnow;
    %pause(0.1)
end