function qs = samplequadrature(T,L,R,z)
% INPUTS
%   T -- function handle from C -> nXn matrices, meromorphic on domain D
%   L -- left nXell probing/sketching matrix
%   R -- right nXr probing/sketching matrix
%   z -- points on the boundary of D (coming from some quadrature rule)
% OUTPUTS
%   qs -- vector of two-sided samples of L*T^{-1}R at z_k in z
% BEGIN

% BEGIN SANITY CHECKS
% check that T yields square matrices
n1,n2 = size(feval(T,0));
assert(n1==n2);
n = n1;

% number of quadrature nodes
N = length(z);

% verify that L and R are compatible with T
% further, the outer dimensions should be <= n!
[l1,ell] = size(L);
[l2,r] = size(R);
assert(all([l1,l2]==[n,n]));
assert(ell <= n && r <= n);
% END SANITY CHECKS

qs = zeros(N,n,n);
for i=1:N
    % could be a good idea to pick / or \ based on outer dims of L and R
    % but wtv for now :)
    qs(:,:,i) = feval(T,z(i)) \ R;
    qs(:,:,i) = L' * qs(:,:,i)
end
end