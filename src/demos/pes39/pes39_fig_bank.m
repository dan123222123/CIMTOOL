%% pes39_bank.png, from bank_sweep.csv and bank_margin.csv of pes39_sweep.m
%
% The bank at the margin, its trusted eigenvalues there, every trusted
% eigenvalue of the sweep coloured by delay, and the untrusted ones of both as
% empty grey boxes. Written to docs/figures/pes39.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
S = readtable(fullfile(here, 'bank_sweep.csv'));
M = readtable(fullfile(here, 'bank_margin.csv'));
tc = M.tau_ms(1);
U = [S(S.trusted == 0, :); M(M.trusted == 0, :)];
S = S(S.trusted == 1, :);  M = M(M.trusted == 1, :);

f = figure('Position', [100 100 360 1000]);
pes39_plot_bank(complex(M.re, M.im), 'Title', sprintf('\\tau = %.1f ms', tc), ...
    'Trajectory', complex(S.re, S.im), 'TrajectoryTau', S.tau_ms, 'Untrusted', complex(U.re, U.im));
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'pes39');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'pes39_bank.png'), 'Resolution', 150);
