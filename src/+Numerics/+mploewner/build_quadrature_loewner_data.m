function [B,BB,C,CC] = build_quadrature_loewner_data(z,w,Ql,Qr,L,R,theta,sigma,PadStrategy,Verbose)
    % construct left/right interpolation data BB/CC from left/right quadrature evaluations given quadrature nodes/weights z and w
    arguments (Input)
        z
        w
        Ql
        Qr
        L
        R
        theta
        sigma
        PadStrategy = "cyclical"
        Verbose = true
    end
    arguments (Output)
        B
        BB
        C
        CC
    end

    elltheta = length(theta); rsigma = length(sigma);
    [Lsize,n1,N1] = size(Ql); [n2,Rsize,N2] = size(Qr);

    % assertions on the given quadrature data
    assert(n1==n2); assert(N1==N2); n=n1; N=N1;
    assert(N==length(z) && N==length(w));

    % choose an appropriate padding strategy, if necessary
    if Lsize < elltheta || Rsize < rsigma
        RR = zeros(n,elltheta); LL = zeros(n,rsigma);
        if strcmp(PadStrategy,"cyclical")
            Qli = @(i) Ql(mod(i-1,Lsize)+1,:,:); Qri = @(i) Qr(:,mod(i-1,Rsize)+1,:);
            Li = @(i) L(:,mod(i-1,Lsize)+1); Ri = @(i) R(:,mod(i-1,Rsize)+1);
        else
            error('Fewer tangential directions than required and an invalid pad strategy "%s" was specified.', PadStrategy)
        end
    else
        RR = R; LL = L;
        Qli = @(i) Ql(i,:,:); Qri = @(i) Qr(:,i,:);
        Li = @(i) L(:,i); Ri = @(i) R(:,i);
        if Lsize > elltheta || Rsize > rsigma && Verbose
            warning('More tangential directions than interpolation points -- is this intended?.')
        end
    end

    % preallocate intermediate sample and (possibly padded) tangential direction arrays
    B = zeros(elltheta,n); C = zeros(n,rsigma);

    % faster to multiply by probing directions at the end rather than for each i
    for i=1:max(elltheta,rsigma)
        if i <= elltheta
            B(i,:) = sum((w ./ (theta(i) - z)) .* reshape(Qli(i),n1,N),2);
            RR(:,i) = Ri(i);
        end
        if i <= rsigma
            C(:,i) = sum((w ./ (sigma(i) - z)) .* reshape(Qri(i),n2,N),2);
            LL(:,i) = Li(i);
        end
    end
    BB = B*RR; CC = LL'*C;

end