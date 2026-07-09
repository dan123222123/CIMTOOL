%% test_save_load_state.m
% Tests for Numerics.CIM save/load session serialization.
%
% Verifies:
%   1. Function-handle operator: full round-trip incl. cached results (.mat)
%   2. MPLoewner custom shifts survive reconstruction (guards the constructor
%      update_shifts() clobber)
%   3. Greedy/partial struct loads with defaults, no error
%   4. NLEVP round-trip incl. arglist (skipped if NLEVP is unavailable)

clear; clc;
fprintf('Testing Numerics.CIM save/load state...\n\n');

npass = 0; nfail = 0;
pass = @(msg) fprintf('  PASSED: %s\n', msg);
tmp  = tempname;                      % base path (no extension)
cleanupObj = onCleanup(@() delete_if(tmp + ".mat"));

%% Test 1: function-handle operator, full round-trip with results
fprintf('Test 1: function-handle operator round-trip (.mat)\n');
try
    rng(0);
    n = 6; ewref = (-1:-1:-n);
    A = diag(ewref); B = randn(n,n); C = randn(n,n);
    H = @(z) C*((z*eye(size(A)) - A) \ B);

    op = Numerics.OperatorData(H); op.sample_mode = Numerics.SampleMode.Direct;
    contour = Numerics.Contour.Ellipse(-(n+1)/2, (n+1)/2, 0.5, 32);
    cim = Numerics.CIM(op, contour);
    cim.SampleData.OperatorData.refew = ewref;
    cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
    cim.SampleData.ell = n; cim.SampleData.r = n;
    cim.RealizationData.K = 1; cim.RealizationData.m = n;
    cim.compute();

    ew0  = cim.ResultData.ew;
    gmd0 = cim.matchingDistance();

    cim.saveState(tmp);
    cim2 = Numerics.CIM.loadState(tmp + ".mat");

    assert(isa(cim2.SampleData.OperatorData.T,'function_handle'), 'operator handle not restored');
    assert(isequal(cim2.SampleData.OperatorData.T(0), H(0)), 'restored handle evaluates differently');
    assert(cim2.SampleData.ell == n && cim2.SampleData.r == n, 'ell/r not preserved');
    assert(cim2.SampleData.Contour.alpha == (n+1)/2, 'contour params not preserved');
    assert(cim2.RealizationData.ComputationalMode == Numerics.ComputationalMode.Hankel, 'mode not preserved');
    assert(norm(sort(cim2.ResultData.ew) - sort(ew0)) < 1e-12, 'computed eigenvalues not preserved');
    assert(cim2.DataDirtiness == 0, 'DataDirtiness should be clean after loading a computed session');
    assert(abs(cim2.matchingDistance() - gmd0) < 1e-12, 'matching distance changed after reload');
    pass('function-handle session round-trips exactly'); npass = npass + 1;
catch e
    fprintf('  FAILED: %s\n', e.message); nfail = nfail + 1;
end
fprintf('\n');

%% Test 2: MPLoewner custom shifts survive reconstruction (guards C4)
fprintf('Test 2: MPLoewner custom interpolation shifts round-trip\n');
try
    contour = Numerics.Contour.Circle(0.15, 0.3, 16);
    op = Numerics.OperatorData(@(z) eye(2));   % operator irrelevant here
    cim = Numerics.CIM(op, contour);
    cim.auto_update_shifts = false;            % keep our hand-set shifts
    cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
    theta0 = [0.4+0.5i; -0.3-0.2i];
    sigma0 = [1.1+0.0i;  0.0-1.2i];
    cim.RealizationData.InterpolationData = Numerics.InterpolationData(theta0, sigma0);

    cim.saveState(tmp);
    cim2 = Numerics.CIM.loadState(tmp + ".mat");

    assert(cim2.RealizationData.ComputationalMode == Numerics.ComputationalMode.MPLoewner, 'mode lost');
    assert(isequal(cim2.RealizationData.InterpolationData.theta, theta0), 'theta shifts clobbered');
    assert(isequal(cim2.RealizationData.InterpolationData.sigma, sigma0), 'sigma shifts clobbered');
    assert(cim2.auto_update_shifts == false, 'auto_update_shifts flag not preserved');
    pass('custom MPLoewner shifts survive the reconstruction'); npass = npass + 1;
catch e
    fprintf('  FAILED: %s\n', e.message); nfail = nfail + 1;
end
fprintf('\n');

%% Test 3: greedy partial struct
fprintf('Test 3: greedy load of a partial struct\n');
try
    s = struct();
    s.version = 1;
    s.contour = struct('type','Circle','gamma',0.5+0.2i,'rho',0.9,'N',12);
    s.sample  = struct('ell',3,'r',3);
    % everything else (operator, realization, result, cim) intentionally absent
    ws = warning('off','all');
    cimP = Numerics.CIM.fromStruct(s);
    warning(ws);

    assert(isa(cimP,'Numerics.CIM'), 'fromStruct did not return a CIM');
    assert(cimP.SampleData.Contour.gamma == 0.5+0.2i, 'partial contour not applied');
    assert(cimP.SampleData.Contour.N == 12, 'partial contour N not applied');
    assert(cimP.SampleData.ell == 3, 'partial ell not applied');
    assert(cimP.RealizationData.ComputationalMode == Numerics.ComputationalMode.Hankel, 'missing mode should default to Hankel');
    pass('partial struct loads with defaults and no error'); npass = npass + 1;
catch e
    fprintf('  FAILED: %s\n', e.message); nfail = nfail + 1;
end
fprintf('\n');

%% Test 4: CircularSegment contour + complex center round-trip
fprintf('Test 4: CircularSegment contour round-trip\n');
try
    contour = Numerics.Contour.CircularSegment(0.2+0.1i, 0.7, [-pi/2, pi/2], [16;16], "clencurt");
    op  = Numerics.OperatorData([], []);   % unloaded operator
    cim = Numerics.CIM(op, contour);
    cim.SampleData.ell = 4; cim.SampleData.r = 5;
    cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.SPLoewner;

    cim.saveState(tmp);
    cim2 = Numerics.CIM.loadState(tmp + ".mat");

    c2 = cim2.SampleData.Contour;
    assert(isa(c2,'Numerics.Contour.CircularSegment'), 'contour type not reconstructed');
    assert(abs(c2.gamma - (0.2+0.1i)) < 1e-12, 'complex contour center not preserved');
    assert(isequal(c2.N, [16 16]) && c2.qr == "clencurt", 'segment params not preserved');
    assert(cim2.SampleData.ell == 4 && cim2.SampleData.r == 5, 'ell/r not reconstructed');
    assert(cim2.RealizationData.ComputationalMode == Numerics.ComputationalMode.SPLoewner, 'mode not reconstructed');
    pass('CircularSegment contour + complex center round-trips'); npass = npass + 1;
catch e
    fprintf('  FAILED: %s\n', e.message); nfail = nfail + 1;
end
fprintf('\n');

%% Test 5: NLEVP round-trip incl. arglist (skipped if NLEVP unavailable)
fprintf('Test 5: NLEVP provenance round-trip (name + arglist)\n');
if exist('nlevp','file') ~= 2
    fprintf('  SKIPPED: NLEVP collection not on the path\n');
else
    try
        op = Numerics.OperatorData([], 'loaded_string', '10');   % takes a size argument
        contour = Numerics.Contour.Circle(0, 5, 16);
        cim = Numerics.CIM(op, contour);

        cim.saveState(tmp);
        cim2 = Numerics.CIM.loadState(tmp + ".mat");

        od2 = cim2.SampleData.OperatorData;
        assert(strcmp(char(od2.name),'loaded_string'), 'NLEVP name not preserved');
        assert(~isempty(od2.arglist), 'NLEVP arglist not preserved');
        assert(isa(od2.T,'function_handle') && od2.loaded, 'NLEVP operator not regenerated');
        assert(isequal(od2.T(0), cim.SampleData.OperatorData.T(0)), 'regenerated NLEVP operator differs');
        pass('NLEVP session regenerates from name + arglist'); npass = npass + 1;
    catch e
        fprintf('  FAILED: %s\n', e.message); nfail = nfail + 1;
    end
end
fprintf('\n');

%% Summary
fprintf('==================================================\n');
fprintf('  %d passed, %d failed\n', npass, nfail);
fprintf('==================================================\n');
assert(nfail == 0, 'test_save_load_state: %d test(s) failed', nfail);

function delete_if(p)
    if isfile(p); delete(p); end
end
