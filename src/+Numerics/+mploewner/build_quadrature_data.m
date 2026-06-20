function [B,BB,C,CC] = build_quadrature_data(z,w,Ql,Qr,L,R,theta,sigma,PadStrategy,Verbose)
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

    % Resolve one tangential direction (and its quadrature samples) per
    % interpolation point. The number of left (theta) and right (sigma) points
    % need NOT match: BB/CC are rectangular (elltheta-by-rsigma), which realize()
    % handles by SVD-truncating to m -- recovery only requires
    % min(elltheta,rsigma) >= m. When fewer directions than points are supplied,
    % cycle through them; extra directions are unused.
    if Lsize < elltheta || Rsize < rsigma
        if ~strcmp(PadStrategy,"cyclical")
            error('Fewer tangential directions than required and an invalid pad strategy "%s" was specified.', PadStrategy)
        end
        Qli = @(i) Ql(mod(i-1,Lsize)+1,:,:); Qri = @(i) Qr(:,mod(i-1,Rsize)+1,:);
        Li  = @(i) L(:,mod(i-1,Lsize)+1);    Ri  = @(i) R(:,mod(i-1,Rsize)+1);
    else
        Qli = @(i) Ql(i,:,:); Qri = @(i) Qr(:,i,:);
        Li  = @(i) L(:,i);    Ri  = @(i) R(:,i);
        if (Lsize > elltheta || Rsize > rsigma) && Verbose
            warning('More tangential directions than interpolation points -- is this intended?.')
        end
    end

    % left data B (one row per theta) / right data C (one column per sigma), each
    % a quadrature-approximated contour-integral moment, gathering the matching
    % tangential directions into LL (n-by-elltheta) and RR (n-by-rsigma)
    B = zeros(elltheta,n); LL = zeros(n,elltheta);
    for i = 1:elltheta
        B(i,:)  = sum((w ./ (z - theta(i))) .* reshape(Qli(i),n1,N), 2);
        LL(:,i) = Li(i);
    end
    C = zeros(n,rsigma); RR = zeros(n,rsigma);
    for j = 1:rsigma
        C(:,j)  = sum((w ./ (z - sigma(j))) .* reshape(Qri(j),n2,N), 2);
        RR(:,j) = Ri(j);
    end

    BB = B*RR; CC = LL'*C;   % both elltheta-by-rsigma
end
