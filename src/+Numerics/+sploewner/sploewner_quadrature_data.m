function [Db,Ds,B,C] = sploewner_quadrature_data(sigma,z,w,Ql,Qr,Qlr,K,ell,r)
% Hankel/Single Point Loewner data matrices from two-sided quadrature samples.
arguments (Input)
    sigma                           % shift value \( = \infty \Leftrightarrow \) Hankel, \( ! \infty \Leftrightarrow \) SPLoewner
    z                               % vector of quadrature nodes
    w                               % vector of quadrature weights
    Ql                              % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr                              % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    Qlr                             % vector of two-sided samples \( L^* T^{-1} R \) at \( z_k \) in \(z\)
    K                               % number of moments to use in data matrix construction
    ell = size(Qlr,1)               % number of leading left directions to use
    r = size(Qlr,2)                 % number of leading right directions to use
end
import Numerics.sploewner.*;

N = size(Qlr,3);

% check that the length of qs, z, and w match
assert(N==length(z)); assert(N==length(w));
assert(ell <= size(Qlr,1) && r <= size(Qlr,2), "the samples must cover ell left and r right directions");

assert(K > 0, "# of moments should be > 0");

% only need K because build_quadrature_moments already does 2K
[Ml,Mr,Mlr] = build_quadrature_moments(sigma,z,w,Ql,Qr,Qlr,K,ell,r);
[Db,Ds,B,C] = build_sploewner(sigma,Ml,Mr,Mlr,K);

end
