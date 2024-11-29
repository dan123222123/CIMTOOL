
# Acoustic Wave 1D (acoustic_wave_1d)

## Description

Quadratic eigenvalue problem (QEP) that arises from the wave equation on \( [0, 1] \):

\[ \frac{d^2 p}{d x^2} + 4 \pi^2 \lambda^2 p = 0, \quad p(0) = 0, \quad \chi p'(1) + 2 \pi i \lambda p(1) = 0. \]

\(p\) is the acoustic pressure, \( \lambda \) is the frequency, and \( \chi \) is the impedance.

We aim to find eigenpairs \( (\lambda,\vec{x}) \) such that

\[ \mathbf{T}(\lambda) \vec{x} = \vec{0} \]

where

\[ \mathbf{T}(\lambda) = \lambda^2 \mathbf{M} + \lambda \mathbf{D} + \mathbf{K}, \quad \mathbf{M},\mathbf{K} \in \mathbb{R}^{n \times n}, \mathbf{D} \in \mathbb{C}^{n \times n}. \]

Reference eigenvalues can be computed explicitly as

\[ \lambda_k = \frac{\tan^{-1}(i \chi)}{2 \pi} + \frac{k}{2}, \quad k \in \mathbb{Z} \]

when \( \tan^{-1}(i \chi) \) is defined.

## Method

We put $n = 500$ and $\chi = 1.0001$.

Let $\Omega = \mathcal{B}(0.8i,10)$ be the circular contour centered at $\gamma = 0.8i$ with radius $\rho = 10$.

$\mathbf{T}$ is meromorphic with $m = 40$ simple poles in $\Omega$.

Hankel and MPLoewner-based CIMs build up relevant data matrices and utilize a rank-$m$ truncated SVD, where, with exact data, $m$ is exactly the number of poles of $\mathbf{T}$ withing $\Omega$ (counting multiplicities).

Inexact data is derived through contour integration of $f_k(z) \left( \mathbf{L}^* \left[ \mathbf{T}(z) \right]^{-1} \mathbf{R} \right)$, approximated via quadrature rule -- $f_k(z)$ depends on the choice of Hankel/SPLoewner/MPLoewner formulations and, in the case of the latter two, on the choice of shift $\sigma$.

Generally, left and right probing matrices are used to reduce the computational burden of full inversion of $\mathbf{T}$ at each quadrature node, and we will denote the number of left/right probing directions by $\ell$ and $r$, respectively.

## Experiments

### Quadrature Approximation, $m = 40; \ell = r = 15; \mathbb{D},\mathbb{D_s} \in \mathbb{C}^{60 \times 60}$

- For $N=128$, Hankel and MPLoewner yield a roughly equivalent maximum relative residual (MRR) -- $4.4*10^{-5}$ and $3.9*10^{-5}$, respectively.
- MRR does not decrease to below $\sim 10^{-10}$ for Hankel until $N = 32768$. For MPLoewner, the MRR is below $\sim 10^{-12}$ for the same $N$.
- These results appear to mirror those produced by polyeig, but at a hefty cost in numerical quadrature.

### Quadrature Approximation, $m = 42; \ell = r = 15; \mathbb{D},\mathbb{D_s} \in \mathbb{C}^{60 \times 60}$

#### Qualifiers

- Note that, if we increase $m$ to $42$, both Hankel and MPLoewner realizations no longer align with the prescribed rank truncation as in the case of exact data. In particular, two more eigenvalues than the number of reference eigenvalues within $\Omega$ are recovered.
- This is only possible because the data matrices are being computed _inexactly_. With sufficiently large $N$, the numerical rank of $\mathbb{D}$ will be smaller than $42$, and the algorithms will fail at the rank determination step.

#### Observations

- Interestingly, many fewer quadrature nodes (less than $512$) are necessary to achieve MRR near machine precision for both Hankel and MPLoewner. A similar gap in the MRR between Hankel and MPLoewner is present in this case (about two orders of magnitude).
- Even with only $N = 128$ quadrature nodes, MPLoewner appears to more accurately match computed eigenvalues to the underlying reference (in the eyeball norm).
- SPLoewner with $\sigma = -13i$ produces results comparable to MPLoewner.
- For $N = 128$, in both Hankel and MPLoewner cases the singular values after position 44/42 of the data matrix are "paired", and enlarging $m$ in steps of two appears to improve the MRR of the "target eigenvalues" (those within the contour).