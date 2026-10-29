% The reference eigenvalues of an NLEVP PEP (OperatorData.computeReference), computed on the background pool:
%   - a small problem finishes within ReferenceWait, so refew is set before the load returns
%   - with ReferenceWait = 0 the result arrives through the afterEach callback, or through waitReference
%   - cancelReference, or refew set by hand, stops it; a second load drops the first problem's late result
%   - n*d above MaxReferenceSize is skipped; a failure warns and leaves refew empty
%   - copy, conversions and a MAT round trip keep refew and the status, and a running computation becomes cancelled
%   - a dropped operator is collected while its reference is computing
%
% SKIPS without NLEVP on the path. Script-based to match the rest of tests/. Run directly in MATLAB.

if ~exist('nlevp', 'file')
    fprintf('SKIP: NLEVP not found on path -- test_reference not run\n');
    return
end
% acoustic_wave_1d(N) is a quadratic of size N, so n*d = 2N: polyeig takes well under a second at N = 10,
% about one at N = 300, and tens of seconds at N = 1000 on a background thread
small = 'acoustic_wave_1d'; medium = "300,1"; large = "1000,1";

%% a small PEP finishes within the wait
op = Numerics.OperatorData([], small);
assert(op.ReferenceStatus == "done" && isReference(op, small, []), "a small PEP must set refew before the load returns");
assert(op.waitReference(0), "nothing may be left running");
fprintf("synchronous reference: PASS\n");

%% with no wait the result arrives through the callback, or through waitReference
op = Numerics.OperatorData(); op.ReferenceWait = 0; op.MaxReferenceSize = Inf;
op.loadNLEVPPACK(small, medium);
assert(op.ReferenceStatus == "computing" && isempty(op.refew) && ~op.waitReference(0), "with no wait the load must return while computing");
waitFor(op);   % pause lets the afterEach callback run
assert(op.ReferenceStatus == "done" && isReference(op, small, medium), "the callback must set refew");
op.loadNLEVPPACK(small, medium);
assert(op.waitReference() && op.ReferenceStatus == "done" && isReference(op, small, medium), "waitReference must set refew");
pause(0.5);
assert(op.ReferenceStatus == "done", "the callback after waitReference must change nothing");
fprintf("asynchronous reference: PASS\n");

%% cancel, or refew set by hand, stops the computation
op = Numerics.OperatorData(); op.ReferenceWait = 0; op.MaxReferenceSize = Inf;
op.loadNLEVPPACK(small, large);
op.cancelReference(); pause(0.5);
assert(op.ReferenceStatus == "cancelled" && isempty(op.refew) && op.waitReference(0), "cancel must leave refew empty");
op.loadNLEVPPACK(small, large);
op.refew = [1; 2]; pause(0.5);
assert(op.ReferenceStatus == "none" && isequal(op.refew, [1; 2]) && op.waitReference(0), "refew set by hand must stop the computation, stay, and leave no status");
fprintf("cancel: PASS\n");

%% a second load keeps only the second problem's reference
op = Numerics.OperatorData(); op.ReferenceWait = 0; op.MaxReferenceSize = Inf;
op.loadNLEVPPACK(small, large);
op.ReferenceWait = 5; op.loadNLEVPPACK('butterfly');
pause(0.5);
assert(op.ReferenceStatus == "done" && isReference(op, 'butterfly', []), "a load must replace a running computation");
% a first result that finished, but whose callback has not run yet, is dropped as well
op.ReferenceWait = 0; op.loadNLEVPPACK(small);
t = tic; while toc(t) < 1, end   % finishes, but a busy wait runs no callbacks
op.loadNLEVPPACK('butterfly'); op.waitReference(); pause(0.5);
assert(op.ReferenceStatus == "done" && isReference(op, 'butterfly', []), "a superseded result must not overwrite the current one");
fprintf("second load: PASS\n");

%% above the size limit the reference is skipped
op = Numerics.OperatorData(); op.MaxReferenceSize = 19;   % acoustic_wave_1d: n*d = 20
op.loadNLEVPPACK(small);
assert(op.ReferenceStatus == "skipped" && isempty(op.refew) && op.waitReference(0), "n*d above MaxReferenceSize must be skipped");
op.MaxReferenceSize = 20; op.computeReference();
assert(op.ReferenceStatus == "done", "n*d at MaxReferenceSize must be computed");
op.MaxReferenceSize = 19; op.computeReference(); op.refew = [1; 2];
assert(op.ReferenceStatus == "none", "a reference set by hand must replace a skipped one");
op.compute_reference = false; op.computeReference();
assert(op.ReferenceStatus == "none", "compute_reference = false must give no automatic reference");
fprintf("size limit: PASS\n");

%% a failure warns once and leaves refew empty
op = Numerics.OperatorData([], small);
op.coeffs = {ones(2, 3), ones(2, 3)};   % not square: polyeig errors
lastwarn(''); warning('off', 'Numerics:OperatorData:referenceFailed');
op.computeReference(); [~, wid] = lastwarn;
assert(op.ReferenceStatus == "failed" && isempty(op.refew) && wid == "Numerics:OperatorData:referenceFailed", "a failure within the wait must warn");
op.ReferenceWait = 0; lastwarn(''); op.computeReference(); waitFor(op); [~, wid] = lastwarn;
assert(op.ReferenceStatus == "failed" && isempty(op.refew) && wid == "Numerics:OperatorData:referenceFailed", "a failure in the callback must warn");
warning('on', 'Numerics:OperatorData:referenceFailed');
fprintf("failure: PASS\n");

%% copies, conversions and a MAT round trip keep the reference, and a running one becomes cancelled
f = [tempname '.mat'];
done = Numerics.OperatorData([], small);
running = Numerics.OperatorData(); running.ReferenceWait = 0; running.MaxReferenceSize = Inf; running.loadNLEVPPACK(small, large);
for x = {done, running, Visual.OperatorData.fromNumerics(done)}
    o = x{1}; save(f, 'o'); S = load(f);
    if isa(o, 'Visual.OperatorData'), conv = o.toNumerics(); else, conv = Visual.OperatorData.fromNumerics(o); end
    expected = replace(o.ReferenceStatus, "computing", "cancelled");
    for y = {copy(o), S.o, conv}
        c = y{1};
        assert(c.ReferenceStatus == expected && isequal(c.refew, o.refew) && c.waitReference(0), ...
            "%s from %s (%s): refew and status must survive, without a running computation", class(c), class(o), o.ReferenceStatus);
    end
end
assert(running.ReferenceStatus == "computing", "copying must leave the source's computation running");
running.cancelReference(); delete(f);
fprintf("copy and MAT round trip: PASS\n");

%% a dropped operator is collected while computing
op = Numerics.OperatorData(); op.ReferenceWait = 0; op.MaxReferenceSize = Inf; op.loadNLEVPPACK(small, large);
w = matlab.lang.WeakReference(op);
clear op
assert(~isvalid(w.Handle), "a pending reference must not keep its operator alive");
fprintf("dropped operator: PASS\n");

function tf = isReference(op, name, args)
% Whether op.refew is polyeig of the NLEVP problem name with the comma-separated arguments args, up to rounding.
    if isempty(args)
        c = nlevp(name);
    else
        a = num2cell(str2double(split(args, ",")));
        c = nlevp(name, a{:});
    end
    e = polyeig(c{:});
    tf = numel(op.refew) == numel(e) && Numerics.matching_distance(op.refew, e) < 1e-8*norm(e);
end

function waitFor(op)
% Pauses, so that the afterEach callback runs, until op stops computing.
    t = tic;
    while op.ReferenceStatus == "computing" && toc(t) < 60
        pause(0.05);
    end
end
