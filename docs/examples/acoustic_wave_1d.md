
# Acoustic Wave 1D (acoustic_wave_1d)[^1]

## Description

Quadratic eigenvalue problem (QEP) that arises from the wave equation on \( [0, 1] \):

\[ \frac{d^2 p}{d x^2} + 4 \pi^2 \lambda^2 p = 0, \quad p(0) = 0, \quad \chi p'(1) + 2 \pi i \lambda p(1) = 0. \]

\(p\) is the acoustic pressure, \( \lambda \) is the frequency, and \( \chi \) is the impedance.

We aim to find eigenpairs \( (\lambda,\vec{x}) \) such that

\[ \mathbf{T}(\lambda) \vec{x} = \vec{0} \]

where

\[ \mathbf{T}(\lambda) = \lambda^2 \mathbf{M} + \lambda \mathbf{D} + \mathbf{K}, \quad \mathbf{M},\mathbf{K} \in \mathbb{R}^{n \times n}, \mathbf{D} \in \mathbb{C}^{n \times n}. \]

## Getting Started

We put $N = 500, \chi = 1.0001$, and let $\Omega = \mathcal{B}(0.8i,10)$ be the circular contour centered at $\gamma = 0.8i$ with radius $\rho = 10$.

``` matlabsession
>> N = 500; chi = 1.0001;
>> nlevp = Numerics.NLEVPData(missing,'acoustic_wave_1d',sprintf("%f,%f",N,chi));
>> contour = Numerics.Contour.Circle(0.8i,10);
>> CIM = Numerics.CIM(nlevp,contour)
```

/// details | Output

``` matlabsession
CIM =

  CIM with properties:

                  SampleData: [1×1 Numerics.SampleData]
             RealizationData: [1×1 Numerics.RealizationData]
                  ResultData: [1×1 Numerics.ResultData]
               DataDirtiness: 2
                      MainAx: <missing>
                        SvAx: <missing>
                        auto: 0
        auto_compute_samples: 0
    auto_compute_realization: 0
             auto_estimate_m: 0
          auto_update_shifts: 1
               auto_update_K: 1
```

///

Reference eigenvalues can be computed explicitly as

\[ \lambda_k = \frac{\tan^{-1}(i \chi)}{2 \pi} + \frac{k}{2}, \quad k \in \mathbb{Z} \]

when \( \tan^{-1}(i \chi) \) is defined.

/// details | Computing Reference Eigenvalues

``` matlab
nref = 50; refew = zeros(2*nref,1);
for k=-nref:nref
    refew(k+nref+1) = atan(1i*chi)/(2*pi) + k/2;
end
CIM.SampleData.NLEVP.refew = refew;
```

///

$\mathbf{T}$ is meromorphic with $m = 40$ simple poles in $\Omega$.
Hankel and MPLoewner-based CIMs build up relevant data matrices and utilize a rank-$m$ truncated SVD, where, with exact data, $m$ is exactly the number of poles of $\mathbf{T}$ within $\Omega$ (counting multiplicities).
Inexact data is derived through contour integration of $f_k(z) \left( \left[ \mathbf{T}(z) \right]^{-1} \right)$, approximated via quadrature rule.
$f_k(z)$ depends on the choice of Hankel/SPLoewner/MPLoewner formulations and, in the case of the latter two, on the choice of shift $\sigma$.
In practice, left ($\mathbf{L} \in \mathbb{C}^{n \times \ell}$) and right ($\mathbf{R} \in \mathbb{C}^{n \times r}$) probing matrices are used to reduce the computational burden of full inversion of $\mathbf{T}$ at each quadrature node, so that the integrand becomes $f_k(z) \left( \mathbf{L}^* \left[ \mathbf{T}(z) \right]^{-1} \mathbf{R} \right)$.

## Example

We set $m = 40, \ell = r = 15$, and choose $K$ so that $\mathbb{D},\mathbb{D_s} \in \mathbb{C}^{60 \times 60}$.

```matlabsession
>> CIM.SampleData.Contour.N = 128;
>> p = 15; CIM.SampleData.ell = p; CIM.SampleData.r = p; % left/right sampling dimensions with L and R taken to be real i.i.d, by default
>> CIM.SampleData.compute(); % samples the quadrature given N and ell=r
>> CIM.RealizationData.m = 40; % independent of quadrature data
```

### Hankel

To use Hankel realization, we set need to specify it and the number of moments, $K$, used to build $\mathbb{D}$:

``` matlabsession
>> CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
>> CIM.RealizationData.K = 4; % 60 / p = 4
>> CIM.compute();
```

Finally, we can find the maximum relative residual (MRR) of the computed eigenpairs:

``` matlabsession
>> max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev))
ans =

   3.8029e-05
```

/// admonition | Note
Since we previously computed `#!matlab CIM.SampleData`, `#!matlab CIM.compute()` only performs the system realization/spectral identification.
///

### MPLoewner

We switch computational modes to MPLoewner where $K$ now represents the number of shifts used in construction of $\mathbb{D}$:

```matlabsession
>> CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner; % implicitly sets default shifts relative to the contour
>> CIM.RealizationData.K = 4*p; % 4 * 15 = 60
>> CIM.compute();
>> max(Numerics.relres(nlevp.T,CIM.ResultData.ew,CIM.ResultData.ev))
ans =

   4.2943e-05
```

<!---

- For $N=128$, Hankel and MPLoewner yield a roughly equivalent maximum relative residual (MRR) -- $4.4*10^{-5}$ and $3.9*10^{-5}$, respectively.
- MRR does not decrease to below $\sim 10^{-10}$ for Hankel until $N = 32768$. For MPLoewner, the MRR is below $\sim 10^{-12}$ for the same $N$.

/// admonition | Note
If we desire a larger $N$, it is possible to _refine_ the quadrature using `#!matlab CIM.refineQuadrature()`.
This method doubles the original number of quadrature nodes while re-using the previously computed sample data on a subset of the new quadrature nodes.
///

- These results appear to mirror those produced by polyeig, but at a hefty cost in numerical quadrature.

### $m = 42$

/// admonition | Note
Note that, if we increase $m$ to $42$, both Hankel and MPLoewner realizations no longer align with the prescribed rank truncation as in the case of exact data. In particular, two more eigenvalues than the number of reference eigenvalues within $\Omega$ are recovered.
This is only possible because the data matrices are being computed _inexactly_; that is, with sufficiently large $N$, the numerical rank of $\mathbb{D}$ will be smaller than $42$, and the algorithms will fail to construct a sufficient-rank $\mathbb{D}$.
///

- Interestingly, many fewer quadrature nodes (less than $512$) are necessary to achieve MRR near machine precision for both Hankel and MPLoewner. A similar gap in the MRR between Hankel and MPLoewner is present in this case (about two orders of magnitude).
- Even with only $N = 128$ quadrature nodes, MPLoewner appears to more accurately match computed eigenvalues to the underlying reference (in the eyeball norm).
- SPLoewner with $\sigma = -13i$ produces results comparable to MPLoewner.
- For $N = 128$, in both Hankel and MPLoewner cases the singular values after position 44/42 of the data matrix are "paired", and enlarging $m$ in steps of two appears to improve the MRR of the "target eigenvalues" (those within the contour).

-->

[^1]: F. Chaitin-Chatelin and M. B. van Gijzen, “Analysis of parameterized quadratic eigenvalue problems in computational acoustics with homotopic deviation theory,” Numerical Linear Algebra with Applications, vol. 13, no. 6, pp. 487–512, 2006, doi: 10.1002/nla.484.
