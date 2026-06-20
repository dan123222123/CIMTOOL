% example2_crossmode_tf.m
% -------------------------------------------------------------------------
% WHAT CHANGED (PROGRESS.md sec 1, bug B2):
%   SPLoewner's reconstructed transfer function tf() used to return -H(z)
%   (sign flipped vs Hankel/MPLoewner), which silently corrupted modal
%   truncation in SPLoewner mode (the residual became H + H_region). The
%   SPLoewner data matrices are now negated so realize() reconstructs +H(z)
%   in ALL three modes.
%
% This script samples a known transfer function, realizes it in each mode,
% and checks that tf(z0) ~= H(z0) (correct sign) for all three.
% -------------------------------------------------------------------------
fprintf('\n=== Example 2: cross-mode transfer-function sign consistency ===\n\n');

rng(0);
n  = 6; ewref = (-1:-1:-n).';
A  = diag(ewref);
Bm = randn(n,n); Cm = randn(n,n);
H  = @(z) Cm*((z*eye(n) - A) \ Bm);     % true transfer function
I  = eye(n);

op = Numerics.OperatorData(H);
op.sample_mode = Numerics.SampleMode.Direct;
op.refew = ewref;
ct  = Numerics.Contour.Circle(-3.5, 3.5, 128);   % encloses all 6 poles
cim = Numerics.CIM(op, ct); cim.SampleData.show_progress = false;
cim.SampleData.L = I; cim.SampleData.R = I;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(n, 1, 1);

z0    = -3.5 + 0.2i;          % probe point inside the contour
Htrue = H(z0);
fprintf('  Probe z0 = %s,  H(z0)(1,1) = %+.6f%+.6fi\n\n', ...
        string(z0), real(Htrue(1,1)), imag(Htrue(1,1)));

modes = [Numerics.ComputationalMode.Hankel, ...
         Numerics.ComputationalMode.SPLoewner, ...
         Numerics.ComputationalMode.MPLoewner];
for md = modes
    cim.setComputationalMode(md);
    if md == Numerics.ComputationalMode.SPLoewner
        % fixed shift outside the contour for reproducibility
        cim.RealizationData.InterpolationData = Numerics.InterpolationData([], -3.5 + 5i);
    end
    cim.compute();
    Happrox = cim.tf();                  % reconstructed transfer function handle
    Hval    = Happrox(z0);
    err     = norm(Hval - Htrue, 'fro') / norm(Htrue, 'fro');
    fprintf('  %-10s tf(z0)(1,1) = %+.6f%+.6fi   rel.err vs +H = %.2e\n', ...
            string(md), real(Hval(1,1)), imag(Hval(1,1)), err);
    assert(err < 1e-6, '%s: tf() must reconstruct +H(z), got rel.err %.2e', string(md), err);
end
fprintf('\n  --> all three modes reconstruct +H(z) (SPLoewner no longer sign-flipped): PASS\n');
fprintf('\nExample 2 complete.\n');
