%% spectra.png, from spectra.csv of milano_3bus_spectra.m
%
% The spectrum with and without the PSS at zero delay, zoomed on the
% electromechanical mode the PSS moves. Written to docs/figures/milano_3bus.

% --8<-- [start:plot]
here = fileparts(mfilename('fullpath'));
Sp = readtable(fullfile(here, 'spectra.csv'), 'TextType', 'string');
Sp = Sp(Sp.im >= 0, :);
nop = Sp(Sp.system == "nopss", :);  wp = Sp(Sp.system == "pss", :);

f = figure('Position', [100 100 680 420]);
plot(nop.re, nop.im, 'o', 'MarkerSize', 7, 'LineWidth', 1.2);  hold on;
plot(wp.re, wp.im, '.', 'MarkerSize', 16);
xline(0, 'k-');
xlim([-2.5 0.5]);  ylim([1.5 7]);
xlabel('Re \lambda');  ylabel('Im \lambda');
legend('without PSS', 'with PSS', 'Location', 'northwest');
title('Spectrum with/without PSS');  grid on;
% --8<-- [end:plot]
outdir = fullfile(here, '..', '..', '..', 'docs', 'figures', 'milano_3bus');
theme(f, "light");
exportgraphics(f, fullfile(outdir, 'spectra.png'), 'Resolution', 150);
