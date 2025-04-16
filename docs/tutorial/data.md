# Building Data Matrices

In this section, we will explore how to build Hankel and Loewner data matrices using the methods in [sploewner][Numerics.sploewner] and [mploewner][Numerics.mploewner] submodules of `Numerics`.
For both submodules, there are two types of data that can be used:

1. **_Exact_ Data**:
For ERA/SPLoewner, this is a state-space description of an LTI system, \( \Sigma = \left( A, B, C \right) \).
For MPLoewner, this is a transfer function \( H \,:\, \mathbb{C} \rightarrow \mathbb{C}^{m \times p} \).
2. **_Inexact_ Data**:
For all methods, we use a numerical quadrature rule to approximate the _exact_ data, and use this approximation as input.

For the rest of this section, we will utilize the following example LTI systems \( \Sigma_i = \left( A_i, B_i, C_i \right), i = 1, 2 \) and their corresponding transfer function:

\[ \dot{\mathbf{x}}(t) = A_i \mathbf{x}(t) + B_i \mathbf{u}(t); \mathbf{y}(t) = C_i \mathbf{x} \quad \Leftrightarrow \quad H_i(z) = C_i (zI - A_i)^{-1} B_i \]

where

``` matlab
n = 6; A = diag(-n:-1);
B1 = (1:n)'; C1 = 1:n;
B2 = ones(n,2); C2 = ones(n,2)';
```

## ERA/Single Point Loewner (SPLoewner)

When one expands \( H \) in a Neumann series about \( \sigma = \infty \) (valid for \( \vert z \vert >> 0 \)), the coefficient matrices of this expansion are called \textit{Markov parameters} of the associated LTI system.
If the state-space representation of the system is known, the Markov parameters are given as \( M_k = C A^{k-1} B \) for \( k = 1, 2, \ldots \)
For the purposes of minimal system realization/pole identification via the Eigenvalue Realization Algorithm (ERA), it is sufficient to construct the first \( 2K \) Markov parameters, arrange them in an augmented data matrix, and then exact a system \( \hat{\Sigma} = \left( \hat{A}, \hat{B}, \hat{C} \right) \) with equivalent dynamics as \( \Sigma \).

??? note "Choosing \(K\)"

    The necessary choice of \(K\) will depend on the input/output dimensions of the system, as well as the desired state dimension of the realized system; generically, larger choices of \(K\) will increase the rank of the data matrices, but the impacts of rounding errors or noise due to increasing powers of \(A\) can make larger data matrices diverge from the Hankel operator limit as \( K \rightarrow \infty \).
    Choosing \(K\) such that \( \text{rank}(\mathbb{D}) \geq \) the McMillan degree of the underlying system will allow for minimal system realization via ERA.

If we consider the SISO system \( \Sigma_1 \) from above, we might choose \( K = 5 \), and construct the first \( 2K \) Markov parameters:

```matlab
K = n; sigma = Inf;
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
```

We can then use these moments to construct the \( 5 \times 5 \) base and shifted data matrices, and try to recover the eigenvalues of \(A\):

```matlab
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
norm(eig(Ds,Db)-diag(A)) % 5.8359e-10
```

If we choose \( \sigma \in \left( \mathbb{C} \setminus \{ \infty \} \right) \), then our expansion of \(H\) about \( \sigma \) will contain coefficient matrices that depend on \( \sigma \) -- these are known as \textit{generalized moment matrices} of \( \Sigma \) at \( \sigma \).
The same approach as in the case of ERA can be used to recover the eigenvalues of \(A\):

```matlab
sigma = 1+1i;
M = Numerics.sploewner.build_exact_moments(sigma,A,B1,C1,2*K);
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
norm(eig(Ds,Db)-diag(A)) % 1.0300e-04
```

!!! note

    The choice of shift \( \sigma \) is crucial for the realization quality in SPLoewner.
    As
