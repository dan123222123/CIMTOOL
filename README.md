# The Contour Integral Method (CIM) Tool

CIMTOOL is a graphical user interface created for the exploration
and application of contour integral methods to solve eigenvalue
problems.

## NSF Award Information

<img src="./figures/NSF_Official_logo_CMYK.png" width="100" height="100" align="left" /> This project is supported by the National Science Foundation Grant DMS-241141, Nonlinear eigenvalue problems: A new paradigm through the lens of systems theory and rational interpolation, Co-PIs: M. Embree and S. Gugercin, Aug 1, 2024 – July 31, 2027

## Requirements

- MATLAB r2022b+

## Installation

1. `git clone git@github.com:dan123222123/CIMTOOL.git`
2. In MATLAB run `addpath(genpath('/path/to/CIMTOOL'))`

## Quick Start

```matlab
import Visual.*;
%
n = OperatorData([],'omnicam1');
c = Contour.Circle(0.4,0.2,8);
cim = CIM(n,c);
%
cim.SampleData.ell = 3; cim.SampleData.r = 3;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(3,3);
cim.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
%
CTOOL = CIMTOOL(cim)
```

Check out additional scripts and demos under `src/tutorial` or `src/demos`.