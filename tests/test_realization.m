% GUI-free regression baseline for the system-realization core: ERA/Hankel,
% SPLoewner, and MPLoewner. This is the headless counterpart to
% testCIMEigensystemRealization (which launches the full GUI via CIMTOOL(...)
% and is therefore fragile and unsuitable for automated runs), and it closes a
% gap in the *_exactVquadrature scripts: those use the exact realization
% routines as the convergence TARGET but never check the target itself recovers
% the true spectrum.
%
% Covers:
%   1. Exact realization recovers the reference spectrum (all three modes).
%   2. Quadrature CIM recovers eigenvalues + small residuals (all three modes).
%   3. The block-moment / Hankel-size trade-off (ell,r vs K), including the
%      conditioning-limited ell=r=1 corner.
%   4. A SISO problem through the CIM path.
%   5. The eigs() convenience interface (sorted, unit-normalized eigenvectors).
%   6. Characterization of the (currently broken) MPLoewner unequal theta/sigma
%      padding path -- it must fail loudly, never silently return wrong results.
%
% Probing directions are fixed (identity for the MIMO problem, scalar for the
% SISO one) so the realization is fully reproducible; sampleMatrix's default
% random probing leaves the ill-conditioned corner cases varying run-to-run.
% The random-probing path stays exercised by the *_exactVquadrature scripts.
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);

%% Shared test problems (drawn first so results are independent of draw order)
n = 6; ewref = (-1:-1:-n).';
A  = diag(ewref);
Bm = randn(n,n); Cm = randn(n,n);          % MIMO system: H(z) = Cm (zI-A)^{-1} Bm
bs = randn(n,1); cs = randn(1,n);          % SISO system: Hs(z) = cs (zI-A)^{-1} bs
H  = @(z) Cm*((z*eye(n) - A) \ Bm);
I  = eye(n);                               % fixed (identity) probing directions

%% 1. Exact realization recovers the reference spectrum (Hankel/SP/MP)
K = 1; m = n;
ewH = sort(Numerics.sploewner.sploewner_exact(Inf,     A, Bm, Cm, K, m, I, I));  % sigma=Inf => Hankel
ewS = sort(Numerics.sploewner.sploewner_exact(-3.5+1i, A, Bm, Cm, K, m, I, I));  % shift off the spectrum
assert(Numerics.matching_distance(ewref, ewH) < 1e-9, "exact Hankel must recover the reference spectrum");
assert(Numerics.matching_distance(ewref, ewS) < 1e-9, "exact SPLoewner must recover the reference spectrum");
% MPLoewner exact needs interpolation points; take a contour's interleaved shifts
% (the same construction the mploewner_exactVquadrature script uses).
ctmp = Numerics.Contour.Ellipse(-(n+1)/2, (n+1)/2, 0.5, 8);
cimp = Numerics.CIM(Numerics.OperatorData(H), ctmp);
cimp.SampleData.OperatorData.sample_mode = Numerics.SampleMode.Direct;
cimp.SampleData.show_progress = false;
cimp.setComputationalMode(Numerics.ComputationalMode.MPLoewner);
theta = cimp.RealizationData.InterpolationData.theta;
sigma = cimp.RealizationData.InterpolationData.sigma;
ewM = sort(Numerics.mploewner.mploewner_exact(H, theta, sigma, I, I, m, "PadStrategy", "cyclical"));
assert(Numerics.matching_distance(ewref, ewM) < 1e-9, "exact MPLoewner must recover the reference spectrum");
fprintf("exact realization -> reference spectrum (Hankel/SP/MP): PASS\n");

%% 2. Quadrature CIM: eigenvalues + residuals, all three modes
op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct; op.refew = ewref;
ct = Numerics.Contour.Circle(-3.5, 3.5, 128);            % encloses all n poles
cim = Numerics.CIM(op, ct); cim.SampleData.show_progress = false;
cim.SampleData.L = I; cim.SampleData.R = I;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(n, 1, 1);
modes = [Numerics.ComputationalMode.Hankel, ...
         Numerics.ComputationalMode.SPLoewner, ...
         Numerics.ComputationalMode.MPLoewner];
for md = modes
    cim.setComputationalMode(md);
    if md == Numerics.ComputationalMode.SPLoewner
        % pin the single shift (default_shifts picks a random point) to a fixed
        % location outside the contour so the SP result is reproducible. The shift
        % is valid (finite, outside Omega), so the update_shifts listener leaves
        % it in place -- no need to disable auto_update_shifts (doing so would
        % also suppress MPLoewner's shift regeneration on the next iteration).
        assert(~ct.inside(-3.5 + 5i), "SPLoewner shift must be outside the contour");
        cim.RealizationData.InterpolationData = Numerics.InterpolationData([], -3.5 + 5i);
    end
    cim.compute();
    assert(numel(cim.ResultData.ew) == n, "%s: should return n eigenvalues", string(md));
    dd = cim.matchingDistance();
    rr = cim.maxrelresidual();
    fprintf("  %-10s md=%.2e  maxrelres=%.2e\n", string(md), dd, rr);
    assert(dd < 1e-8, "%s: eigenvalue matching distance too large (%.2e)", string(md), dd);
    assert(rr < 1e-8, "%s: max relative residual too large (%.2e)", string(md), rr);
end
fprintf("quadrature CIM eigenvalues + residuals (Hankel/SP/MP): PASS\n");

%% 3. Block-moment / Hankel-size trade-off (Hankel mode, shared samples)
% Same operator, same contour: shift work between tangential directions (ell=r)
% and moment depth (K). All recover the n poles; the ell=r=1 corner is the
% conditioning-limited case (ill-conditioned block-Hankel / Vandermonde) and is
% asserted with a correspondingly looser tolerance.
cim.setComputationalMode(Numerics.ComputationalMode.Hankel);
cfgs = {[n 1 1e-9], [3 2 1e-9], [2 3 1e-9], [1 6 1e-3]};   % [ell=r, K, tol]
for k = 1:numel(cfgs)
    d = cfgs{k}(1); Kk = cfgs{k}(2); ctol = cfgs{k}(3);
    cim.SampleData.L = I(:, 1:d); cim.SampleData.R = I(:, 1:d);
    cim.RealizationData.RealizationSize = Numerics.RealizationSize(n, Kk, Kk);
    cim.compute();
    assert(numel(cim.ResultData.ew) == n, "block-Hankel ell=r=%d K=%d: should return n eigenvalues", d, Kk);
    dd = cim.matchingDistance();
    fprintf("  ell=r=%d K=%d  md=%.2e (tol %.0e)\n", d, Kk, dd, ctol);
    assert(dd < ctol, "block-Hankel ell=r=%d K=%d: md=%.2e exceeds tol %.0e", d, Kk, dd, ctol);
end
fprintf("block-moment / Hankel-size trade-off: PASS\n");

%% 4. SISO problem (1x1 transfer function)
Hs = @(z) cs*((z*eye(n) - A) \ bs);
ops = Numerics.OperatorData(Hs); ops.sample_mode = Numerics.SampleMode.Direct; ops.refew = ewref;
cts = Numerics.Contour.Circle(-3.5, 3.5, 256);
csim = Numerics.CIM(ops, cts); csim.SampleData.show_progress = false;
csim.SampleData.L = 1; csim.SampleData.R = 1;            % scalar identity probing for 1x1 H
csim.RealizationData.RealizationSize = Numerics.RealizationSize(n, n, n);
csim.setComputationalMode(Numerics.ComputationalMode.Hankel); csim.compute();
assert(numel(csim.ResultData.ew) == n, "SISO Hankel: should return n eigenvalues");
ddH = csim.matchingDistance();
csim.setComputationalMode(Numerics.ComputationalMode.MPLoewner); csim.compute();
assert(numel(csim.ResultData.ew) == n, "SISO MPLoewner: should return n eigenvalues");
ddM = csim.matchingDistance();
fprintf("  SISO Hankel md=%.2e (conditioning-limited), MPLoewner md=%.2e\n", ddH, ddM);
assert(ddH < 1e-4, "SISO Hankel: md=%.2e exceeds 1e-4", ddH);
assert(ddM < 1e-6, "SISO MPLoewner: md=%.2e exceeds 1e-6", ddM);
fprintf("SISO recovery (Hankel/MPLoewner): PASS\n");

%% 5. eigs() convenience interface
cim.SampleData.L = I; cim.SampleData.R = I;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(n, 1, 1);
cim.setComputationalMode(Numerics.ComputationalMode.Hankel);
[V, D, W] = cim.eigs();
ew = diag(D);
assert(numel(ew) == n, "eigs: should return n eigenvalues");
assert(issorted(abs(ew)), "eigs: eigenvalues should be sorted by magnitude");
assert(isequal(size(V), [n n]) && isequal(size(W), [n n]), "eigs: V and W should be n-by-n");
assert(max(abs(vecnorm(V) - 1)) < 1e-10, "eigs: right eigenvectors should be unit-normalized");
assert(max(abs(vecnorm(W) - 1)) < 1e-10, "eigs: left eigenvectors should be unit-normalized");
assert(Numerics.matching_distance(ewref, ew) < 1e-8, "eigs: eigenvalues should match the reference spectrum");
fprintf("eigs() interface (sorted, unit-normalized): PASS\n");

%% 6. MPLoewner with unequal #theta != #sigma (rectangular Loewner pencil)
% The Loewner pencil need not be square: realize() SVD-truncates to m, so
% recovery only requires min(#theta,#sigma) >= m (the McMillan degree). This
% pins the fix for the padding bug in build_exact_data / build_quadrature_data
% (PRELIM_REVIEW.md sec 3), which previously sized the tangential-direction
% arrays with swapped lengths and crashed for any unequal counts.
mk  = @(cnt,rad,off) (-3.5 + rad*exp(2i*pi*((0:cnt-1).'+off)/cnt));  % distinct pts off the spectrum
pad = {"PadStrategy", "cyclical", "Verbose", false};
% more left than right points (pads the left side), full identity directions
ewU1 = sort(Numerics.mploewner.mploewner_exact(H, mk(n+2,4,0), mk(n,5,0.5), I, I, m, pad{:}));
assert(Numerics.matching_distance(ewref, ewU1) < 1e-6, "MPLoewner #theta>#sigma must recover the spectrum");
% more right than left points (pads the right side)
ewU2 = sort(Numerics.mploewner.mploewner_exact(H, mk(n,4,0), mk(n+2,5,0.5), I, I, m, pad{:}));
assert(Numerics.matching_distance(ewref, ewU2) < 1e-6, "MPLoewner #sigma>#theta must recover the spectrum");
% single tangential direction + unequal counts -> cyclical padding on both sides
ewU3 = sort(Numerics.mploewner.mploewner_exact(H, mk(n+1,4,0), mk(n,5,0.5), I(:,1), I(:,1), m, pad{:}));
assert(Numerics.matching_distance(ewref, ewU3) < 1e-6, "MPLoewner single-direction unequal counts must recover the spectrum");
% boundary: min(#theta,#sigma) < m is under-determined -> must error loudly,
% with the informative too-few-points message (not a generic rank/subscript error)
errid = "";
try
    Numerics.mploewner.mploewner_exact(H, mk(m-2,4,0), mk(m-3,5,0.5), I, I, m, pad{:});
catch e
    errid = string(e.identifier);
end
assert(errid == "Numerics:mploewner:tooFewPoints", ...
    "min(#theta,#sigma) < m should raise Numerics:mploewner:tooFewPoints, got '%s'", errid);
fprintf("MPLoewner rectangular (unequal #theta/#sigma) recovery: PASS\n");

%% 7. Cyclical tangential-direction padding (fewer directions than points)
% When fewer probing directions than interpolation points are supplied, the
% "cyclical" PadStrategy reuses them -- so the quadrature path needs only
% Lsize/Rsize linear solves, not one per point. Prove the padding is byte-
% identical to manually supplying the cycled directions/samples (i.e. the
% direction-reuse behavior is intact), for both the exact and quadrature paths.
% (Recovery from cyclical-padded directions is exercised separately in section 6.)
thetaP = mk(8,4,0); sigmaP = mk(6,5,0.5);             % 8 left / 6 right interpolation points
elltheta = numel(thetaP); rsigma = numel(sigmaP);
rng(1); Ls = 3; Rs = 2; Lp = randn(n,Ls); Rp = randn(n,Rs);   % fewer directions than points
Lcyc = Lp(:, mod((0:elltheta-1), Ls)+1);              % manual cyclic expansion -> n x elltheta
Rcyc = Rp(:, mod((0:rsigma-1),  Rs)+1);               %                        -> n x rsigma

% exact: cyclical padding == manually cycling the directions
[~,BBp,~,CCp] = Numerics.mploewner.build_exact_data(H, thetaP, sigmaP, Lp,   Rp,   "cyclical", false);
[~,BBf,~,CCf] = Numerics.mploewner.build_exact_data(H, thetaP, sigmaP, Lcyc, Rcyc, "cyclical", false);
assert(isequal(BBp,BBf) && isequal(CCp,CCf), "exact cyclical padding must equal manual direction cycling");
assert(isequal(size(BBp),[elltheta rsigma]), "padded BB must be elltheta-by-rsigma");

% quadrature: cyclical padding reuses the Lsize/Rsize samples == manually cycling them
opC = Numerics.OperatorData(H); opC.sample_mode = Numerics.SampleMode.Direct;
ctC = Numerics.Contour.Circle(-3.5, 3.5, 64);
sdC = Numerics.SampleData(opC, ctC); sdC.show_progress = false;
sdC.L = Lp; sdC.R = Rp; sdC.compute();                % only Ls/Rs directions are actually sampled
[~,BBq,~,CCq] = Numerics.mploewner.build_quadrature_data(ctC.z, ctC.w, sdC.Ql, sdC.Qr, Lp, Rp, thetaP, sigmaP, "cyclical", false);
Qlc = sdC.Ql(mod((0:elltheta-1),Ls)+1, :, :);         % manually cycled samples (no padding needed)
Qrc = sdC.Qr(:, mod((0:rsigma-1), Rs)+1, :);
[~,BBqf,~,CCqf] = Numerics.mploewner.build_quadrature_data(ctC.z, ctC.w, Qlc, Qrc, Lcyc, Rcyc, thetaP, sigmaP, "cyclical", false);
assert(isequal(BBq,BBqf) && isequal(CCq,CCqf), "quadrature cyclical padding must reuse samples == manual cycling");
fprintf("MPLoewner cyclical direction padding (== manual cycling, reuses solves): PASS\n");

%%
fprintf("\nAll realization tests passed!\n");
