%% Figure of the PEEC example, from the CSV of milano_peec_1.m
%
% tau_sweep.png: the eigenvalues inside the ellipse with semi-axes 2 and 10 for
% each delay of the sweep, coloured by the delay in ms; empty grey boxes for the
% untrusted ones, relative residual >= 1e-8. Written to docs/figures/peec.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
S = readtable(fullfile(here, 'peec_tau_sweep.csv'));
tau_ms = 1000*S.tau;
trusted = S.relres < 1e-8;
untrusted = S.relres >= 1e-8;

f = figure('Color', 'w', 'Position', [100 100 500 530]);
hold on;  box on;
th = linspace(0, 2*pi, 400);
plot(2*cos(th), 10*sin(th), 'k-');
xline(0, 'k:');
scatter(S.re(trusted), S.im(trusted), 14, tau_ms(trusted), 'filled');
hu = plot(S.re(untrusted), S.im(untrusted), 's', 'LineStyle', 'none', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.6 0.6 0.6]);
legend(hu, 'relative residual \geq 10^{-8}', 'Interpreter', 'tex', 'Location', 'northoutside');
colormap(parula);  cb = colorbar;  clim([min(tau_ms) max(tau_ms)]);  cb.Label.String = '\tau [ms]';
xlabel('Re \lambda');  ylabel('Im \lambda');  axis([-2.2 0.6 -10.5 10.5]);
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'peec');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'tau_sweep.png'), 'Resolution', 150);
