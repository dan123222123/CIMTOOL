function [BB,CC] = build_exact_loewner_data(n,H,theta,sigma,L,R)
    % construct left/right interpolation data BB/CC from exact transfer function evaluations at theta/sigma
    arguments (Input)
        n
        H
        theta
        sigma
        L = randn(n,length(theta))
        R = randn(n,length(sigma))
    end
    arguments (Output)
        BB
        CC
    end

    elltheta = length(theta); rsigma = length(sigma);
    BB = zeros(elltheta,n); CC = zeros(n,rsigma);

    for i=1:max(elltheta,rsigma)
        if i <= elltheta; BB(i,:) = L(:,i)'*H(theta(i)); end
        if i <= rsigma; CC(:,i) = H(sigma(i))*R(:,i); end
    end

end