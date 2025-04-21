# Building Data Matrices

In this section, we will explore how to build Hankel and Loewner data matrices using the methods in [sploewner][Numerics.sploewner] and [mploewner][Numerics.mploewner] submodules of `Numerics`.
For both submodules, there are two types of data that can be used:

1. **_Exact_ Data**:
For ERA/SPLoewner, this is a state-space description of an LTI system, \( S = \left( A, B, C \right) \).
For MPLoewner, this is a transfer function \( H \,:\, \mathbb{C} \rightarrow \mathbb{C}^{m \times p} \).
2. **_Inexact_ Data**:
For all methods, we use a numerical quadrature rule to approximate the _exact_ data, and use this approximation as input.

For the rest of this section, we will utilize the following example LTI systems \( S_i = \left( A_i, B_i, C_i \right), i = 1, 2 \) and their corresponding transfer function:

\[ \dot{\mathbf{x}}(t) = A_i \mathbf{x}(t) + B_i \mathbf{u}(t); \mathbf{y}(t) = C_i \mathbf{x} \quad \Leftrightarrow \quad H_i(z) = C_i (zI - A_i)^{-1} B_i \]

where

``` matlab
n = 6; A = diag(-n:-1);
B1 = (1:n)'; C1 = 1:n;
B2 = ones(n,2); C2 = ones(n,2)';
%
H1 = @(z) C1*((z*eye(size(A)) - A) \ B1);
H2 = @(z) C2*((z*eye(size(A)) - A) \ B2);
```

## Exact Data

### ERA/Single Point Loewner (SPLoewner)

When one expands \( H \) in a Neumann series about \( \sigma = \infty \) (valid for \( \vert z \vert >> 0 \)), the coefficient matrices of this expansion are called _Markov parameters_ of the associated LTI system.
If the state-space representation of the system is known, the Markov parameters are given as \( M_k = C A^{k-1} B \) for \( k = 1, 2, \ldots \)
For the purposes of minimal system realization/pole identification via the Eigenvalue Realization Algorithm (ERA), it is sufficient to construct the first \( 2K \) Markov parameters, arrange them in an augmented data matrix, and then exact a system \( \hat{S} = \left( \hat{A}, \hat{B}, \hat{C} \right) \) with equivalent dynamics as \( S \).

??? note "Choosing \(K\)"

    The necessary choice of \(K\) will depend on the input/output dimensions of the system, as well as the desired state dimension of the realized system; generically, larger choices of \(K\) will increase the rank of the data matrices, but the impacts of rounding errors or noise due to increasing powers of \(A\) can make larger data matrices diverge from the Hankel operator limit as \( K \rightarrow \infty \).
    Choosing \(K\) such that \( \text{rank}(\mathbb{D}) \geq \) the McMillan degree of the underlying system will allow for minimal system realization via ERA.

If we consider the SISO system \( S_1 \) from above, we might choose \( K = 5 \), and construct the first \( 2K \) Markov parameters:

```matlab
K = n; sigma = Inf;
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
```

We can then use these moments to construct the \( 5 \times 5 \) base and shifted data matrices, and try to recover the eigenvalues of \(A\):

```matlab
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
norm(eig(Ds,Db)-diag(A)) % 5.8359e-10
```

If we choose \( \sigma \in \left( \mathbb{C} \setminus \{ \infty \} \right) \), then our expansion of \(H\) about \( \sigma \) will contain coefficient matrices that depend on \( \sigma \) -- these are known as _generalized moment matrices_ of \( S \) at \( \sigma \).
The same approach as in the case of ERA can be used to recover the eigenvalues of \(A\):

```matlab
sigma = 1+1i;
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
norm(eig(Ds,Db)-diag(A)) % 1.0300e-04
```

??? note "Choice of \( \sigma \neq \infty \)"

    The choice of shift \( \sigma \) is crucial for the quality of poles realized in SPLoewner.
    An example for the effect of choosing different shifts on the poles of \( S_1 \) is shown in `demos/exact_sploewner_sigma_choice.m`.
    The resulting heatmap of the ratio between 2-norm error of ERA and SPLoewner for \( \sigma \in \{ z \in \mathbb{C} \,:\, -10 \leq \mathfrak{R}(z) \leq 5, -7.5 \leq \mathfrak{I}(z) \leq 7.5 \} \) is as follows:

    ![](../figures/eravspl_shiftmap.png)

    A value greater than 0 indicates that the poles of SPLoewner are increasingly more accurate ERA, while a value less than 0 indicates the opposite.
    The region of the complex plane in which a finite shift more accurately recovers the poles of \( S_1 \) is highly dependent on the underlying system matrices and size/shape of the formed data matrices.

### Multi Point Loewner (MPLoewner)

When it is possible to sample the transfer function of a system directly, the MPLoewner method can be used to compute the poles of the system.
Data matrices are formed by taking divided differences of the transfer function sampled at left and right sets of interpolation points.
For the version of MPLoewner implemented in package, it is assumed that the transfer function is either:

1. SISO; or,
2. MIMO with left and right sets of tangential interpolation directions used in constructing entries of the Loewner data matrices.

#### SISO

\( S_1 \) is SISO, so we only need to choose left and right interpolation point sets \( \left( \Theta, \Sigma \right) = \{ (\theta_i,\sigma_i) \,:\, i = 1,2,...,K \} \) such that \( \left( \Theta \cup \Sigma \right) \cap \sigma(A) = \emptyset \) and \( \Theta \cap \Sigma = \emptyset \):

```matlab
ellt = @(n) (-1)^n*n; rt = @(n) (-1)^(n+1)*n;
theta = 1i*arrayfun(ellt,2:(n+1)); sigma = 1i*arrayfun(rt,2:(n+1));
```

??? note "Choosing left/right interpolation points"

    For better results with MPLoewner, left/right interpolation points should, ideally, be _close_ to the desired eigenvalues and _interleaved_;
    for the latter, this means that \( \vert \theta_i - \sigma_j \vert \) should be relatively small when \( i, j \) are close.
    This choice of interpolation points biases the ``mass'' of the data matrices towards its diagonal elements and improves corresponding singular value decay.

Then, we can build data matrices \( \mathbb{B} \mathbb{B} \) and \( \mathbb{C} \mathbb{C} \) containing SISO transfer function samples at the left and right interpolation points, and use them to build the base and shifted Loewner data matrices.

```matlab
[~,BB,~,CC] = Numerics.mploewner.build_exact_data(H1,theta,sigma,1,1);
[Db,Ds] = Numerics.mploewner.build_loewner(BB,CC,theta,sigma);
norm(eig(Ds,Db)-diag(A)) % 5.3235e-07
```

!!! note

    When calling `build_exact_data` above, the last two arguments fix the left/right sampling direction to 1 (unscaled).

#### MIMO (with Tangential Interpolation)

When the transfer function corresponds to a MIMO system, one viable strategy is to sample at _tangential_ directions;
that is, pick left/right probing directions \( \vec{\ell}/\vec{r} \) corresponding to left and right interpolation points and form Loewner data matrices with scalar samples \( \vec{\ell} H(z) \vec{r} \) instead of matrices \( H(z) \).
Random tangential directions are a typical choice for \( \vec{\ell}/\vec{r} \), since the resulting tangentially probed data matrices are unlikely to become rank-deficient in this case.

```matlab
[~,BB,~,CC] = Numerics.mploewner.build_exact_data(H2,theta,sigma);
[Db,Ds] = Numerics.mploewner.build_loewner(BB,CC,theta,sigma);
norm(eig(Ds,Db)-diag(A)) % 2.1547e-07 -- varries based on tangential directions
```

## Inexact Data

In practice, although transfer function samples may be available for _some_ points in \( \mathbb{C} \), the given data may not include transfer function samples at left and right interpolation points, let alone generalized moment data.
One approach to dealing with this lack of _necessary_ transfer function samples is to use contour integration and the Cauchy Integral Formula (CIF) to evaluate the underlying transfer function at a specific interpolation point.
If \(H\) is a meromorphic matrix-valued function with all of its poles contained within some bounded domain \( \Omega \subset \mathbb{C} \), then we can use contour integration on particular choices of analytic \(f\) to recover useful data about the dynamics of our system.
Generally, we perform this contour integration using a numerical quadrature rule on \( \partial \Omega \).
For \( \Omega \) conformal to a disk, the trapezoid rule provides exponential convergence guarantees for such data approximations.

First, we create an ellipsoidal contour about the poles of \( H_2 \) with \(8\) quadrature nodes

```matlab
import Visual.*; % allows us to skip subsequent "Visual."s

c = Contour.Ellipse(-(n+1)/2,n/2,n/4,8);

o = OperatorData(H2); o.refew = diag(A); o.sample_mode = "Direct";

s = SampleData(o,c); s.Contour.plot_quadrature = true;

s.ax = gca;
```

??? "Contour/Quadrature Visual"

    ![](../figures/quad_mpl.png)

We will _sketch_ our evaluations of \(H\) at the quadrature nodes down to \( 1 \times 1 \) moments via a random choice of left/right sketching vectors \( \vec{\ell} / \vec{r} \) and compute the left/right/two-sided moments.

```matlab
s.ell = 1; s.r = 1; s.compute();
```

!!! note

    Since each sketched

### ERA/SPLoewner

For ERA, put \( f_k(z) = z^k \) and compute

\[
M_k = C A^k B = \frac{1}{2 \pi i} \oint_{\partial \Omega} z^k H(z) \, dz \approx \sum_{n=1}^N w_n z_n^k H(z_n).
\]

For SPLoewner with \( \sigma \not \in \Omega \), put \( f_k^\sigma(z) = \frac{(-1)^k}{(\sigma - z)^{k+1}} \) and compute

\[
M_k^\sigma = \frac{H^{(k)}(\sigma)}{k!} = \frac{1}{2 \pi i} \oint_{\partial \Omega} \frac{(-1)^k}{(\sigma - z)^{k+1}} H(z) \, dz \approx \sum_{n=1}^N w_n \frac{(-1)^k}{(\sigma - z)^{k+1}} H(z_n).
\]
Just as in the case of MPLoewner, we can apply left and right _sketching_ matrices to our quadrature approximation to reduce the size of our approximated
