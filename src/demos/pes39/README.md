# IEEE PES 39-bus benchmark with delayed feedback loops

The model is the IEEE 39-bus system as published by the IEEE PES Task Force on Benchmark Systems for Stability Controls.
The MATLAB implementation and its report are by I. Hiskens (2013), on the task force's page https://cmte.ieee.org/pes-psdp/benchmark-systems-2/ ("IEEE 39 Bus System", MATLAB Report and MATLAB Files).
The task force documents the benchmarks in C. Cañizares et al., "Benchmark Models for the Analysis and Control of Small-Signal Oscillatory Dynamics in Power Systems," IEEE Trans. Power Syst. 32(1), 2017, and in the technical report PES-TR18 (2015).

## Files

- `pes39_model.m`: downloads the small-disturbance "MATLAB Files" into `cache/` on first use and builds the delay model \(T(\lambda) = \lambda I - A_0 - B\,\mathrm{diag}(e^{-\lambda\tau})E^\top\) on the 100 live states of the report's reduced matrix `Ared`.
  `cache/` is ignored by git.
- `pes39_bank.m`: the base bank, a wall of CIM disks of radius 1 centred at \(3i, 4i, \dots, 12i\), each passing through its neighbours' centres.
  It returns a function of the delay vector that gives every eigenvalue the disks find inside their contours, with its relative residual.
  An eigenvalue is trusted when its relative residual \(\|T(z)v\| / \|T(z)\|_F\) is below \(10^{-8}\), and the margin search uses only trusted eigenvalues.
  An eigenvalue found by two disks is kept once, with the smaller residual.
  CIMTOOL's automatic rank reads a disk whose contour moment level is below \(10^{-5}\) as empty, and otherwise realizes at the largest singular-value gap of the disk's data matrix.
  The disks share one operator and one pair of probing matrices drawn after a fixed seed, so each new delay only resamples.
  The computational mode, the probing size and \(K\) are options.
- `pes39_margin.m`: the delay margin along a delay direction, the smallest delay at which the bank trusts an eigenvalue with positive real part, refined by `fzero`.
- `pes39_plot_bank.m`: plots the wall of disks, the eigenvalues the bank returned and, optionally, eigenvalue trajectories coloured by delay and untrusted eigenvalues as empty grey boxes.
- Experiments: `pes39_common_margin.m` (margin with one common delay, for each computational mode and several probing sizes), `pes39_single_margin.m` (margin with only one stabiliser delayed, for each of the ten) and `pes39_dropone.m` (margin with one stabiliser undelayed, for each of the ten).
  They write `common_margin.csv`, `single_margin.csv` and `dropone.csv`.
- `pes39_sweep.m`: the bank at 201 common delays in \([0, 150]\) ms and at the margin; writes `bank_sweep.csv` and `bank_margin.csv`, with the residual of each eigenvalue and whether it is trusted.
  Run it after `pes39_common_margin.m` to reuse that margin.
- `pes39_single_sweep.m`: the same for the single delayed loop with the smallest margin; writes `single_sweep.csv` and `single_bank.csv`.
  Run it after `pes39_single_margin.m`.
- `pes39_spectra.m`: the spectrum at zero delay with and without the stabilisers; writes `spectra.csv`.
- Figures, from those CSVs only, each written to `docs/figures/pes39/` by its own script: `pes39_fig_margin.m` (`pes39_margin.png`, rightmost trusted eigenvalue against the common delay), `pes39_fig_bank.m` (`pes39_bank.png`, the bank at the common-delay margin with the trusted eigenvalues of the sweep coloured by delay and the untrusted ones as empty grey boxes), `pes39_fig_single_bank.m` (`pes39_single_bank.png`, the same for the worst single loop) and `pes39_fig_spectra.m` (`pes39_spectra.png`).
  `pes39_figures.m` runs all four.
- All scripts assume CIMTOOL's `src` is on the MATLAB path, as the other demos do.
