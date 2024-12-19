function [M,Mr] = build_moments(K,A,B,C,L,R)

    M = zeros(size(L,2),size(R,2),2*K);
    for k=1:2*K
        M(:,:,k) = L'*C*(A^(k-1))*B*R;
    end

    Mr = zeros(size(C,2),size(R,2),K);
    for k=1:2*K
        Mr(:,:,k) = (A^(k-1))*B*R;
    end

end