function [Db,Ds] = quadrature_sploewner_data(Qlr,sigma,z,w,K)

    import Numerics.*
    
    ell = size(Qlr,1); r = size(Qlr,2);

    M = quadrature_sploewner_moments(Qlr,sigma,z,w,2*K);

    [Db,Ds] = build_sploewner_data(M,ell,r,sigma,K);

end
