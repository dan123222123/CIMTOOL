function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = sploewner_exact(sigma,A,B,C,K,m,L,R,options)
% Hankel/Single Point Loewner realization given state, reachability, and observability matrices of an LTI system.
% Using these system matrices, (probed) generalzied moments are constructed up to order \( 2K \).
% We use these "exact" moments to construct the Hankel data matrices and the realize the system from the resulting matrix pencil.
arguments (Input)
    sigma                           % shift value \( = \infty \Leftrightarrow \) Hankel, \( ! \infty \Leftrightarrow \) SPLoewner
    A                               % state matrix
    B                               % reachability matrix
    C                               % observability matrix
    K                               % half of the number of moments to use in data matrix construction
    m                               % number of poles to search for in \( \Omega \)
    L = eye(size(C,1),size(C,2))    % left matrix of probing directions
    R = eye(size(B,2),size(B,1))    % right matrix of probing directions
    options = struct("AbsTol",NaN)  % options for realization
end
arguments (Output)
    Lambda
    V
    W
    Db
    Ds
    B
    C
    X
    Sigma
    Y
end
import Numerics.sploewner.* Numerics.realize;

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(K > 0, "# of moments should be > 0");

[Ml,Mr,Mlr] = build_exact_moments(sigma,A,B,C,2*K,L,R);
[Db,Ds,B,C] = build_sploewner(sigma,Ml,Mr,Mlr,K);
[Lambda,V,W,X,Sigma,Y] = realize(m,Db,Ds,B,C,options.AbsTol);

end