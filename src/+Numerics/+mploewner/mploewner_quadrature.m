function [Lambda,V,W,Db,Ds,BB,CC,X,Sigma,Y] = mploewner_quadrature(z,w,Ql,Qr,L,R,theta,sigma,m,options)
% Multi-Point Loewner realization with one-sided quadrature samples.
% Given left/right quadrature data `Ql`/`Qr`, compute probed left/right transfer function samples at left/right interpolation points (theta/sigma) via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
arguments % NOTE/TODO -- it is possible to write validation functions so that the we can get some more robust code.
    z                           % vector of quadrature nodes
    w                           % vector of quadrature weights
    Ql                          % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr                          % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    L                           % \( n \times \ell \) matrix of left probing directions
    R                           % \( n \times r \) matrix of right probing directions
    theta                       % left interpolation points
    sigma                       % right interpolation points
    m                           % number of poles to search for in \( \Omega \)
    options.PadStrategy = NaN   % padding strategy for construction of BB/CC (if the number of left/right tangential directions is less than the number of corresponding interpolation points)
    options.Verbose = true      % verbose output (or not)
    options.AbsTol = NaN        % absolute tolerance for base data matrix rank determination
end
import Numerics.mploewner.* Numerics.realize;

% simple sanity checks
assert(m > 0, "# Eig Search should be > 0");
assert(~(isempty(theta) || isempty(sigma)), "# of left/right shifts should be > 0");

[B,BB,C,CC] = build_quadrature_data(z,w,Ql,Qr,L,R,theta,sigma,options.PadStrategy,options.Verbose);
[Db,Ds] = build_loewner(BB,CC,theta,sigma);
[Lambda,V,W,X,Sigma,Y] = realize(m,Db,Ds,B,C,options.AbsTol);

end