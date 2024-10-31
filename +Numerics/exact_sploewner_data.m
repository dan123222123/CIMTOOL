function [Db,Ds] = exact_sploewner_data(A,B,C,sigma,K,L,R)
arguments
    A 
    B 
    C 
    sigma
    K
    L = eye(size(A))
    R = eye(size(A))
end

    import Numerics.*
    
    ell = size(L,2); r = size(R,2);
    Mf = exact_sploewner_moments(A,B,C,sigma);
    
    M = zeros(ell,r,2*K);
    
    for k=1:K
        M(:,:,2*k-1) = L'*Mf(2*k-2)*R; M(:,:,2*k) = L'*Mf(2*k-1)*R;
    end

    [Db,Ds] = build_sploewner_data(M,ell,r,sigma,K);

end
