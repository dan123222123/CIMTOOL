function [B,BB,C,CC] = build_exact_data_siso(H,theta,sigma)
    % construct left/right interpolation data BB/CC from exact transfer function evaluations at theta/sigma
    arguments (Input)
        H
        theta
        sigma
    end

    n = size(H(randn(1)),1);
    elltheta = length(theta); rsigma = length(sigma);
    B = zeros(elltheta,n); C = zeros(n,rsigma);

    for i=1:max(elltheta,rsigma)
        if i <= elltheta; B(i,:) = H(theta(i)); end
        if i <= rsigma; C(:,i) = H(sigma(i)); end
    end
    BB = repmat(B,1,rsigma); CC = repmat(C,elltheta,1);
    
end