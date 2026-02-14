function [B,BB,C,CC] = build_exact_data(H,theta,sigma,L,R,PadStrategy,Verbose)
    % construct left/right interpolation data BB/CC from exact transfer function evaluations at theta/sigma
    arguments (Input)
        H
        theta
        sigma
        L = randn(size(H(randn(1)),1),length(theta))
        R = randn(size(H(randn(1)),1),length(sigma))
        PadStrategy = "cyclical"
        Verbose = true
    end
    arguments (Output)
        B
        BB
        C
        CC
    end

    n = size(H(randn(1)),1);
    elltheta = length(theta); rsigma = length(sigma);
    Lsize = size(L,2); Rsize = size(R,2);
    B = zeros(elltheta,n); C = zeros(n,rsigma);

    % choose an appropriate padding strategy, if necessary
    if Lsize < elltheta || Rsize < rsigma
        RR = zeros(n,elltheta); LL = zeros(n,rsigma);
        if strcmp(PadStrategy,"cyclical")
            Li = @(i) L(:,mod(i-1,Lsize)+1); Ri = @(i) R(:,mod(i-1,Rsize)+1);
        else
            error('Fewer tangential directions than required and an invalid pad strategy "%s" was specified.', PadStrategy)
        end
    else
        RR = R; LL = L;
        Li = @(i) L(:,i); Ri = @(i) R(:,i);
        if Lsize > elltheta || Rsize > rsigma && Verbose
            warning('More tangential directions than interpolation points -- is this intended?.')
        end
    end

    for i=1:max(elltheta,rsigma)
        if i <= elltheta; B(i,:) = - Li(i)'*H(theta(i)); RR(:,i) = Ri(i); end
        if i <= rsigma; C(:,i) = - H(sigma(i))*Ri(i); LL(:,i) = Li(i); end
    end
    BB = B*RR; CC = LL'*C;

end