%% construct fn in tf and pole-residue form
n = 5; m = n; p = n;
ewref = (-1:-1:-n);
% ewref = [(-1:-1:-n) 1:1:n];
A = diag(ewref); B = randn(n,m); C = randn(p,n);
%
H = @(z) C*((z*eye(size(A)) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
%
w = logspace(-3,3); % Nbode(w,H,G);
%% setup CIMTOOL
nlevp1 = Numerics.NLEVPData(H); nlevp1.sample_mode = Numerics.SampleMode.Direct;
contour1 = Numerics.Contour.Ellipse(0,n+1,0.5,100);
nlevp2 = Numerics.NLEVPData(H); nlevp2.sample_mode = Numerics.SampleMode.Direct;
contour2 = Numerics.Contour.Ellipse(0,n+1,0.5,100);
%
CIMHNK = Numerics.CIM(nlevp1,contour1);
CIMHNK.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIMHNK.SampleData.show_progress = false;
CIMHNK.SampleData.NLEVP.refew = ewref;
CIMHNK.SampleData.ell = n; CIMHNK.SampleData.r = n;
%
CIMMPL = Numerics.CIM(nlevp2,contour2);
CIMMPL.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIMMPL.SampleData.show_progress = false;
CIMMPL.SampleData.NLEVP.refew = ewref;
CIMMPL.auto_update_shifts = false;
CIMMPL.SampleData.ell = n; CIMMPL.SampleData.r = n;

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
x = linspace(n+1,1.5,100); 
for i = 1:length(x)
    CIMHNK.SampleData.Contour.alpha = x(i);
    CIMMPL.SampleData.Contour.alpha = x(i);
    %
    nec = length(ewref(CIMHNK.SampleData.Contour.inside(ewref)));
    %
    plot_mt(f,w,nec,ewref,B,C,CIMHNK,CIMMPL);
    drawnow;
end
%%
%
%
%
function plot_mt(f,w,m,ewref,B,C,CIMHNK,CIMMPL)
    t = tiledlayout(f,4,4);
    HrMT = @(z) ihml(z,m,ewref,B,C);
    CIMHNK.RealizationData.m = m; CIMHNK.RealizationData.K = 1;
    CIMHNK.compute(); HrHNK = cimmt(CIMHNK,m);
    nexttile(t,1,[2 2]); CIMHNK.plot(gca);
    %
    CIMMPL.RealizationData.m = m; CIMMPL.RealizationData.K = 5;
    CIMMPL.compute(); HrMPL = cimmt(CIMMPL,m);
    nexttile(t,9,[2 2]); CIMMPL.plot(gca);
    %
    nexttile(t,3,[4,2]); Nbode(w,HrMT,HrHNK,HrMPL)
    legend('HrMT','HrHNK','HrMPL','Location','northoutside','Orientation','horizontal')
end