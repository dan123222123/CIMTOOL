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
    % L and R give the directions; Ql and Qr may hold extra samples
    Lsize = size(L,2); Rsize = size(R,2);
    [Lrows,n1,N1] = size(Ql); [n2,Rcols,N2] = size(Qr);

    % assertions on the given quadrature data
    assert(n1==n2); assert(N1==N2); n=n1; N=N1;
    assert(N==length(z) && N==length(w));
    assert(Lrows >= Lsize && Rcols >= Rsize, "the samples must cover the directions in L and R");

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
    elseif (Lsize > elltheta || Rsize > rsigma) && Verbose
        warning('More tangential directions than interpolation points -- is this intended?.')
    end
    % direction used by each interpolation point (the identity when there are
    % enough directions, cyclic otherwise)
    li = mod(0:elltheta-1,Lsize)+1; ri = mod(0:rsigma-1,Rsize)+1;

    % left data B (one row per theta) / right data C (one column per sigma), each
    % a quadrature-approximated contour-integral moment
    z = reshape(z,1,N); w = reshape(w,1,N);
    Wt = w ./ (z - theta(:)); Ws = w ./ (z - sigma(:));     % elltheta-by-N, rsigma-by-N
    B = zeros(elltheta,n,'like',Wt);
    for i = 1:elltheta
        B(i,:) = Wt(i,:) * reshape(Ql(li(i),:,:),n,N).';
    end
    C = zeros(n,rsigma,'like',Ws);
    for j = 1:rsigma
        C(:,j) = reshape(Qr(:,ri(j),:),n,N) * Ws(j,:).';
    end
    LL = L(:,li); RR = R(:,ri);                             % matching tangential directions

    BB = B*RR; CC = LL'*C;   % both elltheta-by-rsigma
end
