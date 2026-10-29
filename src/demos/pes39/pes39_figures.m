%% All figures of the PES 39-bus delay example, from the CSVs only
%
% Each figure has its own script; this runs them in turn. All are written to
% docs/figures/pes39.

here = fileparts(mfilename('fullpath'));
run(fullfile(here, 'pes39_fig_margin.m'));
run(fullfile(here, 'pes39_fig_bank.m'));
run(fullfile(here, 'pes39_fig_single_bank.m'));
run(fullfile(here, 'pes39_fig_spectra.m'));
