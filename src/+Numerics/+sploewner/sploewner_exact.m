function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = sploewner_exact(sigma,A,B,C,K,m,L,R,options)
% Hankel/Single Point Loewner realization with two-sided quadrature samples.
% Given two-sided/left/right quadrature data `Qlr'/`Ql`/`Qr`, construction moments via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
arguments (Input) % NOTE/TODO -- it is possible to write validation functions so that the we can get some more robust code.
    sigma            % shift value \( = \infty \Leftrightarrow \) Hankel, \( < \infty \Leftrightarrow \) SPLoewner
    A
    B
    C
    K                % number of moments to use in data matrix construction
    m                % number of poles to search for in \( \Omega \)
    L = eye(size(C,1),size(C,2))
    R = eye(size(B,2),size(B,1))
    options = struct("AbsTol",NaN,"Verbose",true);
end
import Numerics.sploewner.* Numerics.realize;

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(K > 0, "# of moments should be > 0");

[Ml,Mr,Mlr] = build_exact_moments(sigma,A,B,C,2*K,L,R);
[Db,Ds,B,C] = build_sploewner(sigma,Ml,Mr,Mlr,K);
[Lambda,V,W,X,Sigma,Y] = realize(m,Db,Ds,B,C,options.AbsTol);

end