% run_all_examples.m
% -------------------------------------------------------------------------
% One-command tour of every change on the cleanup/prelim-hardening branch,
% followed by the full headless regression suite (the "nothing broke" check).
%
% Usage (from the repo root):
%   addpath(genpath("src"))
%   cd examples
%   run_all_examples
% -------------------------------------------------------------------------

% Make sure src is on the path regardless of where this is launched from.
here = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(here, '..', 'src')));

examples = { ...
    'example1_optimal_matching', ...
    'example2_crossmode_tf', ...
    'example3_mploewner_rectangular', ...
    'example4_input_validation', ...
    'example5_modal_truncation'};

fprintf('\n#########################################################\n');
fprintf('#  CIMTOOL feature examples (cleanup/prelim-hardening)   #\n');
fprintf('#########################################################\n');

failed = strings(0);
for k = 1:numel(examples)
    name = examples{k};
    try
        run(fullfile(here, [name '.m']));
    catch e
        failed(end+1) = string(name); %#ok<AGROW>
        fprintf(2, '\n!!! %s FAILED: %s\n', name, e.message);
    end
end

fprintf('\n=========================================================\n');
if isempty(failed)
    fprintf('All %d feature examples passed.\n', numel(examples));
else
    fprintf(2, '%d example(s) FAILED: %s\n', numel(failed), strjoin(failed, ', '));
end
fprintf('=========================================================\n');

% --- Regression suite: prove nothing else broke --------------------------
fprintf('\nRunning the full headless numerics test suite (run_numerics_tests)...\n\n');
testsdir = fullfile(here, '..', 'tests');
oldpwd = pwd; cleanup = onCleanup(@() cd(oldpwd));
cd(testsdir);
run_numerics_tests;     % errors if any test fails
clear cleanup;          % restore pwd

fprintf('\nAll feature examples + regression suite complete.\n');
