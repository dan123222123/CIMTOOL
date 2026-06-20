% example1_optimal_matching.m
% -------------------------------------------------------------------------
% WHAT CHANGED (PROGRESS.md sec 4):
%   The accuracy metric used everywhere is now the *optimal* assignment
%   (Numerics.matching_distance, Hungarian/matchpairs) instead of the old
%   greedy nearest-neighbor heuristic. Greedy can over-report the error when
%   an early pairing strands a later point; it also used perms() and errored
%   at n >= 10. The optimal version is order-independent and O(n^3).
%
% This script shows a case where greedy and optimal DISAGREE, and that the
% optimal value is the smaller (correct) one.
% -------------------------------------------------------------------------
fprintf('\n=== Example 1: optimal vs greedy matching distance ===\n\n');

% Canonical disagreement case from PROGRESS.md sec 4.
ref = [0; 5; 100];
cmp = [4.9; 5.1];

gd = Numerics.greedy_matching_distance(ref, cmp);   % heuristic (kept as baseline)
od = Numerics.matching_distance(ref, cmp);          % new optimal metric

fprintf('  ref = [%s]\n', strjoin(string(ref(:).'), ', '));
fprintf('  cmp = [%s]\n\n', strjoin(string(cmp(:).'), ', '));
fprintf('  greedy_matching_distance : %.4f  (pairs 4.9->5, 5.1->? -> strands)\n', gd);
fprintf('  matching_distance (opt.) : %.4f  (pairs 4.9->5, 5.1->5 ... best total)\n\n', od);

assert(od <= gd, 'optimal must never be worse than greedy');
assert(abs(od - 4.901) < 1e-3, 'optimal value should be ~4.901');
assert(abs(gd - 5.101) < 1e-3, 'greedy value should be ~5.101');
fprintf('  --> optimal (%.3f) < greedy (%.3f): PASS\n\n', od, gd);

% And it now handles n >= 10 (old perms-based code errored here).
rng(0);
big_ref = (1:12).';
big_cmp = big_ref + 1e-3*randn(12,1);
od_big = Numerics.matching_distance(big_ref, big_cmp);
fprintf('  n=12 case (old perms code errored here): matching_distance = %.2e  PASS\n', od_big);
assert(od_big < 1e-2);

fprintf('\nExample 1 complete.\n');
