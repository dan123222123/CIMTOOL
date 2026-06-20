function [mres, worst_ew, idx] = maxrelresidual(cim)
% Maximum relative residual of the CIM's computed eigenpairs against the operator.
%
% Convenience method: pulls the operator handle, computed eigenvalues/right
% eigenvectors, and sample mode off the CIM object and defers to the standalone
% Numerics.maxrelresidual utility.
%
% Outputs:
%   mres     - maximum relative residual
%   worst_ew - eigenvalue achieving the maximum residual
%   idx      - its index into cim.ResultData.ew
    [mres, worst_ew, idx] = Numerics.maxrelresidual( ...
        cim.SampleData.OperatorData.T, ...
        cim.ResultData.ew, ...
        cim.ResultData.rev, ...
        cim.SampleData.OperatorData.sample_mode);
end
