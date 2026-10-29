function run_numerics_tests(suite)
% One-command regression runner for the headless Numerics test suite.
%
% Runs every script-based numerics test in an isolated workspace, reports
% pass/fail per script, and raises an error at the end if any failed (so it is
% usable from CI / `matlab -batch`). Excludes testCIMEigensystemRealization,
% which launches the GUI (CIMTOOL) and is not headless-safe.
%
% Usage (from any directory):
%     run_numerics_tests           % the CI suite
%     run_numerics_tests("all")    % also the heavy example tests (test_pes39, test_gun)
%
% Each test still runs standalone (cd tests; <name>); this just bundles them so
% the whole baseline can be checked before/after a change in one shot.

    arguments
        suite (1,1) string {mustBeMember(suite, ["ci", "all"])} = "ci"
    end

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
        'test_cim_state', ...                % RNG-neutral construction/copy, listener re-wiring, rank tolerance
        'test_reference', ...                % background polyeig reference: wait, callback, cancel, size limit (skips w/o NLEVP)
        'test_rankrule', ...                 % automatic realization order: rankgap, RankRule Tolerance/Gap
        'test_save_load_state', ...          % session save/load round trips, old files (NLEVP case skips w/o NLEVP)
        'test_poresz', ...                   % pole-residue transfer-function eval
        'test_modal_truncation', ...         % H = H_region + H_residual decomposition
        'hankel_exactVquadrature', ...       % quadrature -> exact convergence (Hankel)
        'sploewner_exactVquadrature', ...    % quadrature -> exact convergence (SPLoewner)
        'mploewner_exactVquadrature', ...    % quadrature -> exact convergence (MPLoewner)
        'test_tritare', ...                  % exact transcendental ground truth + multiplicities (skips w/o nlevp_webs)
    };
    % Heavy example tests, kept out of CI: run only with run_numerics_tests("all").
    heavy = { ...
        'test_pes39', ...                    % ten-delay 39-bus benchmark: published spectrum, CIM vs Newton (downloads on first run)
        'test_gun', ...                      % sparse sampler at n=9956, slow ~1-2 min (skips w/o NLEVP)
    };
    if suite == "all", tests = [tests, heavy]; end

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
