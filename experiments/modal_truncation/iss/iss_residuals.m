scdir = strcat(fileparts(mfilename("fullpath")),"/");
issloc = strcat(scdir,"iss.mat");
sdir = strcat(scdir,"animations_v2/"); mkdir(sdir);
%% construct fn in tf form
load(issloc); n = size(A,1); [V,Lambda] = eig(full(A)); ewref = diag(Lambda);
H = @(z) full(C*((z*speye(n) - A) \ B)); w = logspace(-1,3,500);
%% setup CIM
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
s = 1.2;
contour = Numerics.Contour.Ellipse(0,2*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,8e3);
tc =      Numerics.Contour.Ellipse(0,2*max(abs(real(ewref)))*s,max(abs(imag(ewref)))*s,8e3);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.NLEVP.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 3; CIM.SampleData.r = 3; CIM.RealizationData.K = 1000;
CIM.SampleData.show_progress = false;
%% CIMTOOl investigation (if necessary)
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-1.5 1.5]); ylim(CIM.MainAx,[-125 125]);
lims = {{[-0.4 0.05],[-100 100]},{[],[1e-10 1]},{[],[eps 5e1]},{[eps,5e1],[eps 5e1]}};
tol = 10^-1;

% %% single frame test
% f = figure(1); %f.Position = [100 100 1920 1080];
% tc.alpha = 2*max(abs(real(ewref)))*s; nec = length(ewref(tc.inside(ewref)));
% % compute and plot realized tf response
% if nec ~= 0
%     CIM.SampleData.Contour.alpha = 2*max(abs(real(ewref)))*s; CIM.RealizationData.m = nec;
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
gx = linspace(2*max(abs(real(ewref)))*s,min(abs(real(ewref)))*s,5);

f = figure(1); f.Visible = false; f.Position = [100 100 1920 1080];

wobj = sprintf(strcat(sdir,'cc_iss_mt-N%d.gif'),CIM.SampleData.Contour.N); delete(wobj);
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
end