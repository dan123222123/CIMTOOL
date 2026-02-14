# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CIMTOOL is a MATLAB-based graphical user interface for exploring and applying contour integral methods (CIM) to solve eigenvalue problems. The codebase implements three computational modes (Hankel, SPLoewner, MPLoewner) for system realization and eigenvalue computation.

## Requirements

- MATLAB r2022b or later
- Python 3.11+ (for documentation generation only)

## Development Setup

1. Clone and add to MATLAB path:
   ```matlab
   addpath(genpath("/path/to/CIMTOOL"))
   ```

2. For documentation (optional):
   ```bash
   conda create --name cimtool --file requirements.txt
   conda activate cimtool
   ```

## Running Tests

Tests are script-based and located in `tests/`. Run them directly in MATLAB:

```matlab
cd tests
testCIMEigensystemRealization
hankel_exactVquadrature
mploewner_exactVquadrature
sploewner_exactVquadrature
```

Tests verify mathematical correctness by comparing quadrature-based vs exact realization methods, checking that the greedy matching distance between computed and reference eigenvalues meets tolerance.

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
  - `@CIM/`: CIM class methods (compute, refineQuadrature, greedyMatchingDistance)
  - `@SampleData/`: Quadrature sampling logic
  - `+Contour/`: Contour types (Circle, Ellipse, CircularSegment, Quad)
  - `+mploewner/`, `+sploewner/`: Loewner framework implementations
  - `realize.m`, `realize_dbsvd.m`: System realization functions

- `src/+Visual/`: Reactive GUI wrappers
  - Parallel structure to `+Numerics` with plotting capabilities
  - All classes extend `Visual.VisualReactive` for plot management

- `src/+GUI/`: MATLAB App Designer components
  - `+Parameter/`: Parameter panel tabs (ContourTab, MethodTab, ShiftsTab, NLEVPTab)
  - `+Plot/`: Plot viewport components
  - Main panels: `LeftPanel`, `ParameterPanel`, `PlotPanel`, `Menu`

- `src/CIMTOOL.m`: Main application entry point

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

## Common Tasks

### Starting the GUI

```matlab
import Visual.*;
n = OperatorData([], 'omnicam1');
c = Contour.Circle(0.4, 0.2, 8);
cim = CIM(n, c);
CIMTOOL(cim);
```

### Running a Demo

```matlab
cd src/demos
acoustic_wave_1d  % or other demo files
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
```

### Accessing Results

```matlab
cim.compute();
eigenvalues = cim.ResultData.ew;
eigenvectors = cim.ResultData.rev;
gmd = cim.greedyMatchingDistance();  % matching distance to reference
```

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

### Running the Demo

```matlab
cd src/demos
modal_truncation_demo  % Complete workflow with visualization
```

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

## Important Notes

- When modifying `Numerics.*` classes, consider whether `Visual.*` wrappers need updates
- GUI reactivity depends on `SetObservable` properties; use listeners for auto-updates
- Contour refinement uses `refineQuadrature()` methods in both `SampleData` and `CIM` classes
- The `auto_update_shifts` and `auto_update_K` flags in `Numerics.CIM` control automatic parameter adjustment
