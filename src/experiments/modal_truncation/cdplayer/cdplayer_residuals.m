% addpath("/home/dan1345/CIMTOOL/")
% addpath("/home/dan1345/CIMTOOL/experiments/modal_truncation")
% parpool("Threads")
%
scdir = strcat(fileparts(mfilename("fullpath")),"/");
matloc = strcat(scdir,"CDplayer.mat"); load(matloc);
sdir = strcat(scdir,"animations_v1/"); mkdir(sdir);
%% construct fn in tf form
n = size(A,1); [V,Lambda] = eig(full(A)); ewref = diag(Lambda);
H = @(z) full(C*((z*eye(n) - A) \ B)); w = logspace(-1,6,1000);
%% setup CIM
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
s = 1.2;
contour = Numerics.Contour.Ellipse(0,1.5*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,3e3);
tc =      Numerics.Contour.Ellipse(0,1.5*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,3e3);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.NLEVP.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 2; CIM.SampleData.r = 2; CIM.RealizationData.K = 350;
CIM.SampleData.show_progress = false;
%
% CIM.RealizationData.ShiftScale = 1.25;
%
lims = {{[-900 100],[-5e4 5e4]},{[],[1e-6 1e8]},{[],[eps 5e1]},{[1e-6 1e6],[1e-6 1e6]}};
tol = 10^-1;

%% CIMTOOl investigation (if necessary)
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,lims{1}{1}); ylim(CIM.MainAx,lims{1}{2});

% %% single frame test
% f = figure(1); %f.Position = [100 100 1920 1080];
% tc.alpha = 1.5*max(abs(real(ewref)))*s; nec = length(ewref(tc.inside(ewref)));
% % compute and plot realized tf response
% if nec ~= 0
%     CIM.SampleData.Contour.alpha = 1.5*max(abs(real(ewref)))*s; CIM.RealizationData.m = nec;
%     CIM.compute();
%     %
%     [Lambda,V,W] = CIM.ResultData.rtfm(nec);
%     Hrmpl = @(z) V*((Lambda-z*eye(size(Lambda)))\W);
%     %
%     plot_cim_response(f,w,CIM,H,Hrmpl,V,W,tol,lims);
% else
%     plot_cim_response(f,w,CIM,H,[],[],[],tol,lims);
% end

%% contour conga
nframes = 500;
gx = linspace(1.5*max(abs(real(ewref)))*s,min(abs(real(ewref)))*s,nframes);

f = figure(1); f.Visible = false; f.Position = [100 100 1920 1080];

wobj = sprintf(strcat(sdir,'cc_cdplayer_mt-N%d.gif'),CIM.SampleData.Contour.N); delete(wobj);
for i=1:length(gx)
    clf(f);
    % test if there are ew inside the contour
    tc.alpha = gx(i); nec = length(ewref(tc.inside(ewref)));
    % compute and plot realized tf response
    if nec ~= 0
        CIM.SampleData.Contour.alpha = gx(i); CIM.RealizationData.m = nec;
        CIM.compute();
        %
        [Lambda,V,W] = CIM.ResultData.rtfm(nec);
        Hrmpl = @(z) V*((Lambda-z*eye(size(Lambda)))\W);
        %
        plot_cim_response(f,w,CIM,H,Hrmpl,V,W,tol,lims);
    else
        plot_cim_response(f,w,CIM,H,[],[],[],tol,lims);
    end
    exportgraphics(gcf,wobj,'Append',true,'Resolution',100);
    sprintf("Done with frame %d/%d",i,nframes)
end