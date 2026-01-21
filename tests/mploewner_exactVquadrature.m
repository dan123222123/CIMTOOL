%% setup CIM
n = 6; m = n; p = n; ewref = -1:-1:-n;
A = diag(ewref); B = randn(n,m); C = randn(p,n);
H = @(z) C*((z*eye(size(A)) - A) \ B);
%
nlevp = Numerics.OperatorData(H); nlevp.sample_mode = Numerics.SampleMode.Direct;
contour = Numerics.Contour.Ellipse(-(n+1)/2,((n+1)/2),0.5,8);
CIM = Numerics.CIM(nlevp,contour);
%
CIM.SampleData.show_progress = false; CIM.SampleData.OperatorData.refew = ewref;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.SampleData.ell = 1; CIM.SampleData.r = 1;
CIM.RealizationData.K = n; CIM.RealizationData.m = n;
% c = CIMTOOL(CIM);
%%
cla;
ndir = [n floor(n/2) 1];
for j = 1:length(ndir)
    CIM.SampleData.ell = ndir(j); CIM.SampleData.r = ndir(j);
    % exact
    theta = CIM.RealizationData.InterpolationData.theta;
    sigma = CIM.RealizationData.InterpolationData.sigma;
    L = CIM.SampleData.L; R = CIM.SampleData.R;
    m = CIM.RealizationData.m;
    %
    eew = Numerics.mploewner.mploewner_exact(H,theta,sigma,L,R,m,"PadStrategy","cyclical");
    eew = sort(eew);
    %% quadrature
    N = floor([8:100 logspace(2,3,30)]); nmdl = []; cNl = [];
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
title("Exact vs Quadrature MPLoewner Convergence");
legend("Location","northoutside","Orientation","horizontal");
hold off;