% Unit tests for input validation / informative errors on the main Numerics
% entry points: the constructors (Contour.*, OperatorData, RealizationSize,
% SampleData, CIM, ModalTruncation) and the frequently set-directly knobs
% (contour geometry, SampleData.ell/r). Verifies that bad inputs are rejected
% at the entry -- both at construction and on later mutation -- instead of being
% silently accepted or crashing cryptically downstream, and that valid inputs
% still construct.
%
% Script-based to match the rest of tests/. Run directly in MATLAB.

rng(0);

%% Valid constructions / mutations still work (guard against false positives)
Numerics.Contour.Circle(0, 1, 8);
Numerics.Contour.Circle(2+3i, 0.5, 16);                      % complex center is fine
Numerics.Contour.Ellipse(0, 2, 1, 32);
Numerics.Contour.CircularSegment(0, 1, [-pi/2, pi/2], [16;16]);
Numerics.Contour.CircularSegment(0, 1, pi/4, 8);             % scalar theta + scalar N expand
Numerics.Contour.CircularSegment(0, 1, [-pi/2, pi/2], [16;16], "gauss");
Numerics.RealizationSize(3, 3, 3);
Numerics.OperatorData(@(z) 1./(z+1));
Numerics.OperatorData([]);                                   % empty T (load-by-name path)
Numerics.CIM();
Numerics.ModalTruncation(@(z) 1./(z+1));
cok = Numerics.Contour.Circle(0, 1, 8); cok.rho = 2; cok.N = 16;   % valid mutations
sdok = Numerics.SampleData(); sdok.ell = 0;                   % valid (default unloaded)
fprintf("valid constructions/mutations: PASS\n");

%% Circle -- invalid geometry rejected at construction
mustError(@() Numerics.Contour.Circle(0,  0, 8),   "Circle rho=0");
mustError(@() Numerics.Contour.Circle(0, -1, 8),   "Circle rho<0");
mustError(@() Numerics.Contour.Circle(0, NaN, 8),  "Circle rho=NaN");
mustError(@() Numerics.Contour.Circle(0, 1, 0),    "Circle N=0");
mustError(@() Numerics.Contour.Circle(0, 1, -4),   "Circle N<0");
mustError(@() Numerics.Contour.Circle(0, 1, 8.5),  "Circle N non-integer");
% mutation is validated too (matters for the reactive GUI + save/load)
cm = Numerics.Contour.Circle(0, 1, 8);
mustError(@() trySet(cm, 'rho', -1),  "Circle.rho=-1 mutation");
mustError(@() trySet(cm, 'N', 2.5),   "Circle.N=2.5 mutation");
fprintf("Circle validation (construct + mutate): PASS\n");

%% Ellipse -- invalid semi-axes / N rejected
mustError(@() Numerics.Contour.Ellipse(0, 0, 1, 8),   "Ellipse alpha=0");
mustError(@() Numerics.Contour.Ellipse(0, 1, -1, 8),  "Ellipse beta<0");
mustError(@() Numerics.Contour.Ellipse(0, 1, 1, 7.5), "Ellipse N non-integer");
em = Numerics.Contour.Ellipse(0, 2, 1, 8);
mustError(@() trySet(em, 'alpha', 0), "Ellipse.alpha=0 mutation");
fprintf("Ellipse validation: PASS\n");

%% CircularSegment -- radius / angle range / node counts / quad rule
mustError(@() Numerics.Contour.CircularSegment(0, -1, [-pi/2,pi/2], [8;8]),     "Segment rho<0");
mustError(@() Numerics.Contour.CircularSegment(0, 1, [pi/2,-pi/2], [8;8]),      "Segment theta reversed");
mustError(@() Numerics.Contour.CircularSegment(0, 1, [0, 3*pi], [8;8]),         "Segment theta span > 2*pi");
mustError(@() Numerics.Contour.CircularSegment(0, 1, [-pi/2,pi/2], [8;8;8]),    "Segment N has 3 elements");
mustError(@() Numerics.Contour.CircularSegment(0, 1, [-pi/2,pi/2], [8;-1]),     "Segment N<0");
mustError(@() Numerics.Contour.CircularSegment(0, 1, [-pi/2,pi/2], [8;8], "x"), "Segment bad quad rule");
fprintf("CircularSegment validation: PASS\n");

%% RealizationSize -- nonnegative integers
mustError(@() Numerics.RealizationSize(-1),    "RealizationSize m<0");
mustError(@() Numerics.RealizationSize(2.5),   "RealizationSize m non-integer");
mustError(@() Numerics.RealizationSize(3, -1), "RealizationSize T1<0");
fprintf("RealizationSize validation: PASS\n");

%% OperatorData -- T must be a function handle (or empty)
mustError(@() Numerics.OperatorData(5),            "OperatorData T numeric");
mustError(@() Numerics.OperatorData("nothandle"),  "OperatorData T string");
mustError(@() Numerics.OperatorData([], 42),       "OperatorData name numeric");
fprintf("OperatorData validation: PASS\n");

%% SampleData / CIM / ModalTruncation -- type checks + ell/r knobs
mustError(@() Numerics.SampleData(5),                         "SampleData operator wrong type");
mustError(@() Numerics.CIM(5),                               "CIM operator wrong type");
mustError(@() Numerics.CIM(Numerics.OperatorData(), 5),      "CIM contour wrong type");
mustError(@() Numerics.ModalTruncation(5),                   "ModalTruncation H not a handle");
mustError(@() Numerics.ModalTruncation(@(z)z, 5),            "ModalTruncation contour wrong type");
sd = Numerics.SampleData();
mustError(@() trySet(sd, 'ell', -1),  "SampleData.ell=-1 mutation");
mustError(@() trySet(sd, 'r', 2.5),   "SampleData.r=2.5 mutation");
fprintf("SampleData/CIM/ModalTruncation validation: PASS\n");

%%
fprintf("\nAll validation tests passed!\n");

% --- local helpers ---
function mustError(thunk, label)
    threw = false;
    try
        thunk();
    catch
        threw = true;
    end
    assert(threw, "%s: expected an error, but none was thrown", label);
end

function trySet(obj, prop, val)
    obj.(prop) = val;   % dynamic property set -> exercises set-time validation
end
