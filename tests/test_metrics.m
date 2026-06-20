% Unit tests for the consolidated diagnostic-metric utilities:
%   - Numerics.maxrelresidual (standalone + the CIM convenience method)
%   - Numerics.matching_distance (optimal assignment via matchpairs)
% and the relationship of matching_distance to the greedy heuristic.
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);

%% Operator with known eigenpairs
n = 5; ewref = -(1:n); A = diag(ewref); B = eye(n); C = eye(n);
T = @(z) z*eye(n) - A;                       % operator form (Inverse mode): residual uses T(ew)*ev
[Vexact, Dexact] = eig(A); ewx = diag(Dexact);

%% maxrelresidual: standalone equals max(relres), returns the worst eigenvalue
rr = Numerics.relres(T, ewx, Vexact, Numerics.SampleMode.Inverse);
[mres, worst_ew, idx] = Numerics.maxrelresidual(T, ewx, Vexact, Numerics.SampleMode.Inverse);
assert(abs(mres - max(rr)) < 1e-14, "maxrelresidual must equal max(relres)");
assert(worst_ew == ewx(idx), "worst_ew must be the eigenvalue at the max-residual index");
assert(mres < 1e-10, "exact eigenpairs should have ~0 relative residual (got %.2e)", mres);
% perturb one eigenvector so a specific pair is clearly the worst
Vbad = Vexact; Vbad(:,3) = Vbad(:,3) + 0.5*Vexact(:,1);
[~, worst_bad, idx_bad] = Numerics.maxrelresidual(T, ewx, Vbad, Numerics.SampleMode.Inverse);
assert(idx_bad == 3, "the perturbed pair (col 3) should be flagged as worst (got %d)", idx_bad);
fprintf("maxrelresidual standalone: PASS\n");

%% maxrelresidual: CIM convenience method matches the standalone
H = @(z) C*((z*eye(n) - A) \ B);             % transfer function (Direct sampling)
op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct; op.refew = ewref;
ct = Numerics.Contour.Circle(-3, 3.5, 128);  % encloses all poles
cim = Numerics.CIM(op, ct); cim.SampleData.show_progress = false;
cim.SampleData.ell = n; cim.SampleData.r = n;
cim.RealizationData.K = 1; cim.RealizationData.m = n;
cim.compute();
[m1, w1] = cim.maxrelresidual();
[m2, w2] = Numerics.maxrelresidual(op.T, cim.ResultData.ew, cim.ResultData.rev, op.sample_mode);
assert(abs(m1 - m2) < 1e-14 && w1 == w2, "cim.maxrelresidual must match the standalone");
assert(m1 < 1e-6, "computed eigenpairs should have small residual (got %.2e)", m1);
fprintf("maxrelresidual CIM method: PASS\n");

%% matching_distance: optimal beats greedy where greedy is suboptimal
% ref=[0,5,100], cmp=[4.9,5.1]: greedy grabs 5<->4.9 first (dist 0.1), stranding
% 5.1 onto its nearest remaining ref 0 (dist 5.1) -> norm([0.1,5.1]) = 5.101.
% The optimal assignment 0<->4.9, 5<->5.1 -> norm([4.9,0.1]) = 4.901 is smaller.
ref = [0, 5, 100]; cmp = [4.9, 5.1];
opt = Numerics.matching_distance(ref, cmp);
gre = Numerics.greedy_matching_distance(ref, cmp);
fprintf("  greedy = %.3f, optimal = %.3f\n", gre, opt);
assert(abs(opt - norm([4.9, 0.1], 2)) < 1e-9, "optimal should be norm([4.9,0.1])=4.901, got %.3f", opt);
assert(opt < gre, "optimal must be strictly below the greedy heuristic here (%.3f vs %.3f)", opt, gre);

%% matching_distance: agrees with greedy on a well-separated set
refS = [-1 -2 -3 -4]; cmpS = refS + 1e-3*[1 -1 1 -1];
assert(abs(Numerics.matching_distance(refS, cmpS) - Numerics.greedy_matching_distance(refS, cmpS)) < 1e-9, ...
    "optimal and greedy should agree on well-separated eigenvalues");

%% matching_distance: handles n >= 10 (the old perms cap is gone)
refB = (1:12) + 0.0; cmpB = refB + 1e-2;
db = Numerics.matching_distance(refB, cmpB);
assert(abs(db - norm(1e-2*ones(12,1), 2)) < 1e-9, "n>=10 matching should succeed and be ~exact");

%% matching_distance: unequal sizes pair min(n,m) and return the pairing
[d3, pairs] = Numerics.matching_distance([0 5 100], [4.9 5.1]);
assert(size(pairs,1) == 2, "should form min(3,2)=2 pairs");
assert(~any(ismember(100, pairs(:,1))), "the far reference (100) should be left unmatched");
fprintf("matching_distance (optimal vs greedy): PASS\n");

%% rtfm removal: ResultData no longer exposes it; cim.tf still works
assert(~ismethod(cim.ResultData, 'rtfm'), "ResultData.rtfm should be removed");
Hr = cim.tf(); v = Hr(-3 + 0.5i); Hexact = H(-3 + 0.5i);
assert(norm(v - Hexact)/norm(Hexact) < 1e-6, "cim.tf must still reconstruct H");
fprintf("rtfm removal / tf intact: PASS\n");

%%
fprintf("\nAll metric tests passed!\n");
