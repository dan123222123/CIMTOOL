function [Ml,Mr,Mlr] = build_exact_moments(sigma,A,B,C,K,L,R)
% Helper function to build generalized moments up to order K from left/right/two-sided quadrature samples at nodes \( z \) using quadrature weights \( w \).
arguments
    sigma
    A
    B
    C
    K
    L = eye(size(C,1),size(C,1))
    R = eye(size(B,2),size(B,2))
end

    % This is unstable -- better to formulate f based on solving with left/right probing matrices (possibly with a "mode" selection via options, say)
    if sigma == Inf
        f = @(k,Lambda) (Lambda^k);
    else
        f = @(k,Lambda) (((-1)^k) * pinv((sigma*eye(size(Lambda)) - Lambda))^(k+1));
    end

    Ml = zeros(size(L,2),size(B,2),K);
    Mr = zeros(size(C,1),size(R,2),K);
    Mlr = zeros(size(L,2),size(R,2),K);

    [V,D] = eig(full(A)); B = V\full(B); C = full(C)*V;

    for k=1:K
        CL = f(k-1,D);
        Ml(:,:,k) = L'*C*CL*B;
        Mr(:,:,k) = C*CL*B*R;
        Mlr(:,:,k) = Ml(:,:,k)*R;
    end

end