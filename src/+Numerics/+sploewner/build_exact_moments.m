function [Ml,Mr,Mlr] = build_exact_moments(sigma,A,B,C,K,L,R)
    arguments
        sigma
        A
        B 
        C 
        K 
        L = eye(size(A,1),size(C,1))
        R = eye(size(A,1),size(B,2))
    end

    if sigma == Inf
        f = @(k,Lambda) (Lambda^k);
    else
        f = @(k,Lambda) (((-1)^k) * inv((sigma*eye(size(Lambda)) - Lambda))^(k+1));
    end

    Ml = zeros(size(L,2),size(B,2),K);
    Mr = zeros(size(C,2),size(R,2),K);
    Mlr = zeros(size(L,2),size(R,2),K);

    [V,D] = eig(A); B = V\B; C = C*V;

    for k=1:K
        CL = f(k-1,D); % this should be chosen based on the size of B or C!
        Ml(:,:,k) = L'*C*CL*B;
        Mr(:,:,k) = C*CL*B*R;
        Mlr(:,:,k) = Ml(:,:,k)*R;
    end

end