%% construct fn in tf and pole-residue form
n = 5; m = n; p = n;
ewref = (-1:-1:-n);
% ewref = [(-1:-1:-n) 1:1:n];
A = diag(ewref); B = randn(n,m); C = randn(p,n);
%
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
%
w = logspace(-3,3); % Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(0,n+1,0.5,8);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
CIM.SampleData.Lf = eye(n,p); CIM.SampleData.Lf = eye(n,m);
CIM.SampleData.ell = 1; CIM.SampleData.r = 1;
%
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-n-2 1]); ylim(CIM.MainAx,[-1 1]);
%% check initial bode
nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;

%
close all; Nbode(w,H,HrHNK,HrMPL);
legend('H','HrHNK','HrMPL','Location','northoutside','Orientation','horizontal');
%% changing radius bode, fixed N
CIM.SampleData.Contour.gamma = -1.5; alphas = 3; CIM.SampleData.Contour.N = 64;

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
    G = @(z) ihml(z,nec,ewref,B,C); HrHNK = CIM.ResultData.rtf();
    Nbode(w,H,HrHNK);
    drawnow;
end

function [HrHNK,HrMPL] = amt(m,CIM)
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
    CIM.RealizationData.K = 5; CIM.compute(); HrHNK = cimmt(CIM,m);
    %
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    CIM.RealizationData.K = n; CIM.compute(); HrMPL = cimmt(CIM,m);
end

function plot_mt(m,H,CIM)
    
end