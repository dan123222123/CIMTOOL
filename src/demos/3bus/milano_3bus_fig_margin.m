%% delay_margin.png, from sweep.csv and margin.csv of milano_3bus_sweep.m
%
% Real and imaginary parts of the rightmost trusted eigenvalue (relative
% residual below 1e-8) in the disk against the PSS delay, with the margin
% marked. Untrusted eigenvalues, if any, are empty grey boxes. Written to
% docs/figures/milano_3bus.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
S = readtable(fullfile(here, 'sweep.csv'));
M = readtable(fullfile(here, 'margin.csv'));
tc = M.margin_ms(1);
ok = S.relres < 1e-8;
U = S(~ok, :);  S = S(ok, :);

[tau, ~, g] = unique(S.tau_ms);
zs = complex(S.re, S.im);
z = splitapply(@(w) w(find(real(w) == max(real(w)), 1)), zs, g);

f = figure('Position', [100 100 680 380]);
boxstyle = {'s', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.6 0.6 0.6]};
yyaxis left
plot(tau, real(z), '-', 'LineWidth', 1.5);  hold on;
if height(U) > 0
    hu = plot(U.tau_ms, U.re, boxstyle{:});
    legend(hu, 'relative residual \geq 10^{-8}', 'Interpreter', 'tex', 'AutoUpdate', 'off');
end
yline(0, 'k-');
ylabel('Re \lambda');
yyaxis right
plot(tau, imag(z), '.', 'MarkerSize', 6);
if height(U) > 0; plot(U.tau_ms, U.im, boxstyle{:}); end
ylabel('Im \lambda');
xline(tc, '--', sprintf('margin %.1f ms', tc), 'LabelVerticalAlignment', 'bottom');
xlabel('PSS delay \tau [ms]');  title('Rightmost eigenvalue in the disk');  grid on;
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'milano_3bus');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'delay_margin.png'), 'Resolution', 150);
