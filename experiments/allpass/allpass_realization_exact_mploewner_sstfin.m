function [Db,Ds,refeig,cmpeig,nmderr,pairedcmpeig] = allpass_realization_exact_mploewner_sstfin(Ess,Etf,K,theta,sigma,L,R,DbE,DsE)
    arguments
        Ess
        Etf
        K
        theta = missing
        sigma = missing
        L = missing
        R = missing
        DbE = 0;
        DsE = 0;
    end

    n = length(Etf(0));

    refeig = eig(Ess.A); % poles of the system in question

    % set interpolation points, if unset
    if all(ismissing(theta)) && all(ismissing(sigma))
        contour = Numerics.Contour.Circle(0,max(abs(refeig))*2,64);
        [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
    end

    % sample data matrices, if not provided
    if anymissing(L)
        L = Numerics.SampleData.sampleMatrix(n,K);
    end
    if anymissing(R)
        R = Numerics.SampleData.sampleMatrix(n,K);
    end

    ell = K; r = ell; Lt = L(:,1:ell); Rt = R(:,1:r);

    % building the exact data matrices
    [Db,Ds] = Numerics.build_mploewner_data(Etf,theta,sigma,Lt,Rt);

    Db = Db + DbE; Ds = Ds + DsE;

    % [X,Sigma,Y] = svd(Db); m = length(refeig);
    % X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
    % cmpeig = (Sigma \ (X'*Ds*Y));

    cmpeig = eig(Ds,Db,"qz");

    display(cmpeig)

    [nmderr,pairedcmpeig] = Numerics.normmderr(refeig,cmpeig);

end