function [Db,Ds,refeig,cmpeig,nmderr,pairedcmpeig] = allpass_realization_exact_mploewner_sstfin(Ess,Etf,K,theta,sigma,DbE,DsE)
    arguments
        Ess
        Etf
        K
        theta = missing
        sigma = missing
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

    % sample data matrices
    L = Numerics.SampleData.sampleMatrix(n,K);
    R = Numerics.SampleData.sampleMatrix(n,K);

    ell = K; r = ell; Lt = L(:,1:ell); Rt = R(:,1:r);

    % building the exact data matrices
    [Db,Ds] = Numerics.build_mploewner_data(Etf,theta,sigma,Lt,Rt);

    Db = Db + DbE; Ds = Ds + DsE;

    cmpeig = eig(Ds,Db);

    [nmderr,pairedcmpeig] = Numerics.normmderr(refeig,cmpeig);

end