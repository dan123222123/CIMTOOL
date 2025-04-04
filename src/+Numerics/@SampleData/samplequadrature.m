function [Ql,Qr,Qlr] = samplequadrature(T,L,R,z,show_progress,sample_mode)
arguments
    T 
    L 
    R 
    z 
    show_progress = false
    sample_mode = Numerics.SampleMode.Inverse
end
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
% if conditioning of T(z(1)) is bad, this could give extra warnings
orig_state = warning;
warning('off','all');
[n1,n2] = size(T(z(1)));
warning(orig_state);

% verify that L and R are compatible with T
assert(n1==n2); n = n1;
[l1,~] = size(L); [l2,~] = size(R);
assert(all([l1,l2]==[n,n]));
% END SANITY CHECKS

if show_progress == true
    [Ql,Qr,Qlr] = samplequadrature_progress(T,L,R,z,sample_mode);
else
    [Ql,Qr,Qlr] = samplequadrature_noprogress(T,L,R,z,sample_mode);
end

end