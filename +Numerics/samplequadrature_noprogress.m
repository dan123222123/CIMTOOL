function [Ql,Qr,Qlr] = samplequadrature_noprogress(T,L,R,z,sample_mode)

% BEGIN NUMERICS
N = length(z); n = size(T(z(1)),1); ell = size(L,2); r = size(R,2);
%
Tz = zeros(n,n,N);
for i=1:N
    Tz(:,:,i) = T(z(i));
end

Ql = zeros(ell,n,N); Qr = zeros(n,r,N); Qlr = zeros(ell,r,N);
parfor i=1:N
    if sample_mode == Numerics.SampleMode.Direct
        Ql(:,:,i) = L'*Tz(:,:,i); Qr(:,:,i) = Tz(:,:,i)*R; Qlr(:,:,i) = L'*Qr(:,:,i);
    elseif sample_mode == Numerics.SampleMode.Inverse
        Ql(:,:,i) = L' / Tz(:,:,i); Qr(:,:,i) = Tz(:,:,i) \ R; Qlr(:,:,i) = L' * Qr(:,:,i);
    end
end

end