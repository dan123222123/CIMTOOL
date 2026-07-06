function [nmd, pairs] = matching_distance(ref, cmp, p)
% Optimal (minimum p-norm) matching distance between two eigenvalue sets.
%
% Unlike greedy_matching_distance (a sequential nearest-neighbor heuristic that
% can over-report when an early pairing strands a later point), this solves the
% optimal assignment with matchpairs. Using cost |ref_i - cmp_j|^p makes the
% minimum-total-cost assignment coincide with the minimum p-norm of the per-pair
% error vector, so nmd is the smallest achievable norm(d, p) over all pairings.
%
% When the sets differ in size, only min(numel(ref), numel(cmp)) pairs are formed
% (the surplus points are left unmatched).
%
% Inputs:
%   ref - reference eigenvalues
%   cmp - computed eigenvalues
%   p   - norm order (default 2)
%
% Outputs:
%   nmd   - norm(d, p), d = per-pair distances of the optimal assignment
%   pairs - [matched_ref, matched_cmp] columns
    arguments
        ref
        cmp
        p = 2
    end
    ref = ref(:); cmp = cmp(:);
    if isempty(ref) || isempty(cmp)
        nmd = 0; pairs = zeros(0,2); return;
    end
    C = abs(ref - cmp.').^p;                 % n x m cost matrix
    M = matchpairs(C, max(C(:)) + 1);        % unmatched cost > any single match -> match all min(n,m)
    d = abs(ref(M(:,1)) - cmp(M(:,2)));
    nmd = norm(d, p);
    pairs = [ref(M(:,1)), cmp(M(:,2))];
end
