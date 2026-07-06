% Unit tests for contour QUADRATURE correctness: the nodes (z) and weights (w)
% produced by every Numerics.Contour.* type must reproduce contour integrals to
% high accuracy. The weights carry the 1/(2*pi*i) factor, so for a positively
% oriented contour enclosing a region Omega:
%
%       sum_k w_k * g(z_k)   ~~   (1/2*pi*i) * oint_{dOmega} g(z) dz
%
% This pins the foundational object the whole realization pipeline rests on: the
% moment integrals in build_quadrature_moments / build_quadrature_data are
% exactly these weighted sums. The previous suite checked contour geometry
% (test_contours.m: inside(), refinement nesting) but never the integration
% weights themselves. A regression in a parametrization derivative or the
% 1/(2*pi*i) scaling would slip through everything until eigenvalues silently
% drifted.
%
% Invariants checked, for Circle / Ellipse / CircularSegment:
%   1. Winding number / residue:  (1/2pi i) oint dz/(z-z0) = #poles of 1/(z-z0)
%                                 enclosed  (1 inside, 0 outside).
%   2. Cauchy integral formula:   (1/2pi i) oint f(z)/(z-z0) dz = f(z0).
%   3. Cauchy-Goursat:            (1/2pi i) oint p(z) dz = 0   (p analytic).
%   4. Cauchy derivative formula: (1/2pi i) oint f(z)/(z-z0)^2 dz = f'(z0).
%   5. Closed-contour weight sum: sum_k w_k = 0  (= integral of the constant 1).
%   6. Multi-/partial-enclosure residue sums (the latter exercises the
%      CircularSegment cap selecting only the poles it actually encloses).
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);
tol  = 1e-11;   % Circle/Ellipse trapezoid: spectral, ~machine precision
tolS = 1e-9;    % CircularSegment (Clenshaw-Curtis on two smooth pieces): a hair looser

% analytic test functions (entire, so valid inside any contour)
f  = @(z) exp(z) + 2*z + 3;     % f
df = @(z) exp(z) + 2;           % f'

% weighted quadrature sum against the contour's own nodes/weights
oint = @(c, g) sum(c.w(:) .* g(c.z(:)));

%% Circle -- residue, Cauchy, Goursat, derivative, weight sum
c = Numerics.Contour.Circle(0, 1, 32);
assert(abs(oint(c, @(z) 1./(z - 0.0))   - 1) < tol, "circle: winding at center should be 1");
assert(abs(oint(c, @(z) 1./(z - 0.4i))  - 1) < tol, "circle: winding at off-center interior point should be 1");
assert(abs(oint(c, @(z) 1./(z - 5.0))      ) < tol, "circle: winding at exterior point should be 0");
assert(abs(oint(c, @(z) f(z)./(z - 0.3)) - f(0.3))  < tol, "circle: Cauchy integral formula");
assert(abs(oint(c, @(z) z.^2)              ) < tol, "circle: integral of an analytic function should be 0");
assert(abs(oint(c, @(z) f(z)./(z - 0.2).^2) - df(0.2)) < tol, "circle: Cauchy derivative formula");
assert(abs(sum(c.w))                       < tol, "circle: closed-contour weights must sum to 0");
% two interior poles -> integral counts both residues
assert(abs(oint(c, @(z) 1./(z-0.3) + 1./(z+0.2i)) - 2) < tol, "circle: two enclosed poles -> 2");
% off-origin circle: only the enclosed pole contributes
c2 = Numerics.Contour.Circle(2+1i, 0.5, 32);
assert(abs(oint(c2, @(z) 1./(z-(2+1i))) - 1) < tol, "circle(off): enclosed pole counts");
assert(abs(oint(c2, @(z) 1./(z-0.0))       ) < tol, "circle(off): far pole does not count");
fprintf("quadrature/Circle: PASS\n");

%% Ellipse -- residue, Cauchy, Goursat, derivative, weight sum
e = Numerics.Contour.Ellipse(0, 2, 1, 64);   % wide ellipse
assert(abs(oint(e, @(z) 1./(z - 0.0))  - 1) < tol, "ellipse: winding at center should be 1");
assert(abs(oint(e, @(z) 1./(z - 1.5))  - 1) < tol, "ellipse: winding at interior point on major axis should be 1");
assert(abs(oint(e, @(z) 1./(z - 5.0))     ) < tol, "ellipse: winding at exterior point should be 0");
assert(abs(oint(e, @(z) 1./(z - 2.5i))    ) < tol, "ellipse: point beyond the minor axis is exterior -> 0");
assert(abs(oint(e, @(z) f(z)./(z - 0.3)) - f(0.3))  < tol, "ellipse: Cauchy integral formula");
assert(abs(oint(e, @(z) z.^2)             ) < tol, "ellipse: integral of an analytic function should be 0");
assert(abs(oint(e, @(z) f(z)./(z - 0.2).^2) - df(0.2)) < tol, "ellipse: Cauchy derivative formula");
assert(abs(sum(e.w))                      < tol, "ellipse: closed-contour weights must sum to 0");
fprintf("quadrature/Ellipse: PASS\n");

%% CircularSegment -- residue, Cauchy, weight sum, partial enclosure
% Right cap of the unit disk: boundary = arc(-pi/2..pi/2) + chord on the imag axis.
% Interior = {|z|<1, Re z>0}.
s = Numerics.Contour.CircularSegment(0, 1, [-pi/2, pi/2], [64; 64]);
assert(numel(s.z) == sum(s.N), "segment: node count should be sum(N) (arc + chord)");
zin = 0.6; zout = -0.5;        % zin inside the cap, zout in the (excluded) left half-disk
assert( s.inside(zin),  "segment: probe point %.2f should be inside the cap", zin);
assert(~s.inside(zout), "segment: probe point %.2f should be outside the cap", zout);
assert(abs(oint(s, @(z) 1./(z - zin))  - 1) < tolS, "segment: winding at interior point should be 1");
assert(abs(oint(s, @(z) 1./(z - zout))    ) < tolS, "segment: winding at exterior point should be 0");
assert(abs(oint(s, @(z) f(z)./(z - zin)) - f(zin))  < tolS, "segment: Cauchy integral formula");
assert(abs(sum(s.w))                      < tolS, "segment: closed-contour weights must sum to 0");
% partial enclosure: only the pole inside the cap contributes its residue.
% g(z) = 1/((z-a)(z-b)), a=zin inside, b=zout outside -> oint g = res_a = 1/(a-b).
a = zin; b = zout;
assert(abs(oint(s, @(z) 1./((z-a).*(z-b))) - 1/(a-b)) < tolS, ...
    "segment: partial enclosure must pick up only the residue at the enclosed pole");
fprintf("quadrature/CircularSegment: PASS\n");

%% CircularSegment quadrature stays correct & positively oriented in every orientation
% (a left/top/bottom cap whose arc+chord ordering flipped would give winding -1)
for mid = [0, pi, pi/2, 3*pi/2]                 % right / left / top / bottom half-disk caps
    so = Numerics.Contour.CircularSegment(0, 1, mid + [-pi/2, pi/2], [64;64]);
    zi = 0.5*exp(1i*mid); zo = -0.5*exp(1i*mid);
    assert(abs(oint(so, @(z) 1./(z - zi)) - 1) < tolS, ...
        "segment(mid=%.2f): winding at interior point should be +1 (orientation)", mid);
    assert(abs(oint(so, @(z) 1./(z - zo)))     < tolS, ...
        "segment(mid=%.2f): winding at opposite point should be 0", mid);
end
fprintf("quadrature/CircularSegment orientations: PASS\n");

%% Orientation: all contour types are positively (counter-clockwise) oriented
% (a negatively oriented contour would give winding number -1 at an interior point)
for cc = {c, e, s}
    ctr = sum(cc{1}.z)/numel(cc{1}.z);
    wnd = oint(cc{1}, @(z) 1./(z - ctr));
    assert(real(wnd) > 0.5, "%s: contour must be positively oriented (winding ~ +1, got %.3f)", ...
        class(cc{1}), real(wnd));
end
fprintf("quadrature/orientation: PASS\n");

%%
fprintf("\nAll quadrature tests passed!\n");
