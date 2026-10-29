%% pes39_spectra.png, from spectra.csv of pes39_spectra.m
%
% The spectrum with and without the stabilisers at zero delay, upper
% half-plane, real axis on a pseudolog scale. Written to docs/figures/pes39.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
Sp = readtable(fullfile(here, 'spectra.csv'), 'TextType', 'string');
Sp = Sp(Sp.im >= 0, :);
% asinh is linear within about sigma of zero and logarithmic beyond, so the
% electromechanical modes near the axis and the exciter poles near -100 both stay legible
sigma = 0.1;
plog = @(x) asinh(x/(2*sigma))/log(10);
nop = Sp(Sp.system == "nopss", :);  wp = Sp(Sp.system == "pss", :);

f = figure('Position', [100 100 680 420]);
plot(plog(nop.re), nop.im, 'o', 'MarkerSize', 7, 'LineWidth', 1.2);  hold on;
plot(plog(wp.re), wp.im, '.', 'MarkerSize', 16);
xline(0, 'k-');
ticks = [-100 -10 -1 -0.1 0 0.1];
xticks(plog(ticks));  xticklabels(string(ticks));  xlim(plog([-130 0.5]));
xlabel('Re \lambda');  ylabel('Im \lambda');
legend('without PSSs', 'with PSSs', 'Location', 'northwest');
title('Spectrum with/without PSSs');  grid on;
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'pes39');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'pes39_spectra.png'), 'Resolution', 150);
