function [Ql,Qr,Qlr] = samplequadrature(T,L,R,z)
% INPUTS
%   T -- function handle from C -> nXn matrices, meromorphic on domain D
%   L -- left nXell probing/sketching matrix
%   R -- right nXr probing/sketching matrix
%   z -- points on the boundary of D (coming from some quadrature rule)
% OUTPUTS
%   Ql -- vector of one-sided samples L*T^{-1} at z_k in z
%   Qr -- vector of one-sided samples T^{-1}R at z_k in z
%   Qlr -- vector of two-sided samples L*T^{-1}R at z_k in z
% BEGIN

% BEGIN SANITY CHECKS
% check that T yields square matrices
[n1,n2] = size(T(0));
assert(n1==n2);
n = n1;

% number of quadrature nodes
N = length(z);

% verify that L and R are compatible with T
% further, the outer dimensions should be <= n!
[l1,ell] = size(L);
[l2,r] = size(R);
assert(all([l1,l2]==[n,n]));
%assert(ell <= n && r <= n);
% END SANITY CHECKS

% BEGIN NUMERICS
Ql = zeros(ell,n,N);
Qr = zeros(n,r,N);
Qlr = zeros(ell,r,N);
for i=1:N
    Ql(:,:,i) = L'/T(z(i));
    Qr(:,:,i) = T(z(i))\R;
    Qlr(:,:,i) = L'*Qr(:,:,i);
end
% END NUMERICS

end