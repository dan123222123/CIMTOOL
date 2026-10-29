% Automatic choice of the realization order m (RealizationData.AutoRank and RankRule):
%   - Numerics.rankgap: a clean gap, exact zeros, a roundoff tail, geometric decay, 1x1 and empty
%   - the Gap rule realizes the 6-pole problem of test_realization at m = 6 in all three modes, leaving RealizationSize.m alone
%   - a Db without a gap is realized at its largest gap anyway, with GapRatio below GapMin and the Numerics:rankgap:noGap warning only under Verbose;
%     Tolerance and a manual m record no GapRatio; zero data gives an empty realization
%   - AutoRank, RankRule (under AutoRank) and options changes mark the realization stale and keep the samples
%   - a manual m keeps its rank refusal and the AbsTol = 0 override; Tolerance realizes at the rank
%   - copy, conversion and a MAT round trip keep AutoRank, RankRule, ResultData.m and ResultData.GapRatio; tf defaults to the chosen m
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);

MP = Numerics.ComputationalMode.MPLoewner; SP = Numerics.ComputationalMode.SPLoewner; HK = Numerics.ComputationalMode.Hankel;
Tolerance = Numerics.RankRule.Tolerance; Gap = Numerics.RankRule.Gap;

%% rankgap
[m, ratio] = Numerics.rankgap(diag([1 0.5 0.2 1e-9 1e-10]));
assert(m == 3 && abs(ratio - 2e8) < 1e-6*2e8, "a clean gap must give its index and ratio, got m = %d, ratio = %.2e", m, ratio);
[m, ratio] = Numerics.rankgap(diag([3 1 0 0 0]));
assert(m == 2 && isfinite(ratio), "a rank-2 5x5 with exact zeros must give m = 2 and a finite ratio");
[m, ratio] = Numerics.rankgap(diag([1 0.5 0.2 0.1 2e-16 1e-17 1e-33]));   % the unclamped tail has a wider gap, at 6
assert(m == 4, "the roundoff tail must not hide the true rank, got m = %d", m);
[~, S8] = svd(randn(8, 4)*randn(4, 8));
assert(Numerics.rankgap(S8) == 4, "a computed rank-4 8x8 must give m = 4");
[~, ratio] = Numerics.rankgap(diag(10.^(-0.5*(0:9))));
assert(ratio < 1e4, "geometric decay must have no gap above 1e4, got %.2e", ratio);
assert(Numerics.rankgap(5) == 1, "a 1x1 must give m = 1");
[~, S41] = svd(randn(4, 1));
assert(Numerics.rankgap(S41) == 1, "a 4x1 Sigma must give m = 1");
assert(Numerics.rankgap(zeros(0, 0)) == 0 && Numerics.rankgap(zeros(3)) == 0, "empty and zero must give m = 0");
fprintf("rankgap: PASS\n");

%% the Gap rule on the 6-pole problem of test_realization, all three modes
n = 6; ewref = (-1:-1:-n).';
A = diag(ewref); Bm = randn(n, n); Cm = randn(n, n);
H = @(z) Cm*((z*eye(n) - A) \ Bm);
I = eye(n);
op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct; op.refew = ewref;
ct = Numerics.Contour.Circle(-3.5, 3.5, 128);
for md = [HK SP MP]
    c = newCIM(op, ct, I);
    K = 2; if md == MP, K = 2*n; end            % Db is 2n x 2n, above the pole count
    c.setComputationalMode(md, Numerics.RealizationSize(2, K, K));
    if md == SP, c.RealizationData.InterpolationData = Numerics.InterpolationData([], -3.5 + 5i); end
    autoRank(c, Gap); c.compute();
    assert(c.ResultData.m == n && c.RealizationData.RealizationSize.m == 2, ...
        "%s: Gap must realize at m = %d and leave RealizationSize.m = 2, got %d and %d", string(md), n, c.ResultData.m, c.RealizationData.RealizationSize.m);
    assert(Numerics.matching_distance(ewref, c.ResultData.ew) < 1e-8, "%s: Gap must recover the spectrum", string(md));
    ewgap = c.ResultData.ew; [~, ratio] = Numerics.rankgap(c.ResultData.Sigma);
    assert(c.ResultData.GapRatio == ratio && ratio >= c.options.GapMin, "%s: Gap must record the ratio of a clean gap, got %.1e", string(md), c.ResultData.GapRatio);
    c.RealizationData.AutoRank = false; c.RealizationData.m = n; c.compute();
    assert(isequal(ewgap, c.ResultData.ew) && c.ResultData.m == n && isnan(c.ResultData.GapRatio), ...
        "%s: Gap must match a Manual run at m = %d, which records no GapRatio", string(md), n);
    fprintf("  %-9s gap sigma_%d/sigma_%d = %.1e\n", string(md), n, n + 1, ratio);
end
fprintf("Gap rule, all three modes: PASS\n");

%% no gap: realized at the largest gap anyway, the noGap warning under Verbose; zero data
% Hankel at K = 1 with L = R = I gives Db = Cg*Bg, whose singular values decay by 10^-0.5 per step
[U, ~] = qr(randn(n)); [V, ~] = qr(randn(n));
Cg = U*diag(10.^(-0.5*(0:n-1))); Bg = V';
opg = Numerics.OperatorData(@(z) Cg*((z*eye(n) - A) \ Bg)); opg.sample_mode = Numerics.SampleMode.Direct;
cg = newCIM(opg, ct, I); cg.RealizationData.RealizationSize = Numerics.RealizationSize(2, 1, 1);
autoRank(cg, Gap);
lastwarn(''); cg.compute(); [~, wid] = lastwarn;
[mg, ratio] = Numerics.rankgap(cg.ResultData.Sigma);
assert(wid == "" && cg.ResultData.m == mg && numel(cg.ResultData.ew) == mg, ...
    "without Verbose a weak gap must be realized at its index %d silently, got '%s' and m = %d", mg, wid, cg.ResultData.m);
assert(mg < Numerics.rankdet(cg.ResultData.Db), "a weak gap must not fall back to the Tolerance rule");
assert(cg.ResultData.GapRatio == ratio && ratio < cg.options.GapMin, "a weak gap must record its ratio %.1e, below GapMin", ratio);
cg.options.Verbose = true; cg.RealizationData.loaded = false;
lastwarn(''); cg.compute(); [~, wid] = lastwarn; cg.options.Verbose = false;
assert(wid == "Numerics:rankgap:noGap" && cg.ResultData.m == mg, "a weak gap must warn under Verbose and keep m = %d, got '%s'", mg, wid);
ewg = cg.ResultData.ew;
cg.computeDataMatrices();
assert(isempty(cg.ResultData.m) && isnan(cg.ResultData.GapRatio), "rebuilding Db must clear GapRatio with m");
cg.RealizationData.AutoRank = false; cg.RealizationData.m = mg; cg.compute();
assert(isequal(cg.ResultData.ew, ewg) && isnan(cg.ResultData.GapRatio), "a weak gap must match a Manual run at m = %d, which records no GapRatio", mg);
autoRank(cg, Tolerance); cg.compute();
assert(cg.ResultData.m == n && isnan(cg.ResultData.GapRatio), "Tolerance must realize at the rank %d and record no GapRatio", n);
assert(Numerics.matching_distance(ewref, cg.ResultData.ew) < 1e-8, "Tolerance must recover the spectrum");
op0 = Numerics.OperatorData(@(z) zeros(3)); op0.sample_mode = Numerics.SampleMode.Direct;
for rule = [Gap Tolerance]
    c0 = newCIM(op0, ct, eye(3)); autoRank(c0, rule);
    c0.compute();
    assert(c0.ResultData.m == 0 && isempty(c0.ResultData.ew) && c0.DataDirtiness == 0, "%s: zero data must give an empty realization", string(rule));
    [V0, D0] = c0.eigs();
    assert(isempty(V0) && isempty(D0), "%s: eigs of an empty realization must be empty", string(rule));
end
fprintf("weak gap and zero data: PASS\n");

%% an empty contour gives m = 0 before either rule; a quadratic problem with every eigenvalue enclosed does not read as empty
ce = Numerics.Contour.Circle(5, 1, 128);   % no pole of H inside
for rule = [Gap Tolerance]
    c = newCIM(op, ce, I); autoRank(c, rule);
    lastwarn(''); c.compute(); [~, wid] = lastwarn;
    assert(c.contourMomentLevel() < 1e-14 && c.ResultData.m == 0 && isempty(c.ResultData.ew) && wid == "" && isnan(c.ResultData.GapRatio), ...
        "%s: an empty contour must give an empty realization without a warning or a GapRatio", string(rule));
end
c.options.EmptyTol = 0; c.compute();
assert(c.ResultData.m > 0, "EmptyTol = 0 must leave the empty contour to the rank rule");
Cq = randn(3); Kq = randn(3);
opq = Numerics.OperatorData(@(z) z^2*eye(3) + z*Cq + Kq);
ewq = polyeig(Kq, Cq, eye(3));
cq = newCIM(opq, Numerics.Contour.Circle(0, 1.5*max(abs(ewq)), 256), eye(3));
cq.setComputationalMode(HK, Numerics.RealizationSize(2, 4, 4)); autoRank(cq, Gap); cq.compute();
assert(cq.contourMomentLevel() > 1e-6 && cq.ResultData.m == 6 && Numerics.matching_distance(ewq, cq.ResultData.ew) < 1e-8, ...
    "a quadratic problem with all six eigenvalues enclosed must not read as empty");
fprintf("empty contours: PASS\n");

%% ell and r never exceed the operator dimension, whether set directly or after an operator change
cl = Numerics.CIM(op, ct); quietCIM(cl);
lastwarn(''); cl.SampleData.ell = n + 4; [~, wid] = lastwarn;
assert(cl.SampleData.ell == n && wid == "Numerics:SampleData:directionsClamped", "ell above n must be clamped to n with a warning");
cl.SampleData.r = n; cl.compute(); op.T = op.T;
assert(cl.SampleData.ell == n && cl.SampleData.r == n, "an operator change must leave ell and r at n");
fprintf("direction clamp: PASS\n");

%% AutoRank, RankRule and options mark only the realization stale
c = newCIM(op, Numerics.Contour.Circle(-3.5, 3.5, 128), I); c.RealizationData.RealizationSize = Numerics.RealizationSize(n, 2, 2); c.compute();
assert(c.DataDirtiness == 0 && c.ResultData.m == n, "a compute at the manual m must write ResultData.m");
c.RealizationData.AutoRank = true;
assert(c.DataDirtiness == 1 && c.SampleData.loaded, "an AutoRank change must mark the realization stale and keep the samples");
c.compute(); c.RealizationData.RankRule = Tolerance;
assert(c.DataDirtiness == 1 && c.SampleData.loaded, "a RankRule change under AutoRank must mark the realization stale and keep the samples");
c.compute();
assert(c.DataDirtiness == 0, "compute must clear the dirtiness");
c.RealizationData.AutoRank = false; c.compute(); c.RealizationData.RankRule = Gap;
assert(c.DataDirtiness == 0, "a RankRule change while AutoRank is off must leave the realization clean");
c.options.RelTol = 1e-8;
assert(c.DataDirtiness == 1, "an options change must mark the realization stale");
c.options.RelTol = NaN; c.SampleData.Contour.rho = 3.6; c.getFullDataMatrices();
assert(isempty(c.ResultData.m), "rebuilding Db must clear ResultData.m");
fprintf("staleness: PASS\n");

%% Manual refusal, Tolerance at the rank, the AbsTol = 0 override (problem of test_cim_state)
rng(0); n7 = 7; A7 = diag(-(1:n7)); B7 = randn(n7); C7 = randn(n7);
op7 = Numerics.OperatorData(@(z) C7*((z*eye(n7) - A7) \ B7)); op7.sample_mode = Numerics.SampleMode.Direct;
c6 = Numerics.CIM(op7, Numerics.Contour.Circle(-4, 4, 64)); quietCIM(c6);
c6.setComputationalMode(MP, Numerics.RealizationSize(n7 + 1, n7 + 1, n7 + 1));
c6.options.RelTol = 1e-6;
errid = ""; try, c6.compute(); catch e, errid = string(e.identifier); end
assert(errid == "Numerics:realize:rankDeficient", "Manual m above the numerical rank must be refused, got '%s'", errid);
assert(isempty(c6.ResultData.m), "a refused realization must clear ResultData.m");
autoRank(c6, Tolerance); c6.compute();
rk = Numerics.rankdet(c6.ResultData.Db, NaN, 1e-6);
assert(c6.ResultData.m == rk && numel(c6.ResultData.ew) == rk && c6.RealizationData.RealizationSize.m == n7 + 1, ...
    "Tolerance must realize at the rank %d under the same RelTol, got m = %d", rk, c6.ResultData.m);
c8 = Numerics.CIM(op7, Numerics.Contour.Circle(-4, 4, 128)); quietCIM(c8);
c8.RealizationData.RealizationSize = Numerics.RealizationSize(n7, 2, 2); Db8 = c8.getFullDataMatrices();
rk8 = Numerics.rankdet(Db8);
assert(rk8 < size(Db8, 1), "the eps rank of the Hankel Db must be below its size");
c8.RealizationData.m = rk8 + 1;
errid = ""; try, c8.compute(); catch e, errid = string(e.identifier); end
assert(errid == "Numerics:realize:rankDeficient", "Manual m above the eps rank must be refused, got '%s'", errid);
c8.options.AbsTol = 0; c8.compute();
assert(c8.ResultData.m == rk8 + 1 && numel(c8.ResultData.ew) == rk8 + 1, "AbsTol = 0 must force Manual m = %d", rk8 + 1);
fprintf("Manual refusal, Tolerance and AbsTol = 0: PASS\n");

%% copy, conversion and a MAT round trip keep AutoRank, RankRule, ResultData.m and ResultData.GapRatio; tf
c = newCIM(op, ct, I); c.setComputationalMode(HK, Numerics.RealizationSize(2, 2, 2));
autoRank(c, Gap); c.compute();
% isequal also fails on a NaN GapRatio
keeps = @(x, d) x.RealizationData.AutoRank && x.RealizationData.RankRule == Gap && isequal(x.ResultData.m, c.ResultData.m) && ...
    isequal(x.ResultData.GapRatio, c.ResultData.GapRatio) && x.DataDirtiness == d;
f = [tempname '.mat']; save(f, 'c'); S = load(f); delete(f);
v = Visual.CIM.fromNumerics(c);
assert(keeps(copy(c), 0) && keeps(S.c, 0) && keeps(v, 0) && keeps(v.toNumerics(), 0), ...
    "copy, MAT round trip and conversion must keep RankRule, ResultData.m, ResultData.GapRatio and a clean state");
y = S.c; y.RealizationData.RankRule = Tolerance;
assert(y.DataDirtiness == 1, "a loaded CIM must react to a RankRule change");
c.options.GapMin = 1e5;
assert(keeps(copy(c), 1), "a copy must keep a stale state");
[~, Lam] = c.tf(); [~, Lam6] = c.tf(n);
assert(size(Lam, 1) == n && isequal(Lam, Lam6), "tf must default to the m that the Gap rule chose");
c.RealizationData.AutoRank = false; c.RealizationData.RankRule = Tolerance;
f = [tempname '.mat']; save(f, 'c'); S = load(f); delete(f);
for x = {copy(c), S.c, Visual.CIM.fromNumerics(c)}
    assert(~x{1}.RealizationData.AutoRank && x{1}.RealizationData.RankRule == Tolerance, "a rule kept while AutoRank is off must survive copy, MAT and conversion");
end
fprintf("copy, MAT round trip and tf: PASS\n");

function autoRank(c, rule)
% Choose m from Db by rule.
    c.RealizationData.AutoRank = true; c.RealizationData.RankRule = rule;
end

function c = newCIM(op, ct, I)
% A quiet CIM with fixed probing directions.
    c = Numerics.CIM(op, ct); quietCIM(c);
    c.SampleData.L = I; c.SampleData.R = I;
end

function quietCIM(c)
% No progress bar and no padding warnings in the tests.
    c.SampleData.show_progress = false; c.options.Verbose = false;
end
