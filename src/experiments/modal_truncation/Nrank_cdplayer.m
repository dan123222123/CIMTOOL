%% load CDplayer
load('./CDplayer.mat'); n = size(A,1);
[V,Lambda] = eig(full(A)); ewref = diag(Lambda);
BB = V\B; CC = C*V;
%
H = @(z) C*((z*speye(n) - A) \ B); G = @(z) ihml(z,n,ewref,BB,CC);
w = logspace(-1,6,1000); Nbode(w,H,G);
%%
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(mean(ewref),800,6e4,1e2);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ewref;
%
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 10; CIM.SampleData.r = 10;
CIM.RealizationData.K = 1200;
nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
CIM.RealizationData.m = nec;
CIM.compute();
%% changing N
x = 100:50:3000;
rarr = zeros(length(x),1); % Db rank
ewrrarr = zeros(length(x),1); % computed ew relative residual
L2pe = zeros(length(x),1); % L2 error vs H
for i=1:length(x)
    CIM.SampleData.Contour.N = x(i); CIM.compute();
    %
    rarr(i) = Numerics.rankdet(CIM.ResultData.Db);
    ewrrarr(i) = mean(Numerics.relres(CIM.SampleData.NLEVP.T,CIM.ResultData.ew,CIM.ResultData.rev));
    L2pe(i) = mean(l2e(H,rtf(CIM),w));
    fprintf("done with %d\n",i);
end
figure(1);
plot(x,rarr); title(gca, "Db Rank vs N");
saveas(gcf,"dbr_N.png");
%
figure(2);
plot(x,ewrrarr); title(gca, "Mean EW Relative Residual vs N");
saveas(gcf,"mewrr_N.png");
%
figure(3);
plot(x,L2pe); title(gca, "Mean L2 Frequency Error vs N");
saveas(gcf,"ml2fe_N.png");
