# CIMTOOL test suite

Script-based tests verifying the mathematical correctness of the `Numerics`
core. Run them directly in MATLAB.

## Quick start

```matlab
cd tests
run_numerics_tests        % runs the whole headless suite, reports pass/fail
```

`run_numerics_tests` bundles every headless test below, runs each in an isolated
workspace, prints a per-test PASS/FAIL line, and errors if any fail (so it works
from `matlab -batch "cd tests; run_numerics_tests"`). Each test also runs
standalone, e.g. `cd tests; test_realization`.

## What is covered

| Test | Focus |
|---|---|
| `test_quadrature` | Contour **quadrature weights/nodes**: residue theorem, Cauchy integral & derivative formulas, Cauchy–Goursat, orientation — for Circle / Ellipse / CircularSegment. Pins the `1/(2πi)` factor + parametrization derivatives the moment integrals rely on. |
| `test_contours` | Contour **geometry**: `inside()` truth tables (incl. branch-cut segments), refinement nesting (Circle/Ellipse) vs non-corruption (CircularSegment), cross-mode `tf()` sign consistency, SPLoewner shift relocation. |
| `test_metrics` | `matching_distance` (optimal vs greedy), `maxrelresidual` (standalone + CIM method). |
| `test_validation` | Input validation / informative errors on the main entry points: contour geometry, `RealizationSize`, `OperatorData`, `SampleData`, `CIM`, `ModalTruncation` — rejecting bad input at construction **and** on mutation. |
| `test_realization` | **GUI-free realization baseline** (ERA/Hankel, SPLoewner, MPLoewner): exact realization → reference spectrum; quadrature CIM → eigenvalues + residuals; block-moment/Hankel trade-off; SISO; `eigs()` interface; rectangular Loewner (unequal #θ/#σ) recovery. |
| `test_cim_state` | `CIM` state handling: construction, `copy`, display, reading `L`/`R` and an SPLoewner mode switch leave the random stream alone, and `compute` draws the directions; `copy`, `fromNumerics` and `toNumerics` keep `options`, shifts and the realization state; objects loaded from a MAT file or on a `parfor` worker keep their listeners; `SampleData` re-wires replaced contours and operators; `ell` or `r` = 0 gives a plain error; stale samples are refused and every invalidation marks the realization stale; parts that outlive a CIM do not keep it alive (weak references) and `delete` leaves them clean; replacing `SampleData` or `RealizationData` re-wires the listeners; `setComputationalMode(cm, size)`; data matrices kept after a refused realization; `options.RelTol`; N-independent Circle shifts and the `'trap'` phase; lowering `ell`/`r` after sampling reuses the samples; `OperatorData` copies. |
| `test_reference` | The reference eigenvalues of an NLEVP PEP, computed by `polyeig` on the background pool: a small problem finishes within `ReferenceWait`, a later result arrives through the callback or `waitReference`, `cancelReference` and a hand-set `refew` stop it, a second load drops the first result, `MaxReferenceSize` skips, a failure warns, and copies and MAT loads carry no running computation. Skips without NLEVP. |
| `test_rankrule` | Automatic realization order (`RealizationData.AutoRank`, `RankRule`): `Numerics.rankgap` on clean gaps, exact zeros, roundoff tails and geometric decay; the `Gap` rule realizes the 6-pole problem at \(m = 6\) in all three modes and records `ResultData.GapRatio`, also for a weak gap; `Tolerance` realizes at the numerical rank; zero data gives an empty realization; switching rule or options marks the realization stale and keeps the samples; copy, conversion and a MAT round trip keep the rule and the chosen \(m\). |
| `test_save_load_state` | Session save/load (`saveState`/`loadState`): function-handle, CircularSegment and NLEVP sessions round-trip with their samples and results and reload clean; custom MPLoewner shifts survive; partial structs and files saved before `AutoRank` load greedily, with missing options at their defaults; `AutoRank`, `RankRule`, the chosen \(m\) and `GapRatio` survive, also through `Visual.CIM.fromNumerics`/`toNumerics`. The NLEVP case skips without NLEVP. |
| `test_poresz` | Pole-residue transfer-function evaluation + derivatives. |
| `test_modal_truncation` | `H = H_region + H_residual` decomposition via `Numerics.ModalTruncation`. |
| `hankel_exactVquadrature` | Quadrature → exact convergence vs N (Hankel). |
| `sploewner_exactVquadrature` | Quadrature → exact convergence vs N (SPLoewner). |
| `mploewner_exactVquadrature` | Quadrature → exact convergence vs N (MPLoewner). |
| `test_tritare` | The tritare string network against its 30-digit transcendental spectrum, including multiple eigenvalues, whose multiplicity the Loewner rank must count. Skips without nlevp_webs. |

Each assertion in `test_quadrature` / `test_contours` / `test_realization` maps to a specific invariant or a fixed bug, so a regression turns a silent numerical drift into a loud failure.

## Not in the headless runner

- `test_pes39` and `test_gun` — heavy example tests (a download, and a
  \(9956 \times 9956\) sparse problem), kept out of CI. Run them with
  `run_numerics_tests("all")` or standalone.
- `testCIMEigensystemRealization` — launches the GUI (`CIMTOOL(...)`); the
  headless realization coverage lives in `test_realization` instead.
- `test_style_preferences_persistence` (`Visual.StylePreferences` in the MATLAB preferences) runs standalone only.
- GUI / `Visual.*` reactivity is not yet script-testable (open question: drive it
  via App Testing Framework actions).

## Determinism

Most tests seed `rng` before drawing random data. `test_realization` additionally fixes the probing
directions (identity / scalar) and the SPLoewner shift so the realization is
fully reproducible; the random-probing path stays exercised by the
`*_exactVquadrature` convergence scripts.
