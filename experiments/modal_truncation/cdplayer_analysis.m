pdir = fileparts(mfilename('fullpath')); sdir = strcat(pdir,"/cdplayer_analysis"); mkdir(sdir);
%% load CDplayer
load('./CDplayer.mat'); n = size(A,1);
[V,Lambda] = eig(full(A)); ewref = diag(Lambda);
BB = V\B; CC = C*V;
%
H = @(z) C*((z*speye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,6,500); Nbode(w,H,G);

% nlevp
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct; nlevp.refew = ewref;

% base contour
contour = Numerics.Contour.Ellipse(mean(ewref),150,1e4,3e3);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;

% base realization parameters
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
%
CIM.SampleData.ell = 2; CIM.SampleData.r = 2;
CIM.RealizationData.K = 200;
CIM.RealizationData.ShiftScale = 1.4;
%
nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
CIM.RealizationData.m = nec;

% test that parameters are "sufficient"
% CIM.compute();
%% CIMTOOL about spectra
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-1100 100]); ylim(CIM.MainAx,[-6e4 6e4]);
%% Make a contour conga line
x = linspace(-800,0,10); f = @(x) x - 50*1i*x;
for i=1:length(x)
    CIM.SampleData.Contour.gamma = f(x(i));
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    if nec == 0
        continue;
    end
    CIM.RealizationData.m = nec; CIM.compute();
    %
    csdir = strcat(sdir,sprintf("/c%d",i)); mkdir(csdir);
    save(strcat(csdir,"/cim"),"contour","nlevp","CIM"); 
    %
    ellrrank(csdir,CIM,1:6,H,w);
    %
    CIM.SampleData.ell = 2; CIM.SampleData.r = 2;
    ssrank(csdir,CIM,linspace(3,1.1,300),H,w);
    %
    CIM.RealizationData.ShiftScale = 1.4;
    Nrank(csdir,CIM,1e3:113:6e3,H,w);
    %
    CIM.SampleData.Contour.N = 3e3;
end