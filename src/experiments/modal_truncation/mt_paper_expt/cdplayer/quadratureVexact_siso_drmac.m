scdir = strcat(fileparts(mfilename("fullpath")),"/");
matloc = strcat(scdir,"CDplayer.mat"); load(matloc);
%% construct fn in tf and pole-residue form
n = size(A,1); [V,Lambda] = eig(full(A)); ewref = diag(Lambda);
[~,idx] = sort(abs(ewref)); ewref = ewref(idx); V = V(:,idx); % must order the ew/ev appropriately for the modal truncation to make sense
BB = V\B; CC = C*V;
%
H = @(z) C*((z*speye(n) - A) \ B); Hd = @(z) C(2,:)*((z*speye(n) - A) \ B(:,1));
G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,3,500);
% Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
gamma = -400; alpha = 6e2; beta = 6e4;
contour = Numerics.Contour.Ellipse(gamma,alpha,beta,100);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false; CIM.auto_update_shifts = false;
CIM.SampleData.NLEVP.refew = ewref;
%
CIMMPL = copy(CIM);
CIMMPL.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIMMPL.RealizationData.m = length(ewref(CIMMPL.SampleData.Contour.inside(ewref)));
%
NN = 120;
% CIMMPL.SampleData.Lf = ones(2,n); CIMMPL.SampleData.Rf = ones(2,n);
CIMMPL.SampleData.ell = NN; CIMMPL.SampleData.r = NN;
%% inspect CIM if desired
% c = CIMTOOL(CIMMPL); daspect(CIMMPL.MainAx,'auto');
% xlim(CIMMPL.MainAx,[-1100 100]); ylim(CIMMPL.MainAx,[-6e4 6e4]);
%% from drmac arxiv paper
CIMMPL.RealizationData.InterpolationData = drmac_shifts(NN,8e2);
CIMMPL.RealizationData.K = min(length(CIMMPL.RealizationData.InterpolationData.theta),length(CIMMPL.RealizationData.InterpolationData.sigma));
%% exact CIM
theta = CIMMPL.RealizationData.InterpolationData.theta;
sigma = CIMMPL.RealizationData.InterpolationData.sigma;
L = CIMMPL.SampleData.L; R = CIMMPL.SampleData.R;
% Htl = arrayfun(H,theta,"UniformOutput",false); Htl = cat(2,Htl{:});
% Htr = arrayfun(H,sigma,"UniformOutput",false); Htr = cat(2,Htr{:});
% [L,~] = svd(Htl); L = L; [R,~] = svd(Htr); R = R';
% % drmac
% m = 28;
% [BL,BBL,CL,CCL] = Numerics.mploewner.build_exact_data_noprobe(Hd,theta,sigma);
% [Db,Ds] = Numerics.mploewner.build_loewner(BBL,CCL,theta,sigma);
% heatmap(log10(abs(Db)))
% rank(Db)
% eew = Numerics.realize(m,Db,Ds,BL,CL,NaN);

[BL,BBL,CL,CCL] = Numerics.mploewner.build_exact_data(G,theta,sigma,L,R,"cyclical",true);
[Db,Ds] = Numerics.mploewner.build_loewner(BBL,CCL,theta,sigma);
eew = Numerics.realize(rank(Db),Db,Ds,BL,CL,NaN);
%
scatter(real(eew),imag(eew))
hold on
scatter(real(ewref),imag(ewref))
hold off;
%%
figure(1); clf;
s = logspace(0,4,500); Dbrl = []; DbDsrl = [];
for i = 1:length(s)
    CIMMPL.RealizationData.InterpolationData = drmac_shifts(NN,s(i));
    theta = CIMMPL.RealizationData.InterpolationData.theta;
    sigma = CIMMPL.RealizationData.InterpolationData.sigma;
    %
    [BL,BBL,CL,CCL] = Numerics.mploewner.build_exact_data(H,theta,sigma,L,R,"cyclical",true);
    [Db,Ds] = Numerics.mploewner.build_loewner(BBL,CCL,theta,sigma);
    %
    % [BL,BBL,CL,CCL] = Numerics.mploewner.build_exact_data_siso(Hd,theta,sigma);
    % [Db,Ds] = Numerics.mploewner.build_loewner(BBL,CCL,theta,sigma);
    %
    Dbr = rank(Db,1e-8); DbDsr = rank([Db;Ds]);
    eew = Numerics.realize(Dbr,Db,Ds,BL,CL,eps);
    Dbrl(end+1) = Dbr; DbDsrl(end+1) = DbDsr;
    % heatmap(log10(abs(Db)));
    % title(sprintf("Db rank = %d \t [Db;Ds] rank = %d",Dbr,DbDsr));
    %
    scatter(real(eew),imag(eew)); hold on; scatter(real(ewref),imag(ewref))
    hold off;
    drawnow;
end
figure(2); clf;
semilogx(s,Dbrl); hold on;
semilogx(s,DbDsrl); hold off;

function inpd = drmac_shifts(NN,s)
    ip = s*1i*logspace(log10(2*pi),log10(200*pi),2*NN);
    theta = []; sigma = [];
    for i = 1:NN
        theta(end+1) = ((-1)^i)*ip(i);
        sigma(end+1) = ((-1)^(i+1))*ip(i);
    end
    inpd = Numerics.InterpolationData(theta+50,sigma+50);
end

function plot_mt(f,w,m,ewref,B,C,CIMMPL)
    t = tiledlayout(f,1,2);
    HrMT = @(z) ihml(z,m,ewref,B,C);
    %
    CIMMPL.RealizationData.m = m;
    try
        CIMMPL.compute(); HrMPL = cimmt(CIMMPL,m);
        nexttile(t); CIMMPL.plot(gca);
        xlim([-1100 600]); ylim([-6e4 6e4]);
        %
        nexttile(t);
        Nbode(w,HrMT,HrMPL); legend('HrMT','HrMPL','Location','northoutside','Orientation','horizontal')
    catch e
        warning("failed to realize rank %d system",m)
    end

end