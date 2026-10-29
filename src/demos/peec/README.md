# PEEC neutral delay equation

The test circuit is from A. Bellen, N. Guglielmi and A. E. Ruehli, IEEE Trans. Circuits Syst. I 46(1), 1999, pp. 212–216.
A partial element equivalent circuit (PEEC) gives the neutral delay equation \(\dot y(t) = L y(t) + M y(t - \tau) + N \dot y(t - \tau)\) on three states, with \(T(\lambda, \tau) = \lambda(I - N e^{-\lambda\tau}) - L - M e^{-\lambda\tau}\).

## Files

- `milano_peec_1.m` is the companion to section 1 of `docs/examples/delay_systems.md`.
  On the ellipse centred at 0 with semi-axes 2 and 10 and \(10^4\) quadrature nodes, it realizes by multipoint Loewner with \(K = 500\), \(\ell = r = 3\) and the realization order chosen by `AutoRank`.
  It prints the eigenvalues inside the ellipse at \(\tau = 1\), then tracks them at 201 delays in \([0.2, 2]\) with the same probes and writes `peec_tau_sweep.csv`, with the relative residual of each eigenvalue.
  With the Control System Toolbox it also prints \(\|F\|_\infty\), the small-gain bound that shows stability for every delay.
- `peec_figures.m` plots `docs/figures/peec/tau_sweep.png` from that CSV, with untrusted eigenvalues (relative residual at least \(10^{-8}\)) as empty grey boxes.
- Both scripts assume CIMTOOL's `src` is on the MATLAB path, as the other demos do.
