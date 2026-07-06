function [mres, worst_ew, idx] = maxrelresidual(T, ew, ev, mode)
% Maximum relative residual over a set of (eigenvalue, eigenvector) pairs.
%
% Thin wrapper over Numerics.relres: computes the per-pair relative residual
% norm(T(ew)*ev)/norm(T(ew),'fro') (with the eigenvectors normalized), then
% returns the largest residual together with the offending eigenvalue.
%
% Inputs:
%   T    - operator/transfer-function handle T(z)
%   ew   - vector of eigenvalues
%   ev   - matrix of eigenvectors (columns aligned with ew)
%   mode - Numerics.SampleMode.{Inverse,Direct} (default: Inverse)
%
% Outputs:
%   mres     - maximum relative residual
%   worst_ew - eigenvalue achieving the maximum residual
%   idx      - its index into ew
    arguments
        T
        ew
        ev
        mode = Numerics.SampleMode.Inverse
    end
    rr = Numerics.relres(T, ew, ev, mode);
    [mres, idx] = max(rr);
    worst_ew = ew(idx);
end
