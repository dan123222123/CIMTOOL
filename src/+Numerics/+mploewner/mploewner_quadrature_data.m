function [Db,Ds,B,BB,C,CC] = mploewner_quadrature_data(z,w,Ql,Qr,L,R,theta,sigma,PadStrategy,Verbose)
% Multi-Point Loewner data matrices from one-sided quadrature samples.
arguments
    z                           % vector of quadrature nodes
    w                           % vector of quadrature weights
    Ql                          % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr                          % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    L                           % \( n \times \ell \) matrix of left probing directions
    R                           % \( n \times r \) matrix of right probing directions
    theta                       % left interpolation points
    sigma                       % right interpolation points
    PadStrategy = NaN           % padding strategy for construction of BB/CC (if the number of left/right tangential directions is less than the number of corresponding interpolation points)
    Verbose = true              % verbose output (or not)
end
import Numerics.mploewner.*;

assert(~(isempty(theta) || isempty(sigma)), "# of left/right shifts should be > 0");

[B,BB,C,CC] = build_quadrature_data(z,w,Ql,Qr,L,R,theta,sigma,PadStrategy,Verbose);
[Db,Ds] = build_loewner(BB,CC,theta,sigma);

end
