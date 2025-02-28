%% construct fn in tf and pole-residue form
load('./iss.mat'); n = size(A,1);
[V,Lambda] = eig(full(A)); ewref = diag(Lambda);
% BB = V\B; CC = C*V;
%
H = @(z) full(C*((z*speye(n) - A) \ B)); %G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,3,5000);
% Nbode(w,H,G); legend('H','G','Location','northoutside','Orientation','horizontal');
%% setup CIM
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(-0.3+62i,0.025,5,2e3);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.NLEVP.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 3; CIM.SampleData.r = 3; CIM.RealizationData.K = 200;
CIM.SampleData.show_progress = false;
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-1.5 1.5]); ylim(CIM.MainAx,[-125 125]);

%% check initial bode
% nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;
% 
% CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
% CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf(nec);
% Hrmpl = @(z) V2*((M21-z*M22)\W2);
% %
% f = figure(1);
% x = linspace(-5,5,50); y = [-logspace(-3,1,25) logspace(-1,2,75)];
% plot_cim_response(f,CIM,H,Hrmpl,w,x,y);

%% contour conga
g = @(x) x - 200*1i*x; gx = linspace(-0.3,0,1);
% axes(f.Children(end)); hold on; plot(real(g(gx)),imag(g(gx))); hold off;
%
wobj = VideoWriter('cc_iss_1.avi'); wobj.FrameRate = 1; open(wobj);
mkdir('tmp_madness');

f = figure(1); f.Visible = false;

gls = g(gx);
for i=1:length(gls)
    CIM.SampleData.Contour.gamma = gls(i);
    %
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref))); CIM.RealizationData.m = nec;
    CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    CIM.compute(); [~,V2,W2,M21,M22] = CIM.ResultData.rtf(nec);
    Hrmpl = @(z) V2*((M21-z*M22)\W2);
    %
    x = linspace(-5,5,100); y = [-logspace(1,2,10) linspace(-10,10,80) logspace(1,2,10)];
    plot_cim_response(f,CIM,H,Hrmpl,w,x,y); drawnow;
    % you suffer 1 point of madness
    fname = strcat('tmp_madness/f',num2str(i)); print('-djpeg','-r200',fname)
    writeVideo(wobj,im2frame(imread([fname '.jpg'])));
end
close(wobj);