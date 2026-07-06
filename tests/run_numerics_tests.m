function run_numerics_tests()
% One-command regression runner for the headless Numerics test suite.
%
% Runs every script-based numerics test in an isolated workspace, reports
% pass/fail per script, and raises an error at the end if any failed (so it is
% usable from CI / `matlab -batch`). Excludes testCIMEigensystemRealization,
% which launches the GUI (CIMTOOL) and is not headless-safe.
%
% Usage (from any directory):
%     run_numerics_tests
%
% Each test still runs standalone (cd tests; <name>); this just bundles them so
% the whole baseline can be checked before/after a change in one shot.

    here = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(here, '..', 'src')));
    oldpwd = cd(here);                       % tests use relative paths / plotting
    cleanup = onCleanup(@() cd(oldpwd));

    % Fast unit/characterization tests first, slower convergence studies last.
    tests = { ...
        'test_quadrature', ...               % contour quadrature weights (residue/Cauchy)
        'test_contours', ...                 % contour geometry: inside(), refinement nesting
        'test_metrics', ...                  % matching_distance, maxrelresidual
        'test_validation', ...               % input validation on entry points
        'test_realization', ...              % ERA/SP/MP realization baseline
        'test_poresz', ...                   % pole-residue transfer-function eval
        'test_modal_truncation', ...         % H = H_region + H_residual decomposition
        'hankel_exactVquadrature', ...       % quadrature -> exact convergence (Hankel)
        'sploewner_exactVquadrature', ...    % quadrature -> exact convergence (SPLoewner)
        'mploewner_exactVquadrature', ...    % quadrature -> exact convergence (MPLoewner)
    };

    ok = false(1, numel(tests)); msg = strings(1, numel(tests)); secs = zeros(1, numel(tests));
    for i = 1:numel(tests)
        t0 = tic;
        [ok(i), msg(i)] = run_one([tests{i} '.m']);
        secs(i) = toc(t0);
        close all force;
        if ok(i)
            fprintf('  [PASS] %-28s (%5.1fs)\n', tests{i}, secs(i));
        else
            fprintf('  [FAIL] %-28s (%5.1fs)  --  %s\n', tests{i}, secs(i), msg(i));
        end
    end

    fprintf('\n==== %d/%d numerics tests passed (%.1fs total) ====\n', sum(ok), numel(ok), sum(secs));
    if ~all(ok)
        error('run_numerics_tests:failures', '%d test(s) failed: %s', ...
            sum(~ok), strjoin(tests(~ok), ', '));
    end
end

function [ok, msg] = run_one(scriptfile)
% Run one test script with its own workspace fully isolated from the runner's.
    ok = true; msg = "";
    try
        exec_script(scriptfile);
    catch e
        ok = false; msg = string(e.message);
    end
end

function exec_script(scriptfile)
% Separate frame so a test's own `clear` cannot clobber the runner's bookkeeping;
% evalc suppresses the (verbose) per-test stdout so the summary stays readable.
    evalc('run(scriptfile)');
end
