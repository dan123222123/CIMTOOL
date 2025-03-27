function [Lambda,V,W,Db,Ds,B,C,X,Sigma,Y] = mploewner(z,w,Ql,Qr,L,R,theta,sigma,m,abstol)
% Multi-Point Loewner realization with one-sided quadrature samples.
% Given left/right quadrature data `Ql`/`Qr`, compute probed left/right transfer function samples at left/right interpolation points (theta/sigma) via contour integration approximated by a quadrature rule with nodes and weights \( ( z_k, w_k ) \).
arguments (Input) % NOTE/TODO -- it is possible to write validation functions so that the we can get some more robust code.
    z                % vector of quadrature nodes
    w                % vector of quadrature weights
    Ql               % vector of left-sided samples \( L^* T^{-1} \) at \( z_k \) in \(z\)
    Qr               % vector of right-sided samples of \( T^{-1} R \) at \( z_k \) in \(z\)
    L                % \( n \times \ell \) matrix of left probing directions
    R                % \( n \times r \) matrix of right probing directions
    theta            % left interpolation points
    sigma            % right interpolation points
    m                % number of poles to search for in \( \Omega \)
    abstol  = NaN    % absolute tolerance for base data matrix rank determination
end
arguments (Output)
    Lambda           % diagonal eigenvalue matrix
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

% check that elements of qs have the same dimension
[Lsize,n1,N1] = size(Ql); [n2,Rsize,N2] = size(Qr);
elltheta = length(theta); rsigma = length(sigma);

% check that the dimensions of the samples are compatible
assert(n1==n2); assert(N1==N2); n=n1; N=N1;

% check that the length of qs, z, and w match
assert(N==length(z)); assert(N==length(w));

% check that m, # of left/right shifts are greater than 0
assert(m > 0, "# Eig Search should be > 0");
assert(elltheta > 0 && rsigma > 0, "# of left/right shifts should be > 0");

% allocate left/right data and base/shifted data matrices
B = zeros(elltheta,n); C = zeros(n,rsigma);
Db = zeros(elltheta,rsigma); Ds = zeros(elltheta,rsigma);

% construct RR, LL, B, and C matrices
% if L or R have second dimension < elltheta or rsigma,
% tangential directions are repeated cycylically by default
% NOTE, this behavior may be better isolated in it's own function to keep things clearer
RR = zeros(n,elltheta); LL = zeros(n,rsigma);
for i=1:elltheta
    B(i,:) = sum((w ./ (theta(i) - z)) .* reshape(Ql(mod(i-1,Lsize)+1,:,:),n1,N),2);
    RR(:,i) = R(:,mod(i-1,Rsize)+1);
end
for j=1:rsigma
    C(:,j) = sum((w ./ (sigma(j) - z)) .* reshape(Qr(:,mod(j-1,Rsize)+1,:),n2,N),2);
    LL(:,j) = L(:,mod(j-1,Lsize)+1);
end
BB = B*RR; CC = LL'*C;

% construct Db and Ds matrices
for i=1:elltheta
    for j=1:rsigma
        Db(i,j) = (BB(i,j) - CC(i,j))/(theta(i)-sigma(j));
        Ds(i,j) = (theta(i)*BB(i,j) - sigma(j)*CC(i,j))/(theta(i)-sigma(j));
    end
end

[Lambda,V,W,X,Sigma,Y] = Numerics.realize(m,Db,Ds,B,C,abstol);

end