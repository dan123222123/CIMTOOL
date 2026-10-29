%% The NLEVP "gun" problem: Hankel, single-point and multipoint Loewner
%
% The gun problem (Betcke, Higham, Mehrmann, Schroder, Tisseur; NLEVP
% collection) models a radio-frequency gun cavity:
%
%   T(lambda) = K - lambda*M + i*sqrt(lambda)*W1 + i*sqrt(lambda - sigma2^2)*W2,
%
% with K, M, W1, W2 sparse 9956x9956 and sigma2 = 108.8774.
% Compares the three methods on the disk |lambda - 141000| < 30000, which
% holds 17 eigenvalues, on trapezoid rules of N = 16, 32, ..., 1024 nodes;
% inspired by Fig. 7 of Brennan, Embree & Gugercin (SIAM Rev. 65(2), 2023).
%
% Writes, next to this script, the CSVs that gun_figures.m plots:
%   gun_residuals.csv        maximum relative residual against N
%   gun_singular_values.csv  sigma_k(Db)/sigma_1 at every N
%   gun_points.csv           the multipoint Loewner points of each case, padded
%                            with NaN, and the single-point Loewner point
%   gun_eigenvalues.csv      the eigenvalues inside the contour, multipoint
%                            Loewner at (K, r) = (8, 4) and N = 1024

assert(exist('nlevp', 'file') == 2, ...
    'gun_nlevp: the NLEVP collection must be on the path (need nlevp.m).');

% --8<-- [start:setup]
op = Numerics.OperatorData([], 'gun');
n = op.n;

ctr = 141000;  rho = 30000;  M = 17;
N0 = 16;  nlev = 7;
CASES = [2 16; 4 8; 8 4];
sigma_sp = ctr - 40000i;
rho_mp = 40000;
P = max(CASES(:, 2));

cim = Numerics.CIM(op, Numerics.Contour.Circle(ctr, rho, N0));
cim.auto_update_shifts = false;
cim.options.Verbose = false;
cim.options.AbsTol = 0; % realize M even where Db has lower numerical rank

% P fixed probing directions on each side, shared by every case and method.
rng(42);
L = (randn(n, 32) + 1i*randn(n, 32))/sqrt(2);
R = (randn(n, 32) + 1i*randn(n, 32))/sqrt(2);
sd = cim.SampleData;
sd.L = L(:, 1:P);  sd.R = R(:, 1:P);
% --8<-- [end:setup]
fprintf('gun: n=%d, circle centre %g radius %g, N = %d refined %d times, M = %d\n', n, ctr, rho, N0, nlev - 1, M);

% --8<-- [start:points]
% Multipoint Loewner points of each case: K right points on the circle of radius
% rho_mp, the first at ctr + i*rho_mp, and K left points midway between them.
ncase = size(CASES, 1);
theta = cell(ncase, 1);  sigma = cell(ncase, 1);
for c = 1:ncase
    K = CASES(c, 1);
    [theta{c}, sigma{c}] = sd.Contour.interlevedshifts(K, rho_mp/rho, 'scale', 'trap', pi/2 - pi/K);
end
% --8<-- [end:points]

% --8<-- [start:refine]
% Sample once on N0 nodes, then double N, sampling only at the new nodes, and
% realize every case and method at each N. Refinement keeps the leading ell and
% r directions only, hence ell = r = P before it.
NS = nan(1, nlev);  res = nan(nlev, 3, ncase);  sv = nan(32, nlev, 3, ncase);
tic;
sd.compute();
for lev = 1:nlev
    if lev > 1
        sd.ell = P;  sd.r = P;
        sd.refineQuadrature();
    end
    NS(lev) = sd.Contour.N;
    for c = 1:ncase
        [res(lev, :, c), sv(:, lev, :, c)] = realize_methods(cim, M, CASES(c, 1), CASES(c, 2), sigma_sp, theta{c}, sigma{c});
    end
    fprintf('N = %4d realized, %.0f s\n', NS(lev), toc);
end
% --8<-- [end:refine]

% The last realization is multipoint Loewner at (8, 4) on N = 1024.
ew = cim.ResultData.ew;  inside = sd.Contour.inside(ew);
ew = ew(inside);  V = cim.ResultData.rev(:, inside);
relres = Numerics.relres(op.T, ew, V, op.sample_mode);
[~, ord] = sort(real(ew));  ew = ew(ord);  relres = relres(ord);

meth = ["hankel", "sploewner", "mploewner"];
tag = "K" + CASES(:, 1)' + "r" + CASES(:, 2)';
for c = 1:ncase
    fprintf('\n(K, r) = (%d, %d): maximum relative residual\n', CASES(c, :));
    disp(array2table([NS(:), res(:, :, c)], 'VariableNames', ["N", meth]));
end
fprintf('%d eigenvalues inside the contour (BEG: 17), max relres %.1e\n', numel(ew), max(relres));

here = fileparts(mfilename('fullpath'));
cols = meth' + "_" + tag;
writetable(array2table([NS(:), res(:, :)], 'VariableNames', ["N", cols(:)']), fullfile(here, 'gun_residuals.csv'));
svcols = (cols(:) + "_N" + NS)';
writetable(array2table([(1:32)', reshape(sv, 32, [])], 'VariableNames', ["k", svcols(:)']), ...
    fullfile(here, 'gun_singular_values.csv'));
pts = nan(max(CASES(:, 1)), 4*ncase + 2);
for c = 1:ncase
    pts(1:CASES(c, 1), 4*c-3:4*c) = [real(theta{c}), imag(theta{c}), real(sigma{c}), imag(sigma{c})];
end
pts(1, end-1:end) = [real(sigma_sp), imag(sigma_sp)];
names = ["theta_re"; "theta_im"; "sigma_re"; "sigma_im"] + "_K" + CASES(:, 1)';
writetable(array2table(pts, 'VariableNames', [names(:)', "sp_re", "sp_im"]), fullfile(here, 'gun_points.csv'));
writetable(table(real(ew), imag(ew), relres(:), 'VariableNames', {'re', 'im', 'relres'}), ...
    fullfile(here, 'gun_eigenvalues.csv'));

% --8<-- [start:realize]
function [res, sv] = realize_methods(cim, M, K, p, sigma_sp, theta, sigma)
% Realizes M eigenvalues from the leading p probing directions by Hankel with K
% moments, single-point Loewner with K moments at sigma_sp, and multipoint
% Loewner with the K left points theta and K right points sigma, each point
% taking all p directions. Returns, for each method, the maximum relative
% residual and sigma_k(Db)/sigma_1.
    cim.SampleData.ell = p;  cim.SampleData.r = p;
    modes = [Numerics.ComputationalMode.Hankel, Numerics.ComputationalMode.SPLoewner, Numerics.ComputationalMode.MPLoewner];
    sizes = [K, K, K*p];
    points = [Numerics.InterpolationData(NaN, Inf), Numerics.InterpolationData(NaN, sigma_sp), ...
        Numerics.InterpolationData(repelem(theta, p), repelem(sigma, p))];
    for j = 1:3
        cim.setComputationalMode(modes(j), Numerics.RealizationSize(M, sizes(j), sizes(j)));
        cim.RealizationData.InterpolationData = points(j);
        cim.computeRealization();
        res(j) = cim.maxrelresidual();
        s = diag(cim.ResultData.Sigma);  sv(:, j) = s/s(1);
    end
end
% --8<-- [end:realize]
