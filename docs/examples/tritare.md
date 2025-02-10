
# Going Beyond Polynomial Eigenvalue Problems

## Motivation

Thus far in our example of _acoustic-wave-1D_, we have examined a type of NLEVP in which the operator operator of interest is expressible as a matrix _polynomial_ in \( \lambda \).
In particular, this example stems from the discretization of a 1-D homogeneous Helmholtz equation.
Discretizations can be quite effective at capturing low-frequency eigenmodes associated to underlying _infinite dimensional_ problems; however, they are not as effective at capturing high frequency modes (if compounding discretization errors don't corrupt these recovered eigenvalues entirely).
From this perspective, we may desire to work directly with the infinite dimensional problem, trading polynomial nonlinearities for more general, transcendental ones.

## Plane Wave Solutions of 1-D Wave Equation

Consider the 1-D wave equation:

\[ u_{tt}(x,t) = -c^2 u_{xx}(x,t), \quad x \in [0,1], \quad t > 0 \]

with boundary conditions

\[ u(0,t) = 0 \quad \text{and} \quad u(1,t) = u_x(1,t), \quad t > 0. \]

If we apply the ansatz \( u(x,t) = f(x) e^{\lambda t}  \), where \( \lambda \in \mathbb{C} \), then we may write

\[ f_{xx}(x) = - \left( \frac{\lambda}{c} \right)^2 f(x). \]

Fixing \( c = 1 \), say, a simple computation shows that \( f(x) = \sin{( \lambda x )} \) satisfies the equation above.
Further, the right-hand boundary equation implies that

\[
%f(1) e^{\lambda} = \sin{ \lambda } e^{\lambda} = - \lambda \cos{ \lambda } e^{\lambda} \Rightarrow
\sin{ \lambda } = - \lambda \cos{ \lambda }
\Leftrightarrow
T(\lambda) \coloneqq \tan{ \lambda } - \lambda = 0.
\]

\( T(\lambda) = 0 \) is a scalar-valued, nonlinear eigenvalue problem in \( \lambda \) -- finding the roots of this equation enables us to directly construct the corresponding eigenmode \( f(x) \), which can then be used to solve the original PDE.

/// details | Finding Eigenvalues of \(T\) (within \(10^{-6}\) tolerance)|
```matlab
T = @(s) tan(s) - s;

tol = 10^-6; Ni = 2000; x = linspace(0,20,Ni); ew = zeros(size(x));
for i = 1:length(x)
    ew(i) = fzero(T,x(i));
end
ew = ew(ew > 2); ew = ew(abs(T(ew)) < tol); ew = uniquetol(ew,sqrt(tol));
```
///



\( \textcolor{red}{\text{maybe add some plots of the first few mode shapes as well?}} \)

## The Symmetric Three-String

\( \textcolor{red}{\text{add demo example walk-through here}} \)

\( \textcolor{red}{\text{make note about algebraic eigenvalue multiplicities?}} \)

## The Symmetric \(n\)-String

\( \textcolor{red}{\text{here especially, the eigenvalue multiplicities for type 1 \& 2 grow with } n.} \).

\( \textcolor{red}{\text{how does this growth affect things as eigenvalues are excluded from the contour?}} \)