%% pes39_margin.png, from bank_sweep.csv and bank_margin.csv of pes39_sweep.m
%
% Real and imaginary parts of the rightmost trusted eigenvalue in the bank
% against the common delay, with the margin marked. Written to docs/figures/pes39.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
S = readtable(fullfile(here, 'bank_sweep.csv'));
S = S(S.trusted == 1, :);
M = readtable(fullfile(here, 'bank_margin.csv'));
tc = M.tau_ms(1);

[tau, ~, g] = unique(S.tau_ms);
zs = complex(S.re, S.im);
z = splitapply(@(w) w(find(real(w) == max(real(w)), 1)), zs, g);

f = figure('Position', [100 100 680 380]);
yyaxis left
plot(tau, real(z), '.-', 'MarkerSize', 8);  hold on;
yline(0, 'k-');
ylabel('Re \lambda');
yyaxis right
plot(tau, imag(z), '.', 'MarkerSize', 6);
ylabel('Im \lambda');
xline(tc, '--', sprintf('margin %.1f ms', tc), 'LabelVerticalAlignment', 'bottom');
xlabel('common delay \tau [ms]');  title('Rightmost trusted eigenvalue in the bank');  grid on;
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'pes39');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'pes39_margin.png'), 'Resolution', 150);
