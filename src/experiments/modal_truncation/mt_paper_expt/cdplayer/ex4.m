scdir = strcat(fileparts(mfilename("fullpath")),"/");
matloc = strcat(scdir,"CDplayer.mat"); load(matloc);
import Visual.*;
%% construct fn in tf and pole-residue form
% first, extract the reference eigenvalues and order them by absolute value
n = size(A,1); m = size(B,2); p = size(C,1);
[V,Lambda] = eig(full(A)); ewref = diag(Lambda);
[~,idx] = sort(abs(ewref)); ewref = ewref(idx); V = V(:,idx);
% Construct our "sparse" transfer function for faster evaluations
H = @(z) C*((z*speye(n) - A) \ B);
% and our pole-residue form
BB = V\B; CC = C*V; G = @(z) ihml(z,n,ewref,BB,CC);
% construct an unstable transfer function/pole residue form with same i/o dimensions as above
% nu = 2; uewref = 0.5+1i*linspace(-5e1,5e1,nu)'; vc = 300;
nu = 2; uewref = 0.5+1i*linspace(-1e1,1e1,nu)'; vc = 300;
Au = diag(uewref); Bu = vc*randn(size(Au,1),m,"like",1i); Cu = vc*randn(p,size(Au,1),"like",1i);
Hu = @(z) Cu*((z*eye(size(Au)) - Au) \ Bu); Gu = @(z) ihml(z,nu,uewref,Bu,Cu);
% Construct "combined" transfer and pole-residue forms
cewref = [ewref;uewref];
Hc = @(z) H(z) + Hu(z); Gc = @(z) G(z) + Gu(z);
% check L2 bode
w = logspace(-1,3,500);
figure(1);
tiledlayout(2,2); nexttile(1,[2 1]);
Nbode(w,H,Hc); legend('H','Hc','Location','northoutside','Orientation','horizontal');
nexttile(2); scatter(real(cewref),imag(cewref));
nexttile(4); scatter(real(cewref),imag(cewref)); xlim([-10,6]); ylim([-100,100]);
%% setup unstable contour problem
nlevp = OperatorData(Hc); nlevp.sample_mode = Numerics.SampleMode.Direct;
% gamma = 0.5; alpha = 0.25; beta = 65;
gamma = 0.5; alpha = 0.25; beta = 20;
contour = Contour.Ellipse(gamma,alpha,beta,1024);
c = CIM(nlevp,contour);
c.SampleData.OperatorData.refew = cewref;
c.SampleData.show_progress = false; c.auto_update_shifts = false;
%%
lep = [4 0];
nec = length(cewref(c.SampleData.Contour.inside(cewref)));
NN = 20;
%
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
c.RealizationData.m = nec;
c.SampleData.ell = 2; c.SampleData.r = 2;
c.RealizationData.InterpolationData = vertshiftline(NN,lep,5);
c.RealizationData.K = min(length(c.RealizationData.InterpolationData.theta),length(c.RealizationData.InterpolationData.sigma));
c.compute();
%
%% check in CIMTOOL
% c = CIMTOOL(CIM); daspect(CIM.MainAx,'auto');
% xlim(CIM.MainAx,[-10,6]); ylim(CIM.MainAx,[-100,100]);
%%
Hur = cimmt(c,nec); Hsr = @(z) Hc(z) - Hur(z);
figure(2); tiledlayout(2,2);
nexttile(1,[2 1]); c.plot(); xlim([-1,6]); ylim([-70,70]);
nexttile(2); Nbode(w,H,Hsr); legend('H','Hsr','Location','northoutside','Orientation','horizontal');
nexttile(4); nboderr(w,H,Hsr); title("Pointwise Relative $\mathcal{L}_2$ Error, H vs Hsr", 'Interpreter','latex');
%%
function inpd = vertshiftline(NN,lep,offset)
arguments
    NN 
    lep = [5 3]
    offset = 0
end
    ip = 1i*[logspace(lep(1),lep(2),2*NN) -logspace(lep(1),lep(2),2*NN)] + offset;
    [~,idx] = sort(abs(ip)); ip = ip(idx);
    
    theta = []; sigma = [];
    
    for i = 1:NN
        tm = 2*mod(NN-1,2); sm = 2*mod(NN,2);
        theta(end+1) = ip(4*i-tm); theta(end+1) = ip(4*i-1-tm);
        sigma(end+1) = ip(4*i-sm); sigma(end+1) = ip(4*i-1-sm);
    end
    inpd = Numerics.InterpolationData(theta,sigma);
end

function nboderr(w,H,Hr)
    Herr = @(z) H(z) - Hr(z);
    Hw = arrayfun(H,1i*w,'UniformOutput',false); nHw = cellfun(@norm,Hw);
    Hwerr = arrayfun(Herr,1i*w,'UniformOutput',false); nHwerr = cellfun(@norm,Hwerr);
    loglog(w,(nHwerr./nHw));
    title("Pointwise Relative $\mathcal{L}_2$ Error", 'Interpreter','latex');
    xlabel("$\omega$","Interpreter","latex");
    ylabel("$\frac{\Vert H(i \omega) - H_r(i \omega) \Vert_F}{\Vert H(i \omega) \Vert_F}$","Interpreter","latex");
end
