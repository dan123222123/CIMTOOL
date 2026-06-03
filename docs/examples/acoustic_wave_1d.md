---
jupyter: mkernel
---


``` matlab
% Project root is the execute-dir; add src to path.
pwd
```


    ans =

        '/home/dfolescu/version_control/git/math/CIMTOOL'

``` matlab
% Project root is the execute-dir; add src to path.
getenv("QUARTO_PROJECT_DIR")
```


    ans =

        '/home/dfolescu/version_control/git/math/CIMTOOL'

``` matlab
% Project root is the execute-dir; add src to path.
addpath(genpath('~/version_control/git/math/CIMTOOL/src/'))
```

## Description

Quadratic eigenvalue problem (QEP) that arises from the wave equation on $ \[0, 1\] $:

$$ \frac{d^2 p}{d x^2} + 4 \pi^2 \lambda^2 p = 0, \quad p(0) = 0, \quad \chi p'(1) + 2 \pi i \lambda p(1) = 0. $$

*p* is the acoustic pressure, *λ* is the frequency, and *χ* is the impedance.

We aim to find eigenpairs (*λ*, *x⃗*) such that

$$ \mathbf{T}(\lambda) \vec{x} = \vec{0} $$

where

**T**(*λ*) = *λ*<sup>2</sup>**M** + *λ***D** + **K**,  **M**, **K** ∈ ℝ<sup>*n* × *n*</sup>, **D** ∈ ℂ<sup>*n* × *n*</sup>.

## Getting Started

We put *N* = 506, *χ* = 1.0001, and let *Ω* = ℬ(0.8*i*, 10) be the circular contour centered at *γ* = 0.8*i* with radius *ρ* = 10 and 128 quadrature nodes.

``` matlab
N = 506; Xi = 1.0001;
n = Numerics.OperatorData([], 'acoustic_wave_1d', sprintf("%f,%f", N, Xi));
c = Numerics.Contour.Circle(0.8i, 10, 128);
cim = Numerics.CIM(n, c); cim.options.Verbose = false;
```

Reference eigenvalues can be computed explicitly as

$$ \lambda_k = \frac{\tan^{-1}(i \chi)}{2 \pi} + \frac{k}{2}, \quad k \in \mathbb{Z} $$

when $ ^{-1}(i ) $ is defined.

``` matlab
nref = 50; refew = zeros(2*nref+1, 1);
for k = -nref:nref
    refew(k+nref+1) = atan(1i*Xi)/(2*pi) + k/2;
end
n.refew = refew;
```

**T** is meromorphic with *m* = 40 simple poles in *Ω*. Hankel and MPLoewner-based CIMs build up relevant data matrices and utilize a rank-*m* truncated SVD, where, with exact data, *m* is exactly the number of poles of **T** within *Ω* (counting multiplicities). Inexact data is derived through contour integration of *f*<sub>*k*</sub>(*z*)(\[**T**(*z*)\]<sup>−1</sup>), approximated via quadrature rule. *f*<sub>*k*</sub>(*z*) depends on the choice of Hankel/SPLoewner/MPLoewner formulations and, in the case of the latter two, on the choice of shift *σ*. In practice, left (**L** ∈ ℂ<sup>*n* × *ℓ*</sup>) and right (**R** ∈ ℂ<sup>*n* × *r*</sup>) probing matrices are used to reduce the computational burden of full inversion of **T** at each quadrature node, so that the integrand becomes *f*<sub>*k*</sub>(*z*)(**L**<sup>\*</sup>\[**T**(*z*)\]<sup>−1</sup>**R**).

## Example

We set *m* = 40, *ℓ* = *r* = 15, and choose *K* so that 𝔻, 𝔻<sub>𝕤</sub> ∈ ℂ<sup>60 × 60</sup>.

``` matlab
p = 15; cim.SampleData.ell = p; cim.SampleData.r = p;
cim.RealizationData.m = 42
```


    cim = 

      CIM with properties:

                SampleData: [1×1 Numerics.SampleData]
           RealizationData: [1×1 Numerics.RealizationData]
                ResultData: [1×1 Numerics.ResultData]
             DataDirtiness: 2
        auto_update_shifts: 1
             auto_update_K: 1
                   options: [1×1 struct]

### Hankel

To use Hankel realization, set the computational mode and the number of moments *K* used to build 𝔻:

``` matlab
cim.setComputationalMode(Numerics.ComputationalMode.Hankel);
cim.RealizationData.K = 4;  % p * K = 15 * 4 = 60
cim.compute();
fprintf('MRR: %.4e\n', max(Numerics.relres(n.T, cim.ResultData.ew, cim.ResultData.rev, Numerics.SampleMode.Inverse)))
```

    MRR: 2.2976e-05

### MPLoewner

We switch to MPLoewner, where *K* now represents the number of shifts used to construct 𝔻:

``` matlab
cim.setComputationalMode(Numerics.ComputationalMode.MPLoewner);
cim.RealizationData.K = 4*p;  % 60 shifts
cim.compute();
fprintf('MRR: %.4e\n', max(Numerics.relres(n.T, cim.ResultData.ew, cim.ResultData.rev, Numerics.SampleMode.Inverse)))
```

    MRR: 1.3077e-06
