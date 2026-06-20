% example3_mploewner_rectangular.m
% -------------------------------------------------------------------------
% WHAT CHANGED (PROGRESS.md sec 7):
%   MPLoewner with unequal numbers of left/right interpolation points
%   (#theta ~= #sigma -> a *rectangular* Loewner pencil) used to crash:
%   the padding branch sized the tangential-direction arrays with each
%   other's lengths. The Loewner pencil is allowed to be rectangular --
%   realize() SVD-truncates to m -- so the only requirement is
%   min(#theta,#sigma) >= m. Both builders were rewritten accordingly.
%   Additionally, min(#theta,#sigma) < m now raises an INFORMATIVE error
%   (Numerics:mploewner:tooFewPoints) instead of a cryptic subscript/rank
%   crash.
%
% This script recovers a known spectrum with #theta > #sigma and with
% #sigma > #theta, then shows the informative too-few-points error.
% -------------------------------------------------------------------------
fprintf('\n=== Example 3: MPLoewner rectangular (unequal #theta/#sigma) ===\n\n');

rng(0);
n  = 6; ewref = (-1:-1:-n).';
A  = diag(ewref);
Bm = randn(n,n); Cm = randn(n,n);
H  = @(z) Cm*((z*eye(n) - A) \ Bm);
I  = eye(n);
m  = n;                                  % McMillan degree we seek

% Distinct interpolation points placed off the spectrum (two concentric rings).
mk  = @(cnt,rad,off) (-3.5 + rad*exp(2i*pi*((0:cnt-1).'+off)/cnt));
pad = {"PadStrategy", "cyclical", "Verbose", false};

% --- more left points than right (pads the left side) ---------------------
ewU1 = sort(Numerics.mploewner.mploewner_exact(H, mk(n+2,4,0), mk(n,5,0.5), I, I, m, pad{:}));
d1 = Numerics.matching_distance(ewref, ewU1);
fprintf('  #theta=%d > #sigma=%d :  matching distance = %.2e\n', n+2, n, d1);
assert(d1 < 1e-6, '#theta>#sigma must recover the spectrum');

% --- more right points than left (pads the right side) --------------------
ewU2 = sort(Numerics.mploewner.mploewner_exact(H, mk(n,4,0), mk(n+2,5,0.5), I, I, m, pad{:}));
d2 = Numerics.matching_distance(ewref, ewU2);
fprintf('  #theta=%d < #sigma=%d :  matching distance = %.2e\n', n, n+2, d2);
assert(d2 < 1e-6, '#sigma>#theta must recover the spectrum');

fprintf('  --> both rectangular pencils recover the true spectrum: PASS\n\n');

% --- under-determined: min(#theta,#sigma) < m must error LOUDLY -----------
errid = "";
try
    Numerics.mploewner.mploewner_exact(H, mk(m-2,4,0), mk(m-3,5,0.5), I, I, m, pad{:});
catch e
    errid = string(e.identifier);
    fprintf('  too-few-points raised: %s\n', e.identifier);
    fprintf('    "%s"\n', e.message);
end
assert(errid == "Numerics:mploewner:tooFewPoints", ...
    'expected Numerics:mploewner:tooFewPoints, got "%s"', errid);
fprintf('  --> informative error on min(#theta,#sigma) < m: PASS\n');

fprintf('\nExample 3 complete.\n');
