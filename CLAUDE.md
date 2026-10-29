# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CIMTOOL is a MATLAB-based graphical user interface for exploring and applying contour integral methods (CIM) to solve eigenvalue problems. The codebase implements three computational modes (Hankel, SPLoewner, MPLoewner) for system realization and eigenvalue computation.

## Requirements

- MATLAB r2024b or later
- Python 3.11+ (for documentation generation only)

## Development Setup

1. Clone and add to MATLAB path:
   ```matlab
   addpath(genpath("/path/to/CIMTOOL"))
   ```

2. For documentation (optional), `nix develop` enters a shell whose `.venv-docs` holds mkdocs, mkdocs-material, mkdocstrings-matlab and mkdocs-awesome-nav (built by `scripts/ensure-venv.sh docs`).
   `mkdocs serve` previews the site and `mkdocs build` writes it to `site/`.
   No MATLAB is needed: mkdocstrings-matlab parses `src/` statically.
   `requirements.txt` is an older conda environment for the same stack.

## Running Tests

Tests are script-based and located in `tests/`; `tests/README.md` describes each one.

```matlab
cd tests
run_numerics_tests          % the headless suite, as CI would run it
run_numerics_tests("all")   % also test_pes39 (downloads on first run) and test_gun (n = 9956)
test_realization            % any test also runs standalone
```

`testCIMEigensystemRealization` launches the GUI and is not in the runner.
`test_style_preferences_persistence` runs standalone only.
`test_reference` and `test_gun` skip without NLEVP; `test_tritare` skips without nlevp_webs.
`scripts/ci-local.sh` mirrors the CI jobs locally, and `scripts/ci-local.sh realtest [all]` runs `run_numerics_tests`, which CI does not run yet.

## Architecture

### Core Layer Structure

The codebase uses a dual-namespace architecture:

- **`+Numerics`**: Computational core (no GUI dependencies)
  - Pure numerical algorithms for CIM methods
  - Operator data handling and sampling
  - System realization algorithms (Hankel/SPLoewner/MPLoewner)

- **`+Visual`**: GUI-enabled extensions
  - Wraps `Numerics` classes with reactive plotting capabilities
  - All `Visual.*` classes inherit from corresponding `Numerics.*` classes
  - Adds `SetObservable` properties for GUI reactivity

### Key Class Hierarchy

```
Numerics.CIM (computational core)
  ├── SampleData (operator sampling on contours)
  ├── RealizationData (realization parameters)
  └── ResultData (computed eigenvalues/eigenvectors)

Visual.CIM (GUI-reactive version)
  └── extends Numerics.CIM
      └── used by CIMTOOL (main GUI app)
```

### Component Organization

- `src/+Numerics/`: Core numerical methods
  - `@CIM/`: CIM class methods (`computeDataMatrices`/`buildDataMatrices`, `computeRealization`, `refineQuadrature`, `matchingDistance`, `maxrelresidual`, `toStruct`/`fromStruct`/`saveState`/`loadState`)
  - `@SampleData/`: Quadrature sampling logic
  - `+Contour/`: Contour types (Circle, Ellipse, CircularSegment, Quad)
  - `+mploewner/`, `+sploewner/`: Loewner framework implementations
  - `realize.m`, `realize_dbsvd.m`: System realization functions
  - `RankRule.m`, `rankgap.m`, `rankdet.m`, `momentlevel.m`: automatic realization order (see below)
  - `weakListener.m`: PostSet listener that does not keep its owner alive

- `src/+Visual/`: Reactive GUI wrappers
  - Parallel structure to `+Numerics` with plotting capabilities
  - All classes extend `Visual.VisualReactive` for plot management
  - `emptyHandles.m` lets `Visual` objects be built on a thread-based worker, where graphics classes are unavailable

- `src/+GUI/`: MATLAB App Designer components
  - `+Parameter/`: Parameter panel tabs (ContourTab, MethodTab, ShiftsTab, NLEVPTab)
  - `+Plot/`: Plot viewport components
  - Main panels: `LeftPanel`, `ParameterPanel`, `PlotPanel`, `Menu`
  - `SubObjectListener.m`: a listener on a property path such as `SampleData.Contour` that follows replaced sub-objects; panels use it instead of binding to one instance

- `src/CIMTOOL.m`: Main application entry point

- `src/demos/`: worked examples, one folder per example (`3bus`, `gun`, `peec`, `pes39`, `webs`), each with a README; see Demos below

### Data Flow

1. **OperatorData**: Defines the eigenvalue problem (transfer function T or NLEVPack problem)
2. **Contour**: Specifies integration contour in complex plane
3. **SampleData**: Samples operator on contour points (quadrature or exact)
4. **RealizationData**: Configures computational mode and interpolation parameters
5. **CIM.compute()**: Samples data → performs realization → stores results
6. **ResultData**: Contains computed eigenvalues/eigenvectors

### Computational Modes

Three system realization methods accessed via `Numerics.ComputationalMode`:

- **Hankel**: Classical Hankel matrix approach
- **SPLoewner**: Single-point Loewner framework
- **MPLoewner**: Multi-point Loewner framework

Mode selection affects interpolation data requirements and realization matrix construction.

### Property Reactivity

The `DataDirtiness` property in `Numerics.CIM` tracks when recomputation is needed:
- `>1`: Resample required
- `>0`: Realization required
- `=0`: Results up-to-date

Listeners automatically update this when parameters change. GUI uses this for selective updates.

CIM listeners on `SampleData`, `RealizationData` and the contour are weak (`Numerics.weakListener`), so parts that outlive a CIM do not keep it alive.
Replacing a part re-wires the listeners, and objects loaded from a MAT file or sent to a `parfor` worker re-attach theirs in `loadobj`.

### Random Probing Directions

Constructing, copying or displaying a CIM leaves the random stream alone.
`compute` draws the probing directions `L` and `R` when none are set.
For reproducible results, call `rng(seed)` once and set `cim.SampleData.L` and `cim.SampleData.R` explicitly, as the demos do.

### Realization Order

With `RealizationData.AutoRank = false` (the default), the realization order is `RealizationSize.m`.
With `AutoRank = true`, `computeRealization` chooses `m` from the singular values of the base data matrix `Db` by `RealizationData.RankRule`:

- `Gap` (default): `m` sits at the largest gap \(\sigma_m/\sigma_{m+1}\) (`Numerics.rankgap`), and `ResultData.GapRatio` records it; a gap below `options.GapMin` (\(10^3\)) is weak but still used, with a warning under `options.Verbose`.
- `Tolerance`: `m` is the numerical rank under `options.AbsTol` and `options.RelTol` (`Numerics.rankdet`).

Under `AutoRank`, a contour whose moment level (`cim.contourMomentLevel`, `Numerics.momentlevel`) is below `options.EmptyTol` (\(10^{-10}\)) is read as empty, with `m = 0`.
`ResultData.m` is the order actually used.
After a GUI compute with a weak gap, a dialog offers to switch to manual `m` at that value.

### Reference Eigenvalues

For an NLEVP polynomial problem, `OperatorData` computes reference eigenvalues `refew` by `polyeig` on the background pool.
A result within `ReferenceWait` (5 s) is set before the load returns, and a later one is set when it arrives.
`ReferenceStatus`, `waitReference` and `cancelReference` expose the computation, and the left panel shows the status with a cancel button.
No automatic reference is computed when \(n d\) exceeds `MaxReferenceSize` (500), and setting `refew` by hand cancels a running one.

## Common Tasks

### Starting the GUI

```matlab
import Visual.*;
n = OperatorData([], 'omnicam1');
c = Contour.Circle(0.4, 0.2, 8);
cim = CIM(n, c);
CIMTOOL(cim);
```

`CIMTOOL()`, `Numerics.CIM()` and `Visual.CIM()` start with an empty contour.
Shifts wait for a contour, Compute or Refine without one shows a message in the GUI, and the contour type buttons build a default contour.
`CIMTOOL(cim)` with a `Numerics.CIM` converts it by `Visual.CIM.fromNumerics`.

### Running a Demo

```matlab
cd src/demos
acoustic_wave_1d          % opens the GUI on a configured CIM; so does tritare_simple
run peec/milano_peec_1    % the example folders hold the gallery computations
```

### Testing Computational Modes

```matlab
% Setup
cim.SampleData.ell = 3;
cim.SampleData.r = 3;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(3, 3);

% Try different modes
cim.setComputationalMode(Numerics.ComputationalMode.Hankel)
cim.compute();

cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner)
cim.compute();

% Mode and size in one call; the samples are kept
cim.setComputationalMode(Numerics.ComputationalMode.SPLoewner, Numerics.RealizationSize(3, 4))
cim.computeRealization();

% Realization order from the largest singular-value gap
cim.RealizationData.AutoRank = true;
cim.compute();
```

### Accessing Results

```matlab
cim.compute();
eigenvalues = cim.ResultData.ew;
eigenvectors = cim.ResultData.rev;
[V, D] = cim.eigs();                 % computes if needed; sorted by modulus, unit-norm V
mrr = cim.maxrelresidual();          % maximum relative residual of the computed eigenpairs
inside = cim.SampleData.Contour.inside(diag(D));
nmd = cim.matchingDistance();        % matching distance to OperatorData.refew
```

To evaluate one CIM at many parameter values, as the delay demos do, keep the CIM and assign `op.T`; each assignment resamples on the same contour with the same probes and shifts.

## File Naming Conventions

- `+PackageName/`: MATLAB package (namespace)
- `@ClassName/`: MATLAB class methods folder
- `*Component.m`: GUI components in `+GUI` hierarchy
- `*Tab.m`: Tab panels in parameter interface
- `*Data.m`: Data container classes

## Modal Truncation

CIMTOOL supports **modal truncation**, a technique for isolating spectral regions of a transfer function using contour integral methods. This enables data-driven decomposition of a system into regional components without requiring prior knowledge of eigenvalue locations.

### Workflow

Modal truncation approximates the contribution of eigenvalues within a user-chosen contour:

1. **Given**: Transfer function `H(z)` (function handle that can be evaluated at any point)
2. **Choose**: Contour to select spectral region of interest (Circle, Ellipse, CircularSegment, etc.)
3. **Compute**: CIM approximates `H_region(z)` representing spectrum inside the contour
4. **Extract**: Residual `H_residual(z) = H(z) - H_region(z)` isolates the complementary region

### Example: Isolating Unstable Subsystem

```matlab
% Given: Transfer function (could be from measurements, models, etc.)
H = @(z) ...; % Full transfer function

% Choose circular segment to isolate right half-plane (unstable region)
contour = Numerics.Contour.CircularSegment(...
    0.2,           % center
    0.7,           % radius
    [-pi/2, pi/2], % angular range (RHP)
    [32; 32]       % quadrature points [arc; chord]
);

% Configure realization parameters
rd = Numerics.RealizationData();
rd.RealizationSize = Numerics.RealizationSize(2, 5, 5);
rd.ComputationalMode = Numerics.ComputationalMode.MPLoewner;

% Create and compute modal truncation
mt = Numerics.ModalTruncation(H, contour, rd);
mt.compute();

% Extract subsystems
H_unstable = mt.getRegionTransferFunction();   % Approx. of RHP spectrum
H_stable = mt.getResidualTransferFunction();   % H - H_unstable
ew_computed = mt.getRegionEigenvalues();       % Computed eigenvalues in region
```

### Key Features

- **Data-driven**: No prior knowledge of eigenvalue locations required
- **Flexible contours**: Any contour type supported (Circle, Ellipse, CircularSegment, Quad)
- **User control**: User explicitly chooses region based on problem knowledge
- **Clean decomposition**: Guarantees `H(z) = H_region(z) + H_residual(z)`
- **Export-friendly**: Returns function handles for further analysis or model order reduction

### Testing

```matlab
cd tests
test_poresz              % Test pole-residue evaluation utilities
test_modal_truncation    % Test modal truncation workflow
```

### Related Utilities

- **`Numerics.poresz(z, ew, B, C, deriv)`**: Evaluate transfer function in pole-residue form
  - `deriv=0`: Function value (default)
  - `deriv=1`: First derivative
  - `deriv=2`: Second derivative, etc.
- **`ResultData.getTransferFunction(deriv)`**: Extract transfer function handle from CIM results

## Saving and Loading Sessions

CIMTOOL can serialize a full CIM session to a `.mat` file so a configured example
can be shared and reopened exactly, without re-running a setup script.

### In the GUI

- **File → Save State...** (Ctrl+S): writes the current session to a `.mat` file.
- **File → Load State...** (Ctrl+O): loads a `.mat` session and relaunches the GUI in a fresh window.

### Programmatically

```matlab
cim.saveState("session.mat");            % Numerics.CIM (or Visual.CIM) -> file
cim2 = Numerics.CIM.loadState("session.mat");
```

### Design

- `Numerics.CIM.toStruct` / `fromStruct` (`@CIM/`) convert the object graph to/from a
  plain versioned struct; `saveState`/`loadState` wrap file I/O (`-v7.3` .mat).
- **Greedy load**: `fromStruct` restores every field that is present and valid and
  falls back to constructor defaults (with a warning) for anything missing or broken,
  so partial/older files still load into a usable session.
- **Operators**: NLEVP problems persist as `name`+`arglist` and regenerate via `nlevp`
  on load; raw function-handle operators are stored natively in the `.mat`.
- **Contours** persist by generating parameters (nodes/weights regenerate).
- Cached quadrature samples and computed results are saved too, so a reloaded session
  is clean (`DataDirtiness == 0`) and needs no recompute.
- `AutoRank`, `RankRule`, `ResultData.m` and `GapRatio` are saved.
  A file saved before `AutoRank` loads with it off, its `ranktol` field is ignored (no computation ever read it), and options missing from a file keep their defaults.
- Tests: `tests/test_save_load_state.m`.

## Important Notes

- When modifying `Numerics.*` classes, consider whether `Visual.*` wrappers need updates
- GUI reactivity depends on `SetObservable` properties; use listeners for auto-updates
- Contour refinement uses `refineQuadrature()` methods in both `SampleData` and `CIM` classes
- The `auto_update_shifts` and `auto_update_K` flags in `Numerics.CIM` control automatic parameter adjustment

## Demos

`src/demos/acoustic_wave_1d.m` and `src/demos/tritare_simple.m` open the GUI on a configured CIM.
The example folders hold the computations behind the gallery pages in `docs/examples/`, and each has a README:

| Folder | Example | Page |
|---|---|---|
| `peec` | PEEC neutral delay equation | `delay_systems.md`, section 1 |
| `3bus` | Milano three-bus system with a delayed stabiliser | `delay_systems.md`, section 2 |
| `pes39` | IEEE PES 39-bus benchmark with ten delayed loops; downloads its data into the git-ignored `cache/` | `delay_systems.md`, section 3 |
| `gun` | NLEVP gun problem, Hankel against single- and multipoint Loewner | `gun.md` |
| `webs` | String networks from nlevp_webs | `webs.md` |

Conventions for demo scripts:

- In `peec`, `3bus`, `pes39` and `gun`, compute scripts write CSVs next to themselves (git-ignored), and separate `*_figures.m` or `*_fig_*.m` scripts plot from those CSVs only, into `docs/figures/<example>/`.
  The `webs` scripts write their figures directly, to `docs/figures/tritare/`.
- Use CIMTOOL's own features: `AutoRank` for \(m\), `Contour.inside`, `cim.eigs`, `cim.maxrelresidual`, one CIM reused across parameter values through `op.T`, fixed probes set through `SampleData.L`/`R` after one `rng(seed)`, and `OperatorData([], name)` for NLEVP problems.
- Every eigenvalue found inside a contour keeps its relative residual.
  Below \(10^{-8}\) it is trusted, decisions such as margins use trusted eigenvalues only, and figures draw untrusted ones as empty grey boxes (marker `s`, no fill, edge `[0.6 0.6 0.6]`).
- Parameter sweeps use 201 points, and `fzero` refines any reported margin.
- Comments are a short header plus block-level comments, with no line-by-line explanation and no history.

## Documentation

The site is mkdocs-material, configured in `mkdocs.yml`, with the API pages generated from docstrings by mkdocstrings-matlab.
CI (`.github/workflows/ci.yml`) deploys it to `gh-pages` on a push to `main`.
Code shown on a page comes from `% --8<-- [start:name]` and `% --8<-- [end:name]` markers in the demo scripts, included by `pymdownx.snippets` inside `??? note` blocks rather than copied.
`check_paths: true` makes a missing snippet file or section fail the build.
Figures live under `docs/figures/`, which `.gitignore` exempts from its image patterns.

## Documentation Style

For Markdown and other writing-heavy files (docs, `.md`), use
**one sentence per line** — each sentence on its own source line, with no fixed-width
wrapping. This keeps `git diff`s minimal (editing one sentence touches one line) and
reflows nothing when prose changes. Rendered output is unaffected, since Markdown
collapses single newlines within a paragraph to spaces.

- Applies to prose only. Leave code blocks, display-math (`\[ ... \]`), tables,
  and (optionally) footnote definitions wrapped as-is.
- This is a documentation convention, **not** a code convention — MATLAB/`.m`
  source keeps its normal line structure.
