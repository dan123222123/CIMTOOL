function M = build_moments(A,B,C,K)

    M = zeros(size(C,1),size(B,2),2*K);
    for k=1:2*K
        M(:,:,k) = C*(A^k)*B;
    end

end