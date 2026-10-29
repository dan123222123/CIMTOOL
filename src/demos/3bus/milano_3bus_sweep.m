%% Eigenvalues of the three-bus system as the PSS delay grows
%
% Milano, Eigenvalue Problems in Power Systems (2020), Example 11.1.
% One MPLoewner CIM on the circle |z - (-0.5 + 4i)| = 2.6 gives the eigenvalues
% inside it, with their relative residuals, at 201 delays from 0 to 250 ms.
% Eigenvalues with relative residual below 1e-8 are trusted. The delay margin,
% the smallest delay at which the rightmost trusted eigenvalue reaches the
% imaginary axis, is bracketed by the grid and refined by fzero. Writes
% sweep.csv (every eigenvalue at every delay) and margin.csv.

here = fileparts(mfilename('fullpath'));
milano_3bus_ex11_1;

% --8<-- [start:cim]
rng(0);   % the probing directions are drawn once and kept for every delay
c   = Numerics.Contour.Circle(-0.5 + 4i, 2.6, 256);
cim = Numerics.CIM(Numerics.OperatorData(@(s) T(s, 0)), c);
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner, Numerics.RealizationSize(0, 50));
cim.SampleData.L = randn(n, 5);  cim.SampleData.R = randn(n, 5);
cim.RealizationData.AutoRank = true;   % m from the largest singular-value gap of the Loewner matrix
% --8<-- [end:cim]

% --8<-- [start:sweep]
tau = linspace(0, 0.25, 201);  sweep = cell(size(tau));
for i = 1:numel(tau)
    sweep{i} = disk_eigs(cim, @(s) T(s, tau(i)));
end

% the first sign change of the abscissa of the trusted eigenvalues on the grid,
% refined by fzero; a disk without trusted eigenvalues reads as stable
tol = 1e-8;   % an eigenvalue with relative residual below tol is trusted
abscissa = @(E) max([real(E.z(E.relres < tol)); -1]);
i  = find(cellfun(abscissa, sweep) > 0, 1);
tc = fzero(@(t) abscissa(disk_eigs(cim, @(s) T(s, t))), tau([i-1 i]));
Ec = disk_eigs(cim, @(s) T(s, tc));  Ec = Ec(Ec.relres < tol, :);
[~, j] = max(real(Ec.z));  zc = Ec.z(j);
% --8<-- [end:sweep]

S = vertcat(sweep{:});  ts = repelem(tau, cellfun(@height, sweep));
writetable(table(1e3*ts(:), real(S.z), imag(S.z), S.relres, 'VariableNames', {'tau_ms', 're', 'im', 'relres'}), fullfile(here, 'sweep.csv'));
writetable(table(1e3*tc, real(zc), imag(zc), 'VariableNames', {'margin_ms', 're', 'im'}), fullfile(here, 'margin.csv'));
fprintf('delay margin %.2f ms, crossing %+.5f%+.5fi\n', 1e3*tc, real(zc), imag(zc));
fprintf('%d of %d eigenvalues trusted, largest relative residual %.1e\n', nnz(S.relres < tol), height(S), max(S.relres));

% --8<-- [start:disk_eigs]
function E = disk_eigs(cim, Ttau)
% the eigenvalues z of Ttau inside the contour and their relative residuals
op = cim.SampleData.OperatorData;
op.T = Ttau;   % new samples; the probes and shifts are kept
[V, Lam] = cim.eigs();  z = diag(Lam);
in = cim.SampleData.Contour.inside(z);
E = table(z(in), Numerics.relres(Ttau, z(in), V(:,in), op.sample_mode), 'VariableNames', {'z', 'relres'});
end
% --8<-- [end:disk_eigs]
