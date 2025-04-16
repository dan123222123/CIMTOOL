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
theta = 1i*(2:(n+1)); sigma = -1i*(2:(n+1));
```

Then, we can build data matrices \( \mathbb{B} \mathbb{B} \) and \( \mathbb{C} \mathbb{C} \) containing SISO transfer function samples at the left and right interpolation points, and use them to build the base and shifted Loewner data matrices.
Eigenvalue recovery

```matlab
[~,BB,~,CC] = Numerics.mploewner.build_exact_data(H1,theta,sigma);
[Db,Ds] = Numerics.mploewner.build_loewner(BB,CC,theta,sigma);
norm(eig(Ds,Db)-diag(A)) % 0.0105
```

??? note "Choosing left/right interpolation points"

    For better results with MPLoewner, left/right interpolation points should, ideally, be _interleaved_ -- \( \textcolor{red}{\text{explain}} \)

#### MIMO (with Tangential Interpolation)
