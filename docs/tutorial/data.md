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
n = 5; A1 = diagm(-n:-1); A2 = A1;
B1 = (1:5)'; C1 = 1:5;
B2 = ones(n,2); C2 = ones(n,2)';
```