function Mf = exact_sploewner_moments(A,B,C,sigma)
    if sigma == Inf
        Mf = @(k) C * A^k * B';
    else
        Mf = @(k) C * (((-1).^k)/(sigma*eye(size(A)) - A)^(k+1)) * B';
    end
end

