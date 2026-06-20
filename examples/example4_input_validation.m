% example4_input_validation.m
% -------------------------------------------------------------------------
% WHAT CHANGED (PROGRESS.md sec 8):
%   Type-checking + informative errors were added to the user-facing
%   constructors and the frequently-set-directly knobs, so bad input fails
%   AT THE ENTRY POINT (construction OR mutation) instead of silently
%   propagating or crashing cryptically later. Uses MATLAB arguments/property
%   validators, which run on both construction and the reactive obj.prop = ...
%   path.
%
% This script feeds each guarded entry point a bad value and confirms it is
% rejected, then confirms valid input still constructs.
% -------------------------------------------------------------------------
fprintf('\n=== Example 4: input validation on entry points ===\n\n');

% --- Contours: rho/alpha/beta positive, N positive integer ----------------
expect_error('Circle radius <= 0',            @() Numerics.Contour.Circle(0, -1, 8));
expect_error('Circle N non-integer',          @() Numerics.Contour.Circle(0, 1, 8.5));
expect_error('Ellipse axis <= 0',             @() Numerics.Contour.Ellipse(0, 1, 0, 8));
expect_error('CircularSegment bad angle order', ...
    @() Numerics.Contour.CircularSegment(0, 1, [pi/2, -pi/2], [8;8]));

% --- mutation path (GUI drag / save-load) is guarded too ------------------
c = Numerics.Contour.Circle(0, 1, 8);
expect_error('Circle.rho := -1 (mutation)',   @() setfield_(c, 'rho', -1));

% --- RealizationSize: nonnegative integers --------------------------------
expect_error('RealizationSize m non-integer', @() Numerics.RealizationSize(2.5, 1, 1));
expect_error('RealizationSize negative T1',   @() Numerics.RealizationSize(2, -1, 1));

% --- OperatorData: T must be a function handle ----------------------------
expect_error('OperatorData T not a handle',   @() Numerics.OperatorData(42));

% --- ModalTruncation: H must be a function handle (also hardens B5) --------
rd = Numerics.RealizationData();
ctseg = Numerics.Contour.Circle(0, 1, 16);
expect_error('ModalTruncation H not a handle', @() Numerics.ModalTruncation(42, ctseg, rd));

fprintf('\n  Valid inputs still construct cleanly:\n');
okc  = Numerics.Contour.Circle(-3.5, 3.5, 32);
okrs = Numerics.RealizationSize(6, 1, 1);
okop = Numerics.OperatorData(@(z) 1./(z+1));
fprintf('    Circle, RealizationSize, OperatorData: OK\n');
assert(okc.rho == 3.5 && okrs.m == 6 && isa(okop.T, 'function_handle'));

fprintf('\nExample 4 complete.\n');

% ---------------------- local helpers (must be at end) --------------------

% Assert that running THUNK throws (any error), printing the caught id.
function expect_error(label, thunk)
    threw = false;
    try
        thunk();
    catch e
        threw = true;
        fprintf('  rejected %-46s [%s]\n', label, e.identifier);
    end
    assert(threw, '%s should have errored but did not', label);
end

% Perform a property assignment inside a function so the validator-triggered
% error can be caught by expect_error.
function setfield_(obj, prop, val)
    obj.(prop) = val;
end
