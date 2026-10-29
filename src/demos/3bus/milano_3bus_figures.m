%% All figures of the three-bus delay example, from the CSVs only
%
% Each figure has its own script; this runs them in turn. Both are written to
% docs/figures/milano_3bus.

here = fileparts(mfilename('fullpath'));
run(fullfile(here, 'milano_3bus_fig_spectra.m'));
run(fullfile(here, 'milano_3bus_fig_margin.m'));
