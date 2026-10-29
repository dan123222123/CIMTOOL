# Milano three-bus system with a delayed stabiliser

The model is Example 11.1 of F. Milano, *Eigenvalue Problems in Power Systems* (CRC Press, 2020).
A power system stabiliser (PSS) on machine 1 reads the rotor speed \(\omega_{r,1}(t - \tau)\), giving \(T(\lambda, \tau) = \lambda I - A_0 - A_1 e^{-\lambda\tau}\) on 23 states.

## Files

- `As_base_3bus.m`: the \(19 \times 19\) state matrix \(A_S\) of the book's Appendix B, without the PSS.
- `milano_3bus_ex11_1.m`: appends the wash-out and three lag states of eq. (1.146) and forms `A0`, `A1` and `T`.
- `milano_3bus_spectra.m`: the spectrum at zero delay with and without the PSS; writes `spectra.csv`.
- `milano_3bus_sweep.m`: one CIM on the circle \(|z - (-0.5 + 4i)| = 2.6\), with fixed probes and the realization order chosen by `AutoRank`, reused at 201 delays from 0 to 250 ms, and the delay margin refined by `fzero`; writes `sweep.csv` and `margin.csv`.
  Every eigenvalue inside the circle is kept with its relative residual, the `relres` column of `sweep.csv`, and only those below \(10^{-8}\) decide the margin.
- Figures, from those CSVs only, written to `docs/figures/milano_3bus/`: `milano_3bus_fig_spectra.m` (`spectra.png`) and `milano_3bus_fig_margin.m` (`delay_margin.png`).
  `milano_3bus_figures.m` runs both.
- All scripts assume CIMTOOL's `src` is on the MATLAB path, as the other demos do.
