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

    % Resolve one tangential direction per interpolation point. The number of
    % left (theta) and right (sigma) points need NOT match: BB/CC and the Loewner
    % pencil built from them are simply rectangular (elltheta-by-rsigma), which
    % realize() handles by SVD-truncating to m -- recovery only requires
    % min(elltheta,rsigma) >= m (the McMillan degree being sought). When fewer
    % directions than points are supplied, cycle through them; extra directions
    % are unused.
    if Lsize < elltheta || Rsize < rsigma
        if ~strcmp(PadStrategy,"cyclical")
            error('Fewer tangential directions than required and an invalid pad strategy "%s" was specified.', PadStrategy)
        end
        Li = @(i) L(:,mod(i-1,Lsize)+1); Ri = @(i) R(:,mod(i-1,Rsize)+1);
    else
        Li = @(i) L(:,i); Ri = @(i) R(:,i);
        if (Lsize > elltheta || Rsize > rsigma) && Verbose
            warning('More tangential directions than interpolation points -- is this intended?.')
        end
    end

    % left data B (one row per theta) and right data C (one column per sigma),
    % gathering the matching tangential directions into LL (n-by-elltheta) and
    % RR (n-by-rsigma)
    B = zeros(elltheta,n); LL = zeros(n,elltheta);
    for i = 1:elltheta
        B(i,:)  = - Li(i)' * H(theta(i));
        LL(:,i) = Li(i);
    end
    C = zeros(n,rsigma); RR = zeros(n,rsigma);
    for j = 1:rsigma
        C(:,j)  = - H(sigma(j)) * Ri(j);
        RR(:,j) = Ri(j);
    end

    BB = B*RR; CC = LL'*C;   % both elltheta-by-rsigma

end
