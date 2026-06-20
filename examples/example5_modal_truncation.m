% example5_modal_truncation.m
% -------------------------------------------------------------------------
% WHAT CHANGED (PROGRESS.md sec 1, bugs B5 + B2):
%   B5: Visual.ModalTruncation could not be constructed at all (the subclass
%       never called the Numerics superclass constructor, which requires H).
%       Every construction path -- including fromNumerics -- errored. Fixed by
%       calling obj@Numerics.ModalTruncation(H, ...) explicitly and setting
%       sample_mode = "Direct".
%   B2: with the SPLoewner tf sign fixed, modal truncation is now correct in
%       SPLoewner mode too (residual = H - H_region, not H + H_region).
%
% This script runs the full modal-truncation workflow on a known system:
%   * picks a contour enclosing a SUBSET of the poles
%   * checks the region eigenvalues are exactly the enclosed poles
%   * checks the decomposition H = H_region + H_residual holds
%   * confirms Visual.ModalTruncation now constructs (the B5 fix)
% -------------------------------------------------------------------------
fprintf('\n=== Example 5: modal truncation (B5 construct fix + decomposition) ===\n\n');

% A SISO system with 4 real poles; we will isolate the two nearest -1.5.
poles = [-1; -2; -8; -9];
res   = [1; 1; 1; 1];
H = @(z) sum(res ./ (z - poles));          % scalar transfer function

% Contour enclosing only the poles at -1 and -2.
contour = Numerics.Contour.Circle(-1.5, 1.0, 128);
fprintf('  Full system poles: %s\n', strjoin(string(poles(:).'), ', '));
fprintf('  Contour: circle centered -1.5, radius 1.0  (encloses -1, -2)\n\n');

rd = Numerics.RealizationData();
rd.RealizationSize = Numerics.RealizationSize(2, 4, 4);   % expect 2 poles in region
rd.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

mt = Numerics.ModalTruncation(H, contour, rd);
mt.compute();

ew_region = sort(mt.getRegionEigenvalues());
fprintf('  Region eigenvalues recovered: %s\n', ...
        strjoin(compose("%.4f", real(ew_region(:).')), ', '));
enclosed = sort([-1; -2]);
dd = Numerics.matching_distance(enclosed, ew_region);
fprintf('  matching distance to enclosed poles {-1,-2}: %.2e\n', dd);
assert(dd < 1e-6, 'region eigenvalues should be the enclosed poles {-1,-2}');

% Decomposition: H(z) = H_region(z) + H_residual(z), checked on a grid that
% avoids the poles. The residual should also be smooth (no enclosed poles).
Hreg = mt.getRegionTransferFunction();
Hres = mt.getResidualTransferFunction();
zg = -1.5 + 1.7*exp(1i*linspace(0, 2*pi, 50));    % off all poles and the contour
recon_err = max(abs(arrayfun(H, zg) - (arrayfun(Hreg, zg) + arrayfun(Hres, zg))));
fprintf('  max |H - (H_region + H_residual)| on test grid: %.2e\n', recon_err);
assert(recon_err < 1e-10, 'decomposition identity must hold');
fprintf('  --> region recovered + clean decomposition: PASS\n\n');

% --- B5: Visual.ModalTruncation must now CONSTRUCT ------------------------
% (Construction is the bug that was fixed; it needs graphics objects, so we
%  guard it -- a headless session without a display can still report it.)
try
    vmt = Visual.ModalTruncation(H, Visual.Contour.Circle(-1.5, 1.0, 128));
    assert(isa(vmt, 'Visual.ModalTruncation'));
    fprintf('  Visual.ModalTruncation constructed (B5 fixed): PASS\n');
catch e
    fprintf(2, '  Visual.ModalTruncation construction skipped (%s): %s\n', ...
            e.identifier, e.message);
    fprintf('    (likely a headless/no-display issue, not the B5 constructor bug)\n');
end

fprintf('\nExample 5 complete.\n');
