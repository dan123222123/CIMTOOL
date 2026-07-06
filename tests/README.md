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
| `test_poresz` | Pole-residue transfer-function evaluation + derivatives. |
| `test_modal_truncation` | `H = H_region + H_residual` decomposition via `Numerics.ModalTruncation`. |
| `hankel_exactVquadrature` | Quadrature → exact convergence vs N (Hankel). |
| `sploewner_exactVquadrature` | Quadrature → exact convergence vs N (SPLoewner). |
| `mploewner_exactVquadrature` | Quadrature → exact convergence vs N (MPLoewner). |

Each assertion in `test_quadrature` / `test_contours` / `test_realization` maps
to a specific invariant or a fixed/known bug (see `PRELIM_REVIEW.md`), so a
regression turns a silent numerical drift into a loud failure.

## Not in the headless runner

- `testCIMEigensystemRealization` — launches the GUI (`CIMTOOL(...)`); the
  headless realization coverage lives in `test_realization` instead.
- GUI / `Visual.*` reactivity is not yet script-testable (open question: drive it
  via App Testing Framework actions).

## Determinism

Tests seed `rng(0)`. `test_realization` additionally fixes the probing
directions (identity / scalar) and the SPLoewner shift so the realization is
fully reproducible; the random-probing path stays exercised by the
`*_exactVquadrature` convergence scripts.
