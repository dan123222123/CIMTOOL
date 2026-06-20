% Unit tests for the Numerics.Contour.* classes and quadrature refinement.
%
% Covers three things that previously had no coverage and that broke before:
%   1. inside() truth tables for every contour type, including non-semicircle
%      and branch-cut-crossing circular segments (regression for the
%      CircularSegment.inside geometry bug).
%   2. Quadrature refinement nesting: Circle/Ellipse and Clenshaw-Curtis
%      circular segments must reuse old samples so the refined samples equal a
%      fresh full sampling (segments nest N -> 2N-1 per piece); a Gauss segment
%      does not nest and must leave samples unloaded for a full resample.
%   3. Cross-mode transfer-function sign consistency: Hankel / SPLoewner /
%      MPLoewner must all reconstruct +H (regression for the SPLoewner sign
%      flip).
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);
tol = 1e-12;

%% inside() -- Circle
c = Numerics.Contour.Circle(0, 1, 16);
assert(c.inside(0),        "circle: center should be inside");
assert(c.inside(0.99),     "circle: 0.99 should be inside");
assert(~c.inside(1.01),    "circle: 1.01 should be outside");
assert(~c.inside(2i),      "circle: 2i should be outside");
% off-origin center
c2 = Numerics.Contour.Circle(2+1i, 0.5, 16);
assert(c2.inside(2+1i),    "circle(off): center inside");
assert(~c2.inside(0),      "circle(off): origin outside");
fprintf("inside/Circle: PASS\n");

%% inside() -- Ellipse
e = Numerics.Contour.Ellipse(0, 2, 1, 16); % wide ellipse
assert(e.inside(0),        "ellipse: center inside");
assert(e.inside(1.9),      "ellipse: 1.9 on major axis inside");
assert(~e.inside(2.1),     "ellipse: 2.1 on major axis outside");
assert(e.inside(0.9i),     "ellipse: 0.9i on minor axis inside");
assert(~e.inside(1.1i),    "ellipse: 1.1i on minor axis outside");
fprintf("inside/Ellipse: PASS\n");

%% inside() -- CircularSegment, minor segment (right of a near-vertical chord)
% rho=1, theta=[-pi/4,pi/4]: region is the disk cap with real part > cos(pi/4)
cs = Numerics.Contour.CircularSegment(0, 1, [-pi/4, pi/4], [16;16]);
assert(cs.inside(0.9),     "segment(minor): 0.9 inside the cap");
assert(~cs.inside(0.1),    "segment(minor): 0.1 left of chord -> outside");
assert(~cs.inside(1.1),    "segment(minor): 1.1 beyond arc -> outside");
assert(~cs.inside(0.8i),   "segment(minor): 0.8i above the cap -> outside");
fprintf("inside/CircularSegment minor: PASS\n");

%% inside() -- CircularSegment, major segment crossing the +/-pi branch cut
% theta=[pi/2,3*pi/2]: left half-disk (this is where the old angle() test broke)
csM = Numerics.Contour.CircularSegment(0, 1, [pi/2, 3*pi/2], [16;16]);
assert(csM.inside(-0.5),   "segment(major): -0.5 inside left half-disk");
assert(~csM.inside(0.5),   "segment(major): 0.5 in right half -> outside");
assert(~csM.inside(-1.1),  "segment(major): -1.1 beyond arc -> outside");
assert(csM.inside(-0.3 - 0.3i), "segment(major): off-axis point in left half-disk inside");
fprintf("inside/CircularSegment major (branch-cut): PASS\n");

%% inside() -- CircularSegment in every orientation (validation must allow all)
% The disk-cap-on-the-arc-side geometry must be correct whichever way the segment
% opens, and the constructor must accept any ascending [theta1,theta2] with span
% <= 2*pi: left/right/top/bottom half-disks plus a narrow off-axis cap.
oris = struct( ...
    'name',  {'right',       'left',         'top',     'bottom',     'branchcut'}, ...
    'theta', {[-pi/2,pi/2],  [pi/2,3*pi/2],  [0,pi],    [pi,2*pi],    [3*pi/4,5*pi/4]}, ...
    'in',    {0.6,           -0.6,           0.6i,      -0.6i,        -0.85}, ...
    'out',   {-0.6,          0.6,            -0.6i,     0.6i,         -0.5});
for k = 1:numel(oris)
    o = oris(k);
    s = Numerics.Contour.CircularSegment(0, 1, o.theta, [32;32]);  % must construct (validation OK)
    assert(s.inside(o.in),   "segment(%s): interior cap point should be inside", o.name);
    assert(~s.inside(o.out), "segment(%s): opposite-side point should be outside", o.name);
    assert(~s.inside(1.5*exp(1i*mean(o.theta))), "segment(%s): point beyond the arc should be outside", o.name);
end
fprintf("inside/CircularSegment all orientations: PASS\n");

%% inside() -- Quad base class (bounding disk of the nodes)
q = Numerics.Contour.Quad([1, 1i, -1, -1i], [1 1 1 1]);
assert(q.inside(0),        "quad: center inside bounding disk");
assert(~q.inside(2),       "quad: 2 outside bounding disk");
fprintf("inside/Quad: PASS\n");

%% Operator for the sampling-based tests
n = 4; A = diag(-(1:n)); B = eye(n); C = eye(n);
H = @(z) C*((z*eye(n) - A) \ B);
op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct;

%% Refinement nesting -- Circle: refined samples == fresh samples at 2N
N0 = 8;
ct = Numerics.Contour.Circle(-2.5, 3, N0);
sd = Numerics.SampleData(op, ct); sd.show_progress = false;
sd.L = eye(n); sd.R = eye(n);
sd.compute();
sd.refineQuadrature();              % -> 2*N0 nodes, reusing the first N0 samples
assert(sd.loaded, "circle refine: samples should be loaded after nesting");
assert(numel(sd.Contour.z) == 2*N0, "circle refine: node count should double");
% fresh sampling at the doubled resolution
ctf = Numerics.Contour.Circle(-2.5, 3, 2*N0);
sdf = Numerics.SampleData(op, ctf); sdf.show_progress = false;
sdf.L = eye(n); sdf.R = eye(n);
sdf.compute();
assert(norm(sd.Qlr(:) - sdf.Qlr(:)) < tol, ...
    "circle refine: nested samples must match a fresh full sampling");
fprintf("refine nesting/Circle: PASS\n");

%% Refinement nesting -- Ellipse
cte = Numerics.Contour.Ellipse(-2.5, 3, 1.5, N0);
sde = Numerics.SampleData(op, cte); sde.show_progress = false;
sde.L = eye(n); sde.R = eye(n);
sde.compute();
sde.refineQuadrature();
assert(sde.loaded && numel(sde.Contour.z) == 2*N0, "ellipse refine: loaded + doubled");
ctef = Numerics.Contour.Ellipse(-2.5, 3, 1.5, 2*N0);
sdef = Numerics.SampleData(op, ctef); sdef.show_progress = false;
sdef.L = eye(n); sdef.R = eye(n);
sdef.compute();
assert(norm(sde.Qlr(:) - sdef.Qlr(:)) < tol, ...
    "ellipse refine: nested samples must match a fresh full sampling");
fprintf("refine nesting/Ellipse: PASS\n");

%% Refinement nesting -- CircularSegment (Clenshaw-Curtis): refined samples ==
%  fresh full sampling at the refined resolution. CC nodes nest, so each
%  boundary piece goes N -> 2N-1 and the old samples are reused exactly.
Nseg = [8;8];
ctcs = Numerics.Contour.CircularSegment(-2.5, 3, [-pi/2, pi/2], Nseg, "clencurt");
sdcs = Numerics.SampleData(op, ctcs); sdcs.show_progress = false;
sdcs.L = eye(n); sdcs.R = eye(n);
sdcs.compute();
sdcs.refineQuadrature();                          % nested reuse: only the new nodes are sampled
Nref = 2*Nseg - 1;                                % CC nesting: N -> 2N-1 per piece
assert(sdcs.loaded, "segment refine: samples should be loaded after nesting");
assert(isequal(sdcs.Contour.N(:), Nref(:)), "segment refine: node counts should be 2N-1 per piece");
assert(numel(sdcs.Contour.z) == sum(Nref), "segment refine: total node count should be sum(2N-1)");
% fresh full sampling at the refined resolution
ctcsf = Numerics.Contour.CircularSegment(-2.5, 3, [-pi/2, pi/2], Nref, "clencurt");
sdcsf = Numerics.SampleData(op, ctcsf); sdcsf.show_progress = false;
sdcsf.L = eye(n); sdcsf.R = eye(n);
sdcsf.compute();
assert(norm(sdcs.Qlr(:) - sdcsf.Qlr(:)) < tol, ...
    "segment refine: nested samples must match a fresh full sampling");
fprintf("refine nesting/CircularSegment: PASS\n");

%% A Gauss circular segment does NOT nest: refine must leave samples unloaded so
%  the next compute() resamples fully (rather than reusing onto wrong nodes).
Ng = [8;8];
ctg2 = Numerics.Contour.CircularSegment(-2.5, 3, [-pi/2, pi/2], Ng, "gauss");
sdg2 = Numerics.SampleData(op, ctg2); sdg2.show_progress = false;
sdg2.L = eye(n); sdg2.R = eye(n);
sdg2.compute();
ws = warning('off', 'all');                       % silence the expected "does not reuse" warning
sdg2.refineQuadrature();
warning(ws);
assert(~sdg2.loaded, "gauss segment refine: must leave samples unloaded (no nesting)");
assert(isequal(sdg2.Contour.N(:), 2*Ng(:)), "gauss segment refine: node counts should double");
sdg2.compute();                                   % full resample at the new resolution
fprintf("refine non-nesting/gauss segment: PASS\n");

%% Cross-mode transfer-function sign consistency (pins the SPLoewner sign fix)
Bm = randn(n, n); Cm = randn(n, n);
Hm = @(z) Cm*((z*eye(n) - A) \ Bm);
opm = Numerics.OperatorData(Hm); opm.sample_mode = Numerics.SampleMode.Direct;
opm.refew = -(1:n);
ctm = Numerics.Contour.Circle(-2.5, 3, 128);     % encloses all four poles
cim = Numerics.CIM(opm, ctm); cim.SampleData.show_progress = false;
cim.SampleData.ell = n; cim.SampleData.r = n;
cim.RealizationData.K = 1; cim.RealizationData.m = n;
z0 = -2.5 + 0.5i; Hz0 = Hm(z0);
modes = [Numerics.ComputationalMode.Hankel, ...
         Numerics.ComputationalMode.SPLoewner, ...
         Numerics.ComputationalMode.MPLoewner];
for md = modes
    cim.setComputationalMode(md); cim.compute();
    Hr = cim.tf(); relerr = norm(Hr(z0) - Hz0) / norm(Hz0);
    fprintf("  tf %-10s relerr = %.2e\n", string(md), relerr);
    assert(relerr < 1e-6, "tf sign/accuracy mismatch in %s mode (relerr %.2e)", string(md), relerr);
end
fprintf("cross-mode tf consistency: PASS\n");

%% SPLoewner shift stays outside a contour that grows over it (update_shifts fix)
ctg = Numerics.Contour.Circle(0, 0.5, 32);
cg = Numerics.CIM(opm, ctg); cg.SampleData.show_progress = false;
cg.SampleData.ell = n; cg.SampleData.r = n;
cg.setComputationalMode(Numerics.ComputationalMode.SPLoewner);
cg.RealizationData.m = n; cg.RealizationData.K = 1;
sig0 = cg.RealizationData.InterpolationData.sigma(1);
assert(~ctg.inside(sig0), "SPLoewner: initial shift should be outside the contour");
ctg.rho = 5;   % grow the contour so it would swallow a stale shift
sig1 = cg.RealizationData.InterpolationData.sigma(1);
assert(~ctg.inside(sig1), "SPLoewner: shift must be relocated outside the grown contour");
fprintf("SPLoewner shift relocation: PASS\n");

%% MPLoewner interpolation points stay OUTSIDE a circular segment, any orientation
% The chord shifts are offset along the chord's outward normal, so they must
% clear the contour for every orientation, span, quadrature rule and shift mode
% (a purely horizontal offset would let some points fall inside a non-right-
% facing segment -- e.g. the top-facing semicircle).
for rule = ["clencurt","gauss"]
    for sp = deg2rad([45 90 180 270])
        for mid = deg2rad(0:30:330)
            seg = Numerics.Contour.CircularSegment(-0.3+0.2i, 0.6, [mid-sp/2, mid+sp/2], [16;16], rule);
            [th, sg] = seg.interlevedshifts(6, 1.25, 'scale');
            assert(~any(seg.inside([th(:); sg(:)])), ...
                "segment shifts (%s): interpolation point inside contour (span=%g, mid=%g)", ...
                rule, rad2deg(sp), rad2deg(mid));
        end
    end
end
fprintf("MPLoewner segment shifts stay outside: PASS\n");

%%
fprintf("\nAll contour tests passed!\n");
