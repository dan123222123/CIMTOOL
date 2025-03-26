%% construct fn in tf and pole-residue form
n = 6; m = n; p = n; ewref = -1:-1:-n;
A = diag(ewref); B = randn(n,m); C = randn(p,n);
%
H = @(z) C*((z*eye(size(A)) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
%
w = logspace(-3,3); % Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(0,n+1,0.5,5e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false; CIM.SampleData.NLEVP.refew = ewref;
CIM.auto_update_shifts = false;
CIM.SampleData.ell = n; CIM.SampleData.r = n;
%
CIMHNK = copy(CIM);
CIMHNK.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIMHNK.RealizationData.K = 1;
%
CIMMPL = copy(CIM);
CIMMPL.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIMMPL.RealizationData.K = 5;

ip = 1i*(100:-1:-100); [~,idx] = sort(abs(ip));
ip = ip(idx); ip(1) = [];

theta = []; sigma = [];

for i = 1:2*n
    if mod(i,2) == 0
        theta(end+1) = ip(2*i-1);
        theta(end+1) = ip(2*i);
    else
        sigma(end+1) = ip(2*i-1);
        sigma(end+1) = ip(2*i);
    end
end

CIMMPL.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
%% inspect CIM if desired
% c = CIMTOOL(CIMHNK); daspect(CIMHNK.MainAx,'auto');
% xlim(CIMHNK.MainAx,[-n-2 1]); ylim(CIMHNK.MainAx,[-1 1]);
%% check initial bode
nec = length(ewref(CIMMPL.SampleData.Contour.inside(ewref)));
%
f = figure(1); plot_mt(f,w,nec,ewref,B,C,CIMHNK,CIMMPL);
%% modal truncation investigation
x = linspace(n+1,1.5,101);
for i = 1:length(x)
    CIMHNK.SampleData.Contour.alpha = x(i);
    CIMMPL.SampleData.Contour.alpha = x(i);
    %
    nec = length(ewref(CIMHNK.SampleData.Contour.inside(ewref)));
    %
    plot_mt(f,w,nec,ewref,B,C,CIMHNK,CIMMPL);
    drawnow;
end

function plot_mt(f,w,m,ewref,B,C,CIMHNK,CIMMPL)
    t = tiledlayout(f,4,4);
    HrMT = @(z) ihml(z,m,ewref,B,C);
    CIMHNK.RealizationData.m = m;
    CIMHNK.compute(); HrHNK = cimmt(CIMHNK,m);
    nexttile(t,1,[2 2]); CIMHNK.plot(gca); ylim([-1 1]);
    %
    CIMMPL.RealizationData.m = m;
    CIMMPL.compute(); HrMPL = cimmt(CIMMPL,m);
    nexttile(t,9,[2 2]); CIMMPL.plot(gca); ylim([-1 1]);
    %
    nexttile(t,3,[4,2]); Nbode(w,HrMT,HrHNK,HrMPL)
    legend('HrMT','HrHNK','HrMPL','Location','northoutside','Orientation','horizontal')
end