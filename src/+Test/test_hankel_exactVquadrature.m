%% setup CIM
n = 6; m = n; p = n; ewref = -1:-1:-n;
A = diag(ewref); B = randn(n,m); C = randn(p,n);
H = @(z) C*((z*eye(size(A)) - A) \ B);
%
nlevp = Numerics.NLEVPData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(-(n+1)/2,((n+1)/2),0.5,8);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.show_progress = false; CIM.SampleData.NLEVP.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.SampleData.ell = n; CIM.SampleData.r = n;
CIM.RealizationData.K = 1; CIM.RealizationData.m = n;
% c = CIMTOOL(CIM);
%%
cla;
ndir = [n floor(n/2) 1];
for j = 1:length(ndir)
    CIM.SampleData.ell = ndir(j); CIM.SampleData.r = ndir(j);
    CIM.RealizationData.K = ceil(m/ndir(j));
    % exact
    sigma = CIM.RealizationData.InterpolationData.sigma(1);
    L = CIM.SampleData.L; R = CIM.SampleData.R;
    K = CIM.RealizationData.K; m = CIM.RealizationData.m;
    %
    eew = Numerics.sploewner.sploewner_exact(sigma,A,B,C,K,m,L,R);
    eew = sort(eew);
    %% quadrature
    N = 2:200; nmdl = []; cNl = [];
    for i = 1:length(N)
        CIM.SampleData.Contour.N = N(i);
        try CIM.compute(); catch e; warning("failed for ndir=%d, N=%d",ndir(j),N(i)); continue; end
        cew = CIM.ResultData.ew;
        nmdl(end+1) = Numerics.greedy_matching_distance(eew,cew);
        cNl(end+1) = N(i);
    end
    semilogy(cNl,nmdl,"DisplayName",sprintf("TID=%d",ndir(j))); hold on;
    ylabel("Greedy Matching Distance to Exact"); xlabel("N");
end
title("Exact vs Quadrature Hankel Convergence");
legend("Location","northoutside","Orientation","horizontal");
hold off;