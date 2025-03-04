# Unilateral Modal Truncation of LTI ISS Model

## Background

We are given an LTI system

\[ \dot{x}(t) = A x(t) + B u(t) \quad ; \quad y(t) = C x(t) \]

with \( A \in \mathbb{R}^{n \times n}, B \in \mathbb{R}^{n \times m}, C \in \mathbb{R}^{p \times n} \) where \( n = 270 \) and \( m = p = 3 \).
This system represents a structural model of the first assembly stage of the international space station (Chahlaoui and Van Dooren 2005).
The reference eigenvalues of the state matrix \( A \) are shown in the following figure:

![ISS Reference Eigenvalues](./iss_ewref.png)

Associated to the state-space representation of the ISS model, we may consider the transfer function \( H \,:\, \mathbb{C} \rightarrow \mathbb{C}^{3 \times 3}, z \mapsto C(zI - A)^{-1}B \).

## Goals

- Identify and isolate modes of the given transfer function.
- Compare frequency response of ``modally truncated'' transfer function to original.
- Compute eigenvalue/eigenvector residual quantities -- eigenvalue gap/subspace angles/etc.
