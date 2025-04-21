# The Contour Integral Method (CIM) Tool

CIMTOOL is a graphical user interface created for the exploration
and application of contour integral methods to solve eigenvalue
problems.

## Requirements

- MATLAB r2022b+

## Installation

1. `git clone git@github.com:dan123222123/CIMTOOL.git`
2. In MATLAB do `addpatch(genpath("/path/to/CIMTOOL"))`
3. Check out scripts in `src/tutorial` or `src/demos`.

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
CTOOL = CIMTOOL(cim); % Try to refine the quadrature
```
