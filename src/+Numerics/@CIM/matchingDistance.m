function [nmd,pairs] = matchingDistance(obj)
% Optimal (minimum-norm) matching distance between the CIM's computed
% eigenvalues and the reference eigenvalues stored on the operator.
%
% Uses Numerics.matching_distance (optimal assignment via matchpairs) rather
% than the greedy heuristic, so the reported distance is the true minimum over
% all pairings and is independent of argument order.
%
% Outputs:
%   nmd   - optimal matching distance (2-norm of the paired residuals)
%   pairs - [matched_ref, matched_computed] columns

    if obj.DataDirtiness
        error("Data is dirty, computing matching distances in this condition doesn't make sense...")
    end

    refew = obj.SampleData.OperatorData.refew;

    if isempty(refew)
        error("no reference eigenvalue data in CIM, cannot compute matching distance...")
    end

    [nmd,pairs] = Numerics.matching_distance(refew,obj.ResultData.ew);

end
