function [Ql,Qr,Qlr] = samplequadrature_noprogress(T,L,R,z,sample_mode)

% BEGIN NUMERICS
N = length(z); n = size(T(z(1)),1); ell = size(L,2); r = size(R,2);
%
% T(z_i) is evaluated inside the loop and never collected into a dense matrix to preserve sparsity
Ql = zeros(ell,n,N); Qr = zeros(n,r,N); Qlr = zeros(ell,r,N);
parfor i=1:N
    Ti = T(z(i));
    if sample_mode == Numerics.SampleMode.Direct
        Ql(:,:,i) = L'*Ti; Qr(:,:,i) = Ti*R; Qlr(:,:,i) = L'*Qr(:,:,i);
    elseif sample_mode == Numerics.SampleMode.Inverse
        Ql(:,:,i) = L' / Ti; Qr(:,:,i) = Ti \ R; Qlr(:,:,i) = L' * Qr(:,:,i);
    end
end

end
