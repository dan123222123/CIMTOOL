scdir = strcat(fileparts(mfilename("fullpath")),"/");
matloc = strcat(scdir,"CDplayer.mat"); load(matloc);
%% construct fn in tf and pole-residue form
n = size(A,1); [V,Lambda] = eig(full(A)); ewref = diag(Lambda);
[~,idx] = sort(abs(ewref)); ewref = ewref(idx); V = V(:,idx); % must order the ew/ev appropriately for the modal truncation to make sense
BB = V\B; CC = C*V;
%
H = @(z) C*((z*speye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,3,500); Nbode(w,H,G);
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
gamma = -140; alpha = 220; beta = 2.7e4;
contour = Numerics.Contour.Ellipse(gamma,alpha,beta,1e5);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.NLEVP.refew = ewref;
CIM.SampleData.show_progress = false; CIM.auto_update_shifts = false;
%
CIMMPL = copy(CIM);
CIMMPL.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

NN = 120; CIMMPL.SampleData.ell = 1; CIMMPL.SampleData.r = 1;

lep = [7 1]; offset = gamma+alpha+5;

CIMMPL.RealizationData.InterpolationData = vertshiftline(NN,lep,offset);
CIMMPL.RealizationData.K = min(length(CIMMPL.RealizationData.InterpolationData.theta),length(CIMMPL.RealizationData.InterpolationData.sigma));
%% inspect CIM if desired
% c = CIMTOOL(CIMMPL); daspect(CIMMPL.MainAx,'auto');
% xlim(CIMMPL.MainAx,[-1100 100]); ylim(CIMMPL.MainAx,[-6e4 6e4]);
%% check initial bode
nec = length(ewref(CIMMPL.SampleData.Contour.inside(ewref)));
%
f = figure(1); plot_mt(f,w,nec,ewref,BB,CC,CIMMPL);
%% modal truncation investigation
NL = 100; x = linspace(offset,gamma+alpha+1,NL);
for i = 1:NL
    CIMMPL.RealizationData.InterpolationData = vertshiftline(NN,lep,x(i));
    %
    nec = length(ewref(CIMMPL.SampleData.Contour.inside(ewref)));
    %
    plot_mt(f,w,nec,ewref,BB,CC,CIMMPL);
    drawnow;
end

function inpd = vertshiftline(NN,lep,offset)
arguments
    NN 
    lep = [5 3]
    offset = 0
end
    ip = 1i*[logspace(lep(1),lep(2),NN+1) -logspace(lep(1),lep(2),NN+1)]+offset; [~,idx] = sort(abs(ip));
    ip = ip(idx);
    
    theta = []; sigma = [];
    
    for i = 1:NN
        if mod(i,2) == 0
            theta(end+1) = ip(2*i-1);
            theta(end+1) = ip(2*i);
        else
            sigma(end+1) = ip(2*i-1);
            sigma(end+1) = ip(2*i);
        end
    end
    inpd = Numerics.InterpolationData(theta,sigma);
end

function plot_mt(f,w,m,ewref,B,C,CIMMPL)
    t = tiledlayout(f,1,2);
    HrMT = @(z) ihml(z,m,ewref,B,C);
    %
    CIMMPL.RealizationData.m = m;
    try
        CIMMPL.compute(); HrMPL = cimmt(CIMMPL,m);
        nexttile(t); CIMMPL.plot(gca);
        xlim([-1100 400]); ylim([-6e4 6e4]);
        %
        nexttile(t);
        Nbode(w,HrMT,HrMPL); legend('HrMT','HrMPL','Location','northoutside','Orientation','horizontal')
    catch e
        warning("failed to realize rank %d system",m)
    end

end