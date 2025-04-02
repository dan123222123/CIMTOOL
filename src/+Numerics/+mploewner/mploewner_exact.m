function [Lambda,V,W,Db,Ds,BB,CC,X,Sigma,Y] = mploewner_exact(H,theta,sigma,L,R,m,options)
% Multi-Point Loewner realization with exact transfer function samples.
arguments % NOTE/TODO -- it is possible to write validation functions so that the we can get some more robust code.
    H                           % transfer function
    theta                       % left interpolation points
    sigma                       % right interpolation points
    L                           % \( n \times \ell \) matrix of left probing directions
    R                           % \( n \times r \) matrix of right probing directions
    m                           % number of poles to search for in \( \Omega \)
    options.PadStrategy = NaN   % padding strategy for construction of BB/CC (if the number of left/right tangential directions is less than the number of corresponding interpolation points)
    options.Verbose = true      % verbose output (or not)
    options.AbsTol = NaN        % absolute tolerance for base data matrix rank determination
end
import Numerics.mploewner.*;

% simple sanity checks
assert(m > 0, "# Eig Search should be > 0");
assert(~(isempty(theta) || isempty(sigma)), "# of left/right shifts should be > 0");

[B,BB,C,CC] = build_exact_loewner_data(H,theta,sigma,L,R,options.PadStrategy,options.Verbose);
[Db,Ds] = build_loewner(BB,CC,theta,sigma);
[Lambda,V,W,X,Sigma,Y] = Numerics.realize(m,Db,Ds,B,C,options.AbsTol);

end