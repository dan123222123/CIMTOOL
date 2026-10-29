function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = sploewner_quadrature(sigma,z,w,Ql,Qr,Qlr,K,m,options)
% Hankel/Single Point Loewner realization with two-sided quadrature samples.
% Given two-sided/left/right quadrature data `Qlr`/`Ql`/`Qr`, construction moments via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
arguments (Input)
    sigma                           % shift value \( = \infty \Leftrightarrow \) Hankel, \( ! \infty \Leftrightarrow \) SPLoewner
    z                               % vector of quadrature nodes
    w                               % vector of quadrature weights
    Ql                              % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr                              % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    Qlr                             % vector of two-sided samples \( L^* T^{-1} R \) at \( z_k \) in \(z\)
    K                               % number of moments to use in data matrix construction
    m                               % number of poles to search for in \( \Omega \)
    options = struct("AbsTol",NaN)  % options for realization: AbsTol, and optionally RelTol (see rankdet)
end
import Numerics.sploewner.* Numerics.realize;

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");

reltol = NaN;
if isfield(options,"RelTol"); reltol = options.RelTol; end

[Db,Ds,B,C] = sploewner_quadrature_data(sigma,z,w,Ql,Qr,Qlr,K);
[Lambda,V,W,X,Sigma,Y] = realize(m,Db,Ds,B,C,options.AbsTol,reltol);

end
