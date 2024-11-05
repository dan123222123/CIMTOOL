function [Db,Ds,refeig,cmpeig] = allpass_realization_exact_mploewner_nin(n,K,rsv,theta,sigma,DbE,DsE)
    arguments
        n
        K
        rsv
        theta = missing
        sigma = missing
        DbE = 0;
        DsE = 0;
    end

    % create error system
    [Ess,Etf] = allpass_error_nin_sstfout(n,rsv);

    n = length(Etf(0));

    refeig = eig(Ess.A); % poles of the system in question

    % set interpolation points, if unset
    if ismissing(theta) && ismissing(sigma)
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

    display(Numerics.normmderr(refeig,cmpeig));

end