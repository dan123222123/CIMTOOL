# Networks of vibrating strings

The string networks come from J. P. Baker's nlevp_webs package, https://github.com/jpeterbaker/nlevp_webs, which accompanies the dissertation "Vibrations of mechanical structures: source localization and nonlinear eigenvalue problems for mode calculation" (Virginia Tech, 2023).
Every script here needs nlevp_webs and CIMTOOL's `src` on the MATLAB path.

## Files

- `tritare_web.m` is the companion to `docs/examples/webs.md` up to the orb-weaver section, with one cell per section in page order.
- `orb_web.m` covers the orb-weaver section, where the \(4964 \times 4964\) `spider2` web is sampled through sparse factorisations.
- `src/demos/tritare_simple.m`, one level up, loads the \(\theta = \pi/2\) tritare into the CIMTOOL GUI, in the style of `acoustic_wave_1d.m`.

An eigenpair counts as trusted when its relative residual is below \(10^{-8}\), and the figures draw untrusted eigenvalues as empty grey squares.
`tritare_web.m` and `orb_web.m` write their figures to `docs/figures/tritare/` unless `figdir` is set before running.
