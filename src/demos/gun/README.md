# NLEVP gun problem

The gun problem models a radio-frequency gun cavity.
It is in the NLEVP collection of T. Betcke, N. J. Higham, V. Mehrmann, C. Schröder and F. Tisseur (ACM TOMS 39(2), 2013), https://github.com/ftisseur/nlevp, which must be on the MATLAB path.

## Files

- `gun_nlevp.m` is the companion to `docs/examples/gun.md`, inspired by Fig. 7 of Brennan, Embree and Gugercin (SIAM Rev. 2023, Sec. 5.4).
  On the disk \(|\lambda - 141000| < 30000\), which holds 17 eigenvalues, it compares Hankel, single-point Loewner and multipoint Loewner at \((K, r) = (2, 16), (4, 8), (8, 4)\), every data matrix \(32 \times 32\).
  The trapezoid rule starts at 16 nodes and doubles to 1024, sampling only the new nodes, and every method and case is realized from the same samples at each level.
  The probing directions are drawn once after `rng(42)`.
  It writes `gun_residuals.csv`, `gun_singular_values.csv`, `gun_points.csv` and `gun_eigenvalues.csv`.
- `gun_figures.m` plots `docs/figures/gun/methods.png` from those CSVs, without recomputing.
