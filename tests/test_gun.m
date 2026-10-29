%% Test the sparse sampler on the NLEVP gun problem (n=9956, transcendental)
% A trimmed version of src/demos/gun/gun_nlevp.m sized for a regression suite:
% one small contour around the gun problem's first eigenvalue in the canonical
% target region, lambda = 22345.1168 + 0.6450i (validated in the full demo
% against the NLEIGS/CORK literature count and by Newton refinement).
% Exercises the sparse path end-to-end: T(z) stays sparse, samples come from
% sparse factorisations (~64 of them; a dense n x n x K sample array would be
% ~100 GB). Runtime ~1-2 min.
%
% SKIPS (passes vacuously) if the NLEVP collection is not on the path; see
% https://github.com/ftisseur/nlevp

clear; close all;
addpath(genpath('../src'));
nlevpdir = fullfile(getenv('HOME'), 'MATLAB Add-Ons', 'Collections', 'NLEVP');
if exist(nlevpdir, 'dir'), addpath(genpath(nlevpdir)); end
if exist('nlevp', 'file') ~= 2
    fprintf('SKIP: NLEVP collection not found on path -- test_gun not run\n');
    return
end
import Visual.*

fprintf('Test: gun, sparse sampling around the first target-region eigenvalue\n');
[coeffs, ~] = nlevp('gun');
gam2 = 108.8774^2;
T  = @(s) coeffs{1} - s*coeffs{2} + 1i*sqrt(s)*coeffs{3} + 1i*sqrt(s - gam2)*coeffs{4};
Tp = @(s) -coeffs{2} + (0.5i/sqrt(s))*coeffs{3} + (0.5i/sqrt(s - gam2))*coeffs{4};
assert(issparse(coeffs{1}) && issparse(T(3e4 + 1i)), 'gun operator should be sparse');

ref = 22345.1168 + 0.6450i;     % from the full demo run (Newton-confirmed to 1.2e-9)

c   = Contour.Circle(2.2e4, 2e3, 128);   % encloses ref only; disk stays right of
cim = CIM(OperatorData(T), c);            % the branch point at 11854.7
cim.auto_update_shifts = true;
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
cim.RealizationData.K = 64;  cim.SampleData.ell = 8;  cim.SampleData.r = 8;
cim.compute();

s = svd(full(cim.ResultData.Db));  s = s/s(1);
m = find(s > 1e-8, 1, 'last');
cim.RealizationData.m = max(m, 1);
[V, Lam] = cim.eigs();  ew = diag(Lam);
in = abs(ew - 2.2e4) < 2e3;  ew = ew(in);  V = V(:,in);

assert(numel(ew) == 1, 'expected exactly 1 eigenvalue inside, got %d', numel(ew));
res = Numerics.relres(T, ew, V, cim.SampleData.OperatorData.sample_mode);
assert(max(res) < 1e-8, 'relres %.1e >= 1e-8', max(res));
assert(abs(ew - ref) < 1e-3, 'dist to reference %.1e >= 1e-3', abs(ew - ref));

% independent confirmation: Newton on the true operator barely moves it
lam = ew; v = V(:,1)/norm(V(:,1));
ws = warning('off', 'MATLAB:nearlySingularMatrix');
for it = 1:3
    u = T(lam) \ (Tp(lam)*v);
    lam = lam - (v'*v)/(v'*u);
    v = u/norm(u);
end
warning(ws);
assert(abs(lam - ew)/abs(ew) < 1e-6, 'Newton correction %.1e >= 1e-6', abs(lam - ew)/abs(ew));

fprintf('  eigenvalue %.4f%+.4fi, relres %.1e, Newton correction %.1e\n', ...
    real(ew), imag(ew), max(res), abs(lam - ew)/abs(ew));
fprintf('test_gun: all tests passed\n');
