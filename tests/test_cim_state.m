% State handling of Numerics.CIM and its parts:
%   - construction, copy, display, reading L or R, and an SPLoewner mode switch leave the global random stream alone;
%     compute draws the probing directions, L before R (SampleData.drawDirections)
%   - copy(c), fromNumerics and toNumerics keep options, shifts and the realization state
%   - replacing c.SampleData or c.RealizationData re-wires the CIM's listeners
%   - setComputationalMode(cm, RealizationSize) applies mode and size together
%   - the data matrices survive a refused realization; options.RelTol sets a relative rank tolerance
%   - Circle.interlevedshifts does not depend on the node count, and its 'trap' phase gives BEG's points
%   - lowering ell and r after sampling keeps the samples; the realization uses their leading directions
%   - SampleData re-wires replaced contours and operators; ell or r = 0 gives a plain error
%   - objects loaded from a MAT file keep reacting to changes (listeners reinstalled by loadobj)
%   - a replaced Visual part leaves the axes, and its replacement is drawn
%   - regressions from the audit: stale samples are refused, every invalidation marks the realization stale,
%     operator T/sample_mode changes invalidate the samples, copies share undrawn directions, Hankel ignores leftover shifts
%   - OperatorData copies keep coeffs and helpstr
%   - a CIM starts without a contour: it copies, loads and converts, compute asks for one, and a contour set later is used
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);

n = 7; A = diag(-(1:n)); B = randn(n); C = randn(n);
H = @(z) C*((z*eye(n) - A) \ B);
op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct;
ct = Numerics.Contour.Circle(-4, 4, 64);     % encloses all poles
MP = Numerics.ComputationalMode.MPLoewner; SP = Numerics.ComputationalMode.SPLoewner;
streamAt = @(s) isequal(s.State, getfield(rng, 'State'));

%% construction, display and reading L draw nothing; compute draws L then R
rng(1); s = rng;
c = Numerics.CIM(op, ct); c.SampleData.show_progress = false; c.options.Verbose = false;
evalc('disp(c.SampleData)'); L0 = c.SampleData.L;
assert(streamAt(s) && isempty(L0), "construction, display and reading L must not draw from the random stream");
rng(1); L1 = randn(n); R1 = randn(n);
rng(1);
c.RealizationData.m = n; c.RealizationData.K = 1; c.compute();
assert(isequal(c.SampleData.L, L1) && isequal(c.SampleData.R, R1), "compute must draw L (n x ell), then R (n x r)");
assert(Numerics.matching_distance(-(1:n).', c.ResultData.ew) < 1e-10, "lazily drawn directions must still recover the spectrum");
g = Numerics.CIM(op, ct); s = rng;
g.SampleData.L = eye(n, 2); g.SampleData.R = eye(n, 3);
assert(streamAt(s) && isequal(size(g.SampleData.L), [n 2]) && isequal(size(g.SampleData.R), [n 3]), ...
    "explicit L and R must replace the default directions without a draw");
fprintf("lazy probing directions: PASS\n");

%% copy keeps options and draws nothing
s = rng; cp = copy(c);
assert(streamAt(s), "copy must not draw from the random stream");
assert(isequaln(cp.options, c.options), "copy must keep options");
assert(isequal(cp.SampleData.L, c.SampleData.L) && isequal(cp.SampleData.R, c.SampleData.R), "copy must keep the directions");
cp.compute();
assert(isequal(sort(cp.ResultData.ew), sort(c.ResultData.ew)), "a copy must recompute the same eigenvalues");
fprintf("copy: PASS\n");

%% replacing RealizationData or SampleData re-wires the listeners
c4 = Numerics.CIM(op, ct);
c4.RealizationData = Numerics.RealizationData(MP);
c4.RealizationData.RealizationSize = Numerics.RealizationSize(n, n, n);
assert(numel(c4.RealizationData.InterpolationData.sigma) == n, "a new RealizationData must still drive the shifts");
ct4 = Numerics.Contour.Circle(-4, 5, 64);
c4.SampleData = Numerics.SampleData(op, ct4);
s1 = c4.RealizationData.InterpolationData.sigma; ct4.rho = 6;
s2 = c4.RealizationData.InterpolationData.sigma;
assert(abs(max(abs(s2 + 4)) - 1.25*6) < 1e-12 && ~isequal(s1, s2), "the shifts must follow the new SampleData's contour");
assert(c4.DataDirtiness == 2, "an unsampled SampleData must mark the CIM for resampling");
fprintf("listener re-wiring: PASS\n");

%% mode and size together
c5 = Numerics.CIM(op, ct);
c5.setComputationalMode(MP, Numerics.RealizationSize(n, 9, 9));
assert(c5.RealizationData.K == 9 && numel(c5.RealizationData.InterpolationData.theta) == 9 ...
    && numel(c5.RealizationData.InterpolationData.sigma) == 9, "setComputationalMode(cm, size) must apply the size and its shifts");
fprintf("setComputationalMode with size: PASS\n");

%% data matrices survive a refused realization; relative rank tolerance
c6 = Numerics.CIM(op, ct); c6.SampleData.show_progress = false; c6.options.Verbose = false;
c6.setComputationalMode(MP, Numerics.RealizationSize(n + 1, n + 1, n + 1));
c6.options.RelTol = 1e-6;                   % above sigma_{n+1}/sigma_1 at N = 64, so m = n+1 is refused
errid = "";
try
    c6.compute();
catch e
    errid = string(e.identifier);
end
assert(errid == "Numerics:realize:rankDeficient", "m above the numerical rank must be refused, got '%s'", errid);
assert(isequal(size(c6.ResultData.Db), [n + 1, n + 1]) && isempty(c6.ResultData.ew), "a refused realization must keep Db and clear the eigenvalues");
assert(numel(diag(c6.ResultData.Sigma)) == n + 1, "a refused realization must keep the singular values of Db, for choosing m");
sv = svd(c6.ResultData.Db);
c6.options.RelTol = 0.5*sv(n + 1)/sv(1); c6.compute();
assert(numel(c6.ResultData.ew) == n + 1, "RelTol below sigma_{n+1}/sigma_1 must accept m = n+1");
c6.options.RelTol = NaN; c6.RealizationData.m = n;
Db = c6.getFullDataMatrices();
assert(isequal(size(Db), [n + 1, n + 1]) && isempty(c6.ResultData.ew), "getFullDataMatrices must not realize");
fprintf("data matrices and rank tolerance: PASS\n");

%% Circle shifts do not depend on N; SPLoewner switch draws nothing
k1 = Numerics.Contour.Circle(0.3+0.1i, 2, 128); k2 = Numerics.Contour.Circle(0.3+0.1i, 2, 64);
[t1, g1] = k1.interlevedshifts(11); [t2, g2] = k2.interlevedshifts(11);
assert(isequal(t1, t2) && isequal(g1, g2), "Circle.interlevedshifts must not depend on the node count");
c8 = Numerics.CIM(op, ct); s = rng;
c8.setComputationalMode(SP);
assert(streamAt(s), "an SPLoewner mode switch must not draw from the random stream");
assert(~ct.inside(c8.RealizationData.InterpolationData.sigma(1)), "the SPLoewner shift must lie outside the contour");
fprintf("deterministic shifts: PASS\n");

%% the 'trap' phase gives the interleaved points of BEG (SIAM Rev. 2023, Fig. 7)
% right points at pi/2 + 2*pi*j/K from +i, left points at the midpoints
gm = 0.3+0.1i; rho = 2; rs = 1.25*rho;
for K = [1 2 4 8]
    [th, sg] = Numerics.Contour.Circle(gm, rho, 64).interlevedshifts(K, 1.25, 'scale', 'trap', pi/2 - pi/K);
    a = pi/2 + 2*pi*(0:K-1).'/K;
    assert(max(abs(sg - (gm + rs*exp(1i*a)))) < 1e-14 && max(abs(th - (gm + rs*exp(1i*(a + pi/K))))) < 1e-14, ...
        "'trap' with phase pi/2 - pi/K must give BEG's points for K = %d", K);
end
c7 = Numerics.CIM(op, ct); c7.auto_update_shifts = false;
c7.setComputationalMode(MP, Numerics.RealizationSize(n, 8, 8));
c7.contour_interlevedshifts(1.25, 'scale', 'trap', pi/2 - pi/8);
assert(abs(c7.RealizationData.InterpolationData.sigma(1) - (-4 + 5i)) < 1e-14, "contour_interlevedshifts must pass variant and phase through");
errid = "";
try
    ct.interlevedshifts(8, 1.25, 'scale', 'cconj', 0.1);
catch e
    errid = string(e.identifier);
end
assert(errid == "Numerics:Circle:phaseNeedsTrap", "a phase with the 'cconj' variant must be refused");
fprintf("interleaved-shift phase: PASS\n");

%% ell and r select the leading directions; lowering them after sampling keeps the samples
for md = [Numerics.ComputationalMode.Hankel, MP]
    c9 = Numerics.CIM(op, ct); c9.SampleData.show_progress = false; c9.options.Verbose = false;
    c9.SampleData.ell = 6; c9.SampleData.r = 6;
    if md == MP, c9.setComputationalMode(MP, Numerics.RealizationSize(n, n, n));
    else, c9.RealizationData.K = 3; c9.RealizationData.m = n; end
    c9.compute(); sd = c9.SampleData;
    sd.ell = 3; sd.r = 3;
    assert(sd.loaded && c9.DataDirtiness == 1, "lowering ell and r must keep the samples and mark the realization stale");
    c9.compute();
    assert(size(sd.Ql,1) == 6 && size(sd.Qr,2) == 6, "the stored samples must keep all six directions");
    K = c9.RealizationData.K; [th, sg] = c9.RealizationData.getThetaSigma(K, K);
    if md == MP
        Dbh = Numerics.mploewner.mploewner_quadrature_data(ct.z, ct.w, sd.Ql(1:3,:,:), sd.Qr(:,1:3,:), sd.Lf(:,1:3), sd.Rf(:,1:3), th, sg, "cyclical", false);
    else
        Dbh = Numerics.sploewner.sploewner_quadrature_data(sg(1), ct.z, ct.w, sd.Ql(1:3,:,:), sd.Qr(:,1:3,:), sd.Qlr(1:3,1:3,:), K);
    end
    assert(isequal(c9.ResultData.Db, Dbh), "%s: Db must be bitwise the Db of the hand-sliced samples", string(md));
    c10 = Numerics.CIM(op, ct); c10.SampleData.show_progress = false; c10.options.Verbose = false;
    c10.SampleData.L = sd.Lf(:,1:3); c10.SampleData.R = sd.Rf(:,1:3);
    if md == MP, c10.setComputationalMode(MP, Numerics.RealizationSize(n, n, n));
    else, c10.RealizationData.K = 3; c10.RealizationData.m = n; end
    c10.compute();
    reldiff = norm(c10.ResultData.Db - c9.ResultData.Db) / norm(c9.ResultData.Db);
    assert(reldiff < 1e-13, "%s: Db must match sampling at ell = r = 3 with the same directions (rel. diff %.1e)", string(md), reldiff);
    fprintf("  %-9s Db vs sampling at ell = r = 3: relative difference %.1e\n", string(md), reldiff);
    sd.ell = 6;  assert(sd.loaded, "raising ell back to the sampled count must keep the samples");
    sd.ell = 7;  assert(~sd.loaded, "raising ell above the sampled count must require sampling");
end
c11 = Numerics.CIM(op, Numerics.Contour.Circle(-4, 4, 64)); c11.SampleData.show_progress = false; c11.options.Verbose = false;
c11.SampleData.ell = 6; c11.SampleData.r = 6;
c11.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); c11.compute();
c11.SampleData.ell = 3; c11.SampleData.r = 3; c11.refineQuadrature();
assert(isequal(size(c11.SampleData.Ql), [3 n 128]) && numel(c11.ResultData.ew) == n, ...
    "refinement must keep and sample only the leading ell and r directions");
c11.SampleData.ell = 6; c11.SampleData.r = 6;
assert(~c11.SampleData.loaded, "raising ell above the refined sample count must require sampling");
c11.compute();
c13 = Numerics.CIM(op, Numerics.Contour.Circle(-4, 4, 128)); c13.SampleData.show_progress = false; c13.options.Verbose = false;
c13.SampleData.L = c11.SampleData.Lf(:,1:6); c13.SampleData.R = c11.SampleData.Rf(:,1:6);
c13.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); c13.compute();
assert(norm(c13.ResultData.Db - c11.ResultData.Db) < 1e-13*norm(c11.ResultData.Db), "the resample must reuse the same leading directions");
fprintf("ell and r as leading directions: PASS\n");

%% staleness and bookkeeping (Fable review of these changes)
c12 = Numerics.CIM(op, ct); c12.SampleData.show_progress = false; c12.options.Verbose = false;
c12.RealizationData.K = 2; c12.RealizationData.m = n; c12.compute();
lh = addlistener(c12.ResultData, 'ew', 'PostSet', @(~,~) eventCount("add"));
eventCount("reset"); c12.compute(); nset = eventCount("get"); delete(lh);
assert(nset == 1 && c12.DataDirtiness == 0, "a compute must set the eigenvalues once (got %d)", nset);
c12.options.Verbose = true;
assert(c12.DataDirtiness == 1, "an options change must mark the realization stale");
c12.SampleData.ell = 6; c12.compute(); c12.SampleData.Lf = c12.SampleData.Lf(:,1:2);
assert(~c12.SampleData.loaded, "assigning Lf must invalidate the samples");
c12.compute(); c12.auto_update_shifts = false; c12.RealizationData.ComputationalMode = MP;
assert(c12.DataDirtiness == 1, "a direct ComputationalMode change must mark the realization stale");
assert(Numerics.rankdet(zeros(0,0), 1e-3) == 0, "rankdet of an empty matrix with a tolerance must be 0");
[thm, sgm] = ct.interlevedshifts(n);
mt = Numerics.ModalTruncation(H, Numerics.Contour.Circle(-4, 4, 64));
mt.setRealizationData(Numerics.RealizationData(MP, Numerics.InterpolationData(thm, 2*sgm), Numerics.RealizationSize(n, n, n)));
assert(isequal(mt.RegionCIM.RealizationData.InterpolationData.sigma, 2*sgm), "setRealizationData must keep the shifts it is given");
fprintf("staleness and bookkeeping: PASS\n");

%% ell or r = 0 gives a plain error
c14 = Numerics.CIM(op, ct); c14.SampleData.show_progress = false; c14.options.Verbose = false;
c14.SampleData.ell = 0;
errid = ""; try, c14.compute(); catch e, errid = string(e.identifier); end
assert(errid == "Numerics:SampleData:noDirections", "ell = 0 must refuse to sample, got '%s'", errid);
c14.SampleData.ell = 3; c14.RealizationData.K = 3; c14.RealizationData.m = n; c14.compute(); c14.SampleData.r = 0;
errid = ""; try, c14.computeRealization(); catch e, errid = string(e.identifier); end
assert(errid == "Numerics:SampleData:noDirections", "r = 0 must refuse to realize, got '%s'", errid);
errid = ""; try, Visual.CIM(Visual.OperatorData(), Visual.Contour.Circle()).compute(); catch e, errid = string(e.message); end
assert(contains(errid, "load a problem"), "an unloaded operator must still be reported first");
fprintf("ell or r = 0: PASS\n");

%% SampleData re-wires replaced contours and operators
c15 = Numerics.CIM(op, Numerics.Contour.Circle(-4, 4, 64)); c15.SampleData.show_progress = false; c15.options.Verbose = false;
c15.RealizationData.K = 3; c15.RealizationData.m = n; c15.compute();
oldct = c15.SampleData.Contour; c15.SampleData.Contour = Numerics.Contour.Circle(-4, 4.5, 64); c15.compute();
oldct.rho = 3;
assert(c15.SampleData.loaded, "a change to a replaced contour must not reach the SampleData");
sd = c15.SampleData; Lf0 = sd.Lf;
sd.OperatorData = Numerics.OperatorData();
assert(~sd.loaded && isempty(sd.Lf) && sd.ell == n, "an unloaded operator must drop the samples and directions and keep ell");
sd.OperatorData = op; sd.Lf = Lf0; sd.Rf = Lf0; c15.compute();
op2 = Numerics.OperatorData(H); op2.sample_mode = Numerics.SampleMode.Direct;
sd.OperatorData = op2;
assert(~sd.loaded && isequal(sd.Lf, Lf0), "a same-size operator must drop the samples and keep the directions");
op3 = Numerics.OperatorData(@(z) z*eye(3) - diag([1 2 3])); sd.OperatorData = op3;
assert(~sd.loaded && isempty(sd.Lf), "a different-size operator must drop the directions");
op3.loaded = false; op3.loaded = true;
assert(sd.ell == 3, "loading the new operator must reach the SampleData (ell clamped to its size)");
fprintf("SampleData re-wiring: PASS\n");

%% copy, fromNumerics and toNumerics keep the realization state
c16 = Numerics.CIM(op, ct); c16.SampleData.show_progress = false; c16.options.Verbose = false;
c16.setComputationalMode(MP, Numerics.RealizationSize(n, n, n));
[th16, sg16] = ct.interlevedshifts(n); sg16 = -4 + 1.1*(sg16 + 4);   % custom shifts, farther out than the defaults
c16.RealizationData.InterpolationData = Numerics.InterpolationData(th16, sg16);
c16.compute();
same = @(x) x.DataDirtiness == 0 && x.RealizationData.loaded && isequal(x.RealizationData.InterpolationData.sigma, sg16) ...
    && isequal(x.ResultData.ew, c16.ResultData.ew);
cp16 = copy(c16); v16 = Visual.CIM.fromNumerics(c16); n16 = v16.toNumerics();
assert(same(cp16) && same(v16) && same(n16), "copy, fromNumerics and toNumerics must keep shifts, results and a clean state");
mt16 = Numerics.ModalTruncation(H, Numerics.Contour.Circle(-4, 4, 64));
mt16.RegionCIM.SampleData.show_progress = false; mt16.RegionCIM.options.Verbose = false;
mt16.RegionCIM.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); mt16.compute();
vmt = Visual.ModalTruncation.fromNumerics(mt16); nmt = vmt.toNumerics(); cmt = copy(vmt);
assert(vmt.RegionCIM.DataDirtiness == 0 && nmt.RegionCIM.DataDirtiness == 0 && isa(cmt, 'Visual.ModalTruncation'), ...
    "ModalTruncation conversions and copies must keep a clean state and their class");
lh = addlistener(vmt.RegionCIM.RealizationData, 'InterpolationData', 'PostSet', @(~,~) eventCount("add"));
eventCount("reset"); vmt.RegionCIM.SampleData.Contour.rho = 4.5; nset = eventCount("get"); delete(lh);
assert(nset == 1, "a contour change must update the shifts once, not through a leftover CIM (got %d)", nset);
fprintf("copy and conversions: PASS\n");

%% objects loaded from a MAT file keep reacting to changes
f = [tempname '.mat'];
vo = Visual.OperatorData(H); vo.sample_mode = Numerics.SampleMode.Direct;
v17 = Visual.CIM(vo, Visual.Contour.Circle(-4, 4, 64));
for c17 = {copy(c16), v17}
    x = c17{1}; x.SampleData.show_progress = false; x.options.Verbose = false;
    x.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); x.compute();
    lastwarn(''); save(f, 'x'); S = load(f); y = S.x; [wmsg, ~] = lastwarn;
    assert(isempty(wmsg), "%s: loading must not warn, got '%s'", class(y), wmsg);
    assert(y.DataDirtiness == 0 && isequal(y.RealizationData.InterpolationData.sigma, x.RealizationData.InterpolationData.sigma) ...
        && isequal(y.ResultData.ew, x.ResultData.ew), "%s: a load must keep shifts, results and a clean state", class(y));
    z0 = y.SampleData.Contour.z; s0 = y.RealizationData.InterpolationData.sigma;
    y.SampleData.Contour.rho = 5;
    assert(~isequal(z0, y.SampleData.Contour.z) && ~y.SampleData.loaded && ~isequal(s0, y.RealizationData.InterpolationData.sigma) ...
        && y.DataDirtiness == 2, "%s: after a load a contour change must move the nodes and shifts and mark the samples stale", class(y));
end
% axes are not saved, so a load does not reopen the figure they belong to
fg = figure('Visible', 'off'); x = Visual.CIM(vo, Visual.Contour.Circle(-4, 4, 64), Visual.RealizationData(), axes(fg));
nfig = numel(findall(groot, 'Type', 'figure'));
save(f, 'x'); S = load(f); y = S.x; close(fg);
assert(isempty(y.ax) && numel(findall(groot, 'Type', 'figure')) == nfig - 1, "a load must not restore axes or reopen their figure");
if exist('nlevp', 'file')
    x = Numerics.CIM(Numerics.OperatorData([], 'acoustic_wave_1d'), Numerics.Contour.Circle(0.8i, 3, 32));
    save(f, 'x'); S = load(f); y = S.x;
    assert(isequal(y.SampleData.OperatorData.T(0.1), x.SampleData.OperatorData.T(0.1)), "an NLEVP operator must survive a load");
end
delete(f);
% parfor workers receive objects through the same serialization
x = copy(c16); moved = false(1,2);
parfor k = 1:2
    y = x; z0 = y.SampleData.Contour.z;
    y.SampleData.Contour.rho = 4 + k/2;
    moved(k) = ~isequal(z0, y.SampleData.Contour.z) && ~y.SampleData.loaded;
end
assert(all(moved), "on a parfor worker a contour change must move the nodes and mark the samples stale");
fprintf("MAT load and parfor: PASS\n");

%% replaced Visual parts hand their axes to the replacement
fg = figure('Visible', 'off'); ax = subplot(1, 2, 1, 'Parent', fg); ax2 = subplot(1, 2, 2, 'Parent', fg);
v18 = Visual.CIM(vo, Visual.Contour.Circle(-4, 4, 64), Visual.RealizationData(), {ax, ax2});
v18.SampleData.show_progress = false; v18.options.Verbose = false;
drawn = @() findall(ax, 'Tag', 'contour');
radius = @() max(abs(get(drawn(), 'XData') + 4));
oldct = v18.SampleData.Contour; v18.SampleData.Contour = Visual.Contour.Circle(-4, 5, 64); oldct.rho = 2;
assert(isscalar(drawn()) && abs(radius() - 5) < 1e-12 && isempty(oldct.ax), "a replaced contour must leave the axes and the new one be drawn");
oldsd = v18.SampleData; v18.SampleData = Visual.SampleData(vo, Visual.Contour.Circle(-4, 6, 64)); oldsd.Contour.rho = 3;
assert(isscalar(drawn()) && abs(radius() - 6) < 1e-12, "a replaced SampleData must leave the axes and the new one be drawn");
v18.SampleData.show_progress = false; v18.RealizationData.K = 3; v18.RealizationData.m = n; v18.compute();
v18.ResultData = Visual.ResultData();
assert(isempty(findall(ax, 'Tag', 'computed_eigenvalues')), "a replaced ResultData must take its eigenvalue markers along");
v18.compute();
assert(isscalar(findall(ax, 'Tag', 'computed_eigenvalues')), "the new ResultData must draw its eigenvalues");
close(fg);
fprintf("Visual part replacement: PASS\n");

%% regressions found by the audit of these changes (numerics core)
mk = @(rho) Numerics.CIM(op, Numerics.Contour.Circle(-4, rho, 64));
fresh = @(c) freshDb(c);
% raising ell or r above the sampled count, then realizing without sampling, must not reuse the old samples
c20 = mk(4); quietCIM(c20); c20.SampleData.ell = 2; c20.SampleData.r = 2; c20.RealizationData.K = 4; c20.RealizationData.m = n; c20.compute();
c20.SampleData.ell = 4; c20.SampleData.r = 4;
for f = {@() c20.computeRealization(), @() c20.computeDataMatrices()}
    errid = ""; try, f{1}(); catch e, errid = string(e.identifier); end
    assert(errid == "Numerics:SampleData:stale", "realizing with ell above the sampled count must refuse, got '%s'", errid);
end
c20.compute();
assert(isequal(size(c20.ResultData.Db), [16 16]), "compute must resample and realize with all four directions");
% every way of invalidating or replacing the samples, parameters or parts must mark the realization stale
cases = {
    "contour change, then a direct SampleData.compute", @(c) setThen(c, @() assign(c.SampleData.Contour, 'rho', 3.5), @() c.SampleData.compute())
    "N change with auto shifts off",                     @(c) setThen(c, @() assign(c, 'auto_update_shifts', false), @() assign(c.SampleData.Contour, 'N', 96), @() c.SampleData.compute())
    "direct SampleData.refineQuadrature",                @(c) c.SampleData.refineQuadrature()
    "same-size operator swap, then SampleData.compute",  @(c) setThen(c, @() assign(c.SampleData, 'OperatorData', copy(op)), @() c.SampleData.compute())
    "an already-sampled SampleData assigned",            @(c) assign(c, 'SampleData', sampledLike(c, 3.5))
    "a loaded RealizationData of another CIM assigned",  @(c) assign(c, 'RealizationData', loadedRealization(mk(4.5)))
    "ResultData replaced",                               @(c) assign(c, 'ResultData', Numerics.ResultData())
};
for i = 1:size(cases, 1)
    c21 = mk(4); quietCIM(c21); c21.setComputationalMode(SP); c21.RealizationData.K = 2; c21.RealizationData.m = n; c21.compute();
    cases{i, 2}(c21);
    assert(c21.DataDirtiness > 0, "%s: the realization must be marked stale", cases{i, 1});
    Db = c21.getFullDataMatrices();
    assert(isequal(Db, fresh(c21)), "%s: getFullDataMatrices must rebuild from the current samples", cases{i, 1});
end
% a new T or sample_mode invalidates the samples
c22 = mk(4); quietCIM(c22); c22.RealizationData.K = 2; c22.RealizationData.m = n; c22.compute();
c22.SampleData.OperatorData.sample_mode = Numerics.SampleMode.Inverse;
assert(~c22.SampleData.loaded && c22.DataDirtiness == 2, "a sample_mode change must invalidate the samples");
c22.SampleData.OperatorData.sample_mode = Numerics.SampleMode.Direct; c22.compute();
c22.SampleData.OperatorData.T = @(z) 2*H(z);
assert(~c22.SampleData.loaded && c22.DataDirtiness == 2, "a new T must invalidate the samples");
c22.SampleData.OperatorData.T = H;
% copies, conversions and tf of a CIM with undrawn directions share one draw
c23 = mk(4); quietCIM(c23); c23.SampleData.ell = 3; c23.SampleData.r = 3; c23.RealizationData.K = 3; c23.RealizationData.m = n;
a = copy(c23); b = copy(c23); v23 = Visual.CIM.fromNumerics(c23);
assert(isequal(a.SampleData.L, b.SampleData.L, c23.SampleData.L, v23.SampleData.L) && size(a.SampleData.L, 2) == 3, ...
    "copies and conversions of an undrawn CIM must share the source's directions");
[~, Lam1] = c23.tf(); [~, Lam2] = c23.tf();
assert(isequal(Lam1, Lam2), "tf must give the same realization on every call");
% Hankel uses sigma = Inf even when InterpolationData still holds other shifts
c24 = mk(4); quietCIM(c24); c24.setComputationalMode(MP, Numerics.RealizationSize(3, 3, 3)); c24.compute();
c24.auto_update_shifts = false; c24.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
c24.RealizationData.RealizationSize = Numerics.RealizationSize(n, 3, 3); c24.compute();
c25 = mk(4); quietCIM(c25); c25.SampleData.L = c24.SampleData.L; c25.SampleData.R = c24.SampleData.R; c25.RealizationData.K = 3; c25.RealizationData.m = n; c25.compute();
assert(isequal(c24.ResultData.Db, c25.ResultData.Db), "Hankel must ignore leftover finite shifts");
% a failure while building the data clears the previous realization
c26 = mk(4); quietCIM(c26); c26.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); c26.compute();
c26.auto_update_shifts = false; c26.RealizationData.InterpolationData = Numerics.InterpolationData([], []);
try, c26.computeRealization(); catch, end
assert(isempty(c26.ResultData.ew) && c26.DataDirtiness == 1, "a build failure must clear the previous realization");
fprintf("audit regressions (numerics core): PASS\n");

%% parts that outlive their owner do not keep it alive (weak references), and delete leaves them clean
rd30 = Numerics.RealizationData(MP, [], Numerics.RealizationSize(n, n, n));
c30 = Numerics.CIM(op, Numerics.Contour.Circle(-4, 4, 64), rd30); w30 = matlab.lang.WeakReference(c30);
c31 = Numerics.CIM(op, Numerics.Contour.Circle(10, 4, 64), rd30); %#ok<NASGU> % shares rd30
clear c30
assert(~isvalid(w30.Handle), "a dropped CIM must be collected although its RealizationData lives on");
rd30.RealizationSize = Numerics.RealizationSize(n, 5, 5);
assert(max(abs(abs(rd30.InterpolationData.sigma - 10) - 5)) < 1e-12, "only the live CIM may drive a shared RealizationData's shifts");
ct32 = Numerics.Contour.Circle(-4, 4, 64);
c32 = Numerics.CIM(op, ct32); w32 = matlab.lang.WeakReference(c32); c33 = Numerics.CIM(op, ct32);
clear c32
assert(~isvalid(w32.Handle), "a dropped CIM must be collected although its contour lives on");
delete(c33); lastwarn('');
ct32.rho = 4.5; op.refew = []; [wmsg, ~] = lastwarn;
assert(isempty(wmsg), "a deleted CIM must leave no listeners on its surviving parts, got '%s'", wmsg);
vo36 = Visual.OperatorData(H); vo36.sample_mode = Numerics.SampleMode.Direct;
v36 = Visual.CIM(vo36, Visual.Contour.Circle(-4, 4, 64)); w36 = matlab.lang.WeakReference(v36);
v37 = Visual.CIM(vo36, Visual.Contour.Circle(-4, 4, 64));
clear v36
assert(~isvalid(w36.Handle) && isvalid(vo36), "a dropped Visual CIM must be collected and leave a shared operator alive");
delete(v37);
assert(isvalid(vo36), "deleting a Visual CIM must not delete a part it shares");
fprintf("weak references and delete: PASS\n");

%% small fixes from the audit
q38 = Numerics.Contour.Quad(ct.z, ct.w); c38 = Numerics.CIM(op, q38); c38c = copy(c38);
assert(isequal(c38c.SampleData.Contour.z, ct.z), "copy must work for a plain Quad contour");
mt39 = Numerics.ModalTruncation(H, Numerics.Contour.Circle(-4, 4, 64));
mt39.RegionCIM.SampleData.show_progress = false; mt39.RegionCIM.options.Verbose = false;
mt39.RegionCIM.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); mt39.compute();
m39 = copy(mt39); z39 = -3 + 0.5i; h39 = m39.RegionTF(z39);
mt39.RegionCIM.SampleData.Contour.rho = 3.5; mt39.compute();
assert(isequal(m39.RegionTF(z39), h39), "a ModalTruncation copy's transfer function must not follow its source");
fg = figure('Visible', 'off'); ax = axes(fg);
vmt40 = Visual.ModalTruncation(H, Visual.Contour.Circle(-4, 4, 64), Visual.RealizationData(), ax);
vmt40.detachFromGraphics(); vmt40.attachListeners(); vmt40.ax = ax;
vmt40.RegionCIM = Visual.CIM(vo, Visual.Contour.Circle(-4, 5, 64));
cl = findall(ax, 'Tag', 'contour');
assert(isscalar(cl) && abs(max(abs(get(cl, 'XData') + 4)) - 5) < 1e-12, "a re-attached Visual.ModalTruncation must follow a replaced RegionCIM");
close(fg);
okw = false(1, 2);
parfor k = 1:2
    ow = Visual.OperatorData(H); ow.sample_mode = Numerics.SampleMode.Direct;
    vw = Visual.CIM(ow, Visual.Contour.Circle(-4, 4, 64)); vw.SampleData.show_progress = false; vw.options.Verbose = false;
    vw.RealizationData.K = 2; vw.RealizationData.m = n; vw.compute();
    okw(k) = numel(vw.ResultData.ew) == n;
end
assert(all(okw), "Visual objects must be buildable and computable on a thread-based worker");
fprintf("small fixes from the audit: PASS\n");

%% a CIM starts without a contour; compute asks for one, and a contour set later is used
assert(isempty(Numerics.CIM().SampleData.Contour) && isa(Numerics.CIM().SampleData.Contour, 'Numerics.Contour.Quad') ...
    && isempty(Visual.CIM().SampleData.Contour) && isa(Visual.CIM().SampleData.Contour, 'Visual.Contour.Quad'), ...
    "a default CIM must have an empty contour of its own namespace");
msg = ""; try, Numerics.CIM().compute(); catch e, msg = string(e.message); end
assert(contains(msg, "Contour data required"), "a default CIM must ask for a contour, got '%s'", msg);
f = [tempname '.mat'];
vo41 = Visual.OperatorData(H); vo41.sample_mode = Numerics.SampleMode.Direct;
fg = figure('Visible', 'off'); ax41 = axes(fg);
ref41 = Numerics.CIM(op, Numerics.Contour.Circle(-4, 4, 64)); quietCIM(ref41);   % the same CIM, built with its contour
ref41.setComputationalMode(MP, Numerics.RealizationSize(n, n, n)); ref41.compute();
for c41 = {Numerics.CIM(op), Visual.CIM(vo41, Visual.Contour.Quad.empty, Visual.RealizationData(), ax41)}
    x = c41{1}; quietCIM(x); kind = class(x); lastwarn('');
    x.setComputationalMode(MP, Numerics.RealizationSize(n, n, n));   % no shifts to place yet
    msg = ""; try, x.compute(); catch e, msg = string(e.message); end
    assert(contains(msg, "Contour data required"), "%s: compute without a contour must ask for one, got '%s'", kind, msg);
    errid = ""; try, x.refineQuadrature(); catch e, errid = string(e.identifier); end
    assert(errid == "Numerics:SampleData:noContour", "%s: refining without a contour must ask for one, got '%s'", kind, errid);
    save(f, 'x'); S = load(f);
    if isa(x, 'Visual.CIM'), v = x; else, v = Visual.CIM.fromNumerics(x); end
    parts = {x, copy(x), S.x, v, v.toNumerics()};
    cls = cellfun(@(p) class(p.SampleData.Contour), parts, 'UniformOutput', false);
    assert(all(cellfun(@(p) isempty(p.SampleData.Contour), parts)) && isequal(cls(1:3), repmat({class(x.SampleData.Contour)}, 1, 3)) ...
        && cls{4} == "Visual.Contour.Quad" && cls{5} == "Numerics.Contour.Quad", "%s: copy, load and conversions must keep an empty contour", kind);
    for p = parts
        y = p{1}; quietCIM(y);
        if isa(y, 'Visual.CIM'), y.SampleData.Contour = Visual.Contour.Circle(-4, 4, 64); else, y.SampleData.Contour = Numerics.Contour.Circle(-4, 4, 64); end
        y.SampleData.L = ref41.SampleData.L; y.SampleData.R = ref41.SampleData.R; y.compute();
        assert(isequal(y.RealizationData.InterpolationData.sigma, ref41.RealizationData.InterpolationData.sigma) ...
            && isequal(y.ResultData.Db, ref41.ResultData.Db) && isequal(y.ResultData.ew, ref41.ResultData.ew), ...
            "%s: a contour set later must place the shifts and give the results of a CIM built with it", kind);
    end
    if isa(x, 'Visual.CIM')
        hc = findobj(x.SampleData.Contour.phandles, 'Tag', 'contour');
        assert(isscalar(hc) && hc.Parent == ax41, "a contour set later must be drawn");
        x.SampleData.Contour = Visual.Contour.Quad.empty;
        assert(~isgraphics(hc), "a removed contour must leave the axes");
    else
        x.SampleData.Contour = Numerics.Contour.Quad.empty;
    end
    assert(~x.SampleData.loaded && x.DataDirtiness == 2, "%s: removing the contour must mark the samples stale", kind);
    [wmsg, ~] = lastwarn;
    assert(isempty(wmsg), "%s: a CIM without a contour must not warn, got '%s'", kind, wmsg);
end
close(fg); delete(f);
fprintf("no contour by default: PASS\n");

%% OperatorData copies keep coeffs and helpstr
if exist('nlevp', 'file')
    od = Numerics.OperatorData([], 'acoustic_wave_1d'); oc = copy(od);
    assert(isequal(oc.coeffs, od.coeffs) && ~isempty(oc.coeffs), "copy must keep coeffs");
    assert(isequal(oc.helpstr, od.helpstr) && ~isempty(oc.helpstr), "copy must keep helpstr");
    fprintf("OperatorData copy: PASS\n");
else
    fprintf("OperatorData copy: SKIP (no NLEVP)\n");
end

function k = eventCount(op)
% Counts listener callbacks: "add" one, "reset" to zero, "get" the count.
    persistent count
    if isempty(count) || op == "reset", count = 0; end
    if op == "add", count = count + 1; end
    k = count;
end

function quietCIM(c)
% No progress bar and no padding warnings in the tests.
    c.SampleData.show_progress = false; c.options.Verbose = false;
end

function assign(obj, prop, value)
% obj.(prop) = value, usable inside an anonymous function.
    obj.(prop) = value;
end

function setThen(~, varargin)
% Runs the given steps in order.
    for i = 1:numel(varargin), varargin{i}(); end
end

function Db = freshDb(c)
% The Db a copy builds from the CIM's current samples (sampling first if they are stale).
    cp = copy(c); cp.SampleData.compute(); cp.computeDataMatrices(); Db = cp.ResultData.Db;
end

function sd = sampledLike(c, rho)
% A sampled SampleData with c's operator, directions and a contour of radius rho.
    sd = Numerics.SampleData(c.SampleData.OperatorData, Numerics.Contour.Circle(-4, rho, 64));
    sd.show_progress = false; sd.L = c.SampleData.L; sd.R = c.SampleData.R; sd.compute();
end

function rd = loadedRealization(c)
% The loaded RealizationData of another computed SPLoewner CIM.
    quietCIM(c); c.setComputationalMode(Numerics.ComputationalMode.SPLoewner); c.RealizationData.K = 2;
    c.RealizationData.m = size(c.SampleData.OperatorData.T(0), 1); c.compute(); rd = copy(c.RealizationData);
end
