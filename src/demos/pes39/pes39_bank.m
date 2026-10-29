function bank = pes39_bank(Tf, opts)
% A wall of CIM disks |z - i c_k| < rho for the delay model Tf of
% pes39_model.m. Returns a function, [ew, res, trusted] = bank(tau), that gives
% the eigenvalues of Tf(tau) the disks find inside their contours, their
% relative residuals, and whether each residual is below ResTol. An eigenvalue
% found by two overlapping disks is kept once, with the smaller residual.
%
% The base wall has radius 1 and centres 3i, ..., 12i, so each circle passes
% through its neighbours' centres. Mode, Probes (ell = r) and K select the
% realization. All disks share one operator and one pair of probing matrices,
% drawn after rng(Seed), so bank(tau) is a deterministic function of tau.
% In both sweeps the trusted residuals stay below 1e-10 and the others above
% 1e-6, on either side of ResTol = 1e-8.
% --8<-- [start:bank]
arguments
    Tf
    opts.Centers (1,:) double = 3:12
    opts.Radius (1,1) double = 1
    opts.Nodes (1,1) double = 128
    opts.Mode (1,1) Numerics.ComputationalMode = Numerics.ComputationalMode.MPLoewner
    opts.Probes (1,1) double = 5
    opts.K (1,1) double = 50
    opts.Seed (1,1) double = 0
    opts.ResTol (1,1) double = 1e-8
    opts.EmptyTol (1,1) double = 1e-5     % moment level: occupied disks >= 2.5e-3, leakage only <= 1.1e-6
end
% One CIM per disk, all sharing the operator op and the probes L and R. Setting
% op.T resamples every disk; the probes and interpolation points stay. AutoRank
% reads a disk whose moment level is below EmptyTol as empty, and otherwise
% realizes at the largest singular-value gap of its data matrix.
op = Numerics.OperatorData(Tf(zeros(10,1)));
rng(opts.Seed);
L = randn(op.n, opts.Probes);  R = randn(op.n, opts.Probes);
cims = cell(size(opts.Centers));
for k = 1:numel(opts.Centers)
    c = Numerics.Contour.Circle(1i*opts.Centers(k), opts.Radius, opts.Nodes);
    cim = Numerics.CIM(op, c);
    cim.SampleData.L = L;  cim.SampleData.R = R;
    cim.setComputationalMode(opts.Mode, Numerics.RealizationSize(0, opts.K));
    cim.RealizationData.AutoRank = true;
    cim.options.EmptyTol = opts.EmptyTol;  cim.options.Verbose = false;
    cims{k} = cim;
end
% --8<-- [end:bank]
bank = @(tau) eigenvalues(op, cims, Tf(tau), opts.ResTol);
end

% --8<-- [start:trust]
function [ew, res, trusted] = eigenvalues(op, cims, T, restol)
% Every eigenvalue a disk finds inside its contour, with its relative residual
% ||T(z)v|| / ||T(z)||_F.
op.T = T;
ew = zeros(0,1);  res = zeros(0,1);
for k = 1:numel(cims)
    [V, D] = cims{k}.eigs();  z = diag(D);
    in = cims{k}.SampleData.Contour.inside(z);
    ew  = [ew; z(in)];
    res = [res; Numerics.relres(T, z(in), V(:,in), op.sample_mode)];
end
% Overlapping disks find some eigenvalues twice; the copy with the smaller
% residual is kept.
[res, i] = sort(res);  ew = ew(i);
keep = true(size(ew));
for j = 2:numel(ew)
    keep(j) = all(abs(ew(j) - ew(keep(1:j-1))) > 1e-6*max(1, abs(ew(j))));
end
ew = ew(keep);  res = res(keep);
trusted = res < restol;
end
% --8<-- [end:trust]
