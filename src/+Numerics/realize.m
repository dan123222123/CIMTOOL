function [Lambda,V,W,Xf,Sigmaf,Yf] = realize(m,Db,Ds,B,C,abstol,reltol)
    arguments
        m
        Db
        Ds
        B
        C
        abstol = NaN    % absolute rank tolerance for Db (see rankdet)
        reltol = NaN    % rank tolerance for Db relative to its largest singular value (see rankdet)
    end
    [Dbrank,Xf,Sigmaf,Yf] = Numerics.rankdet(Db,abstol,reltol);
    if Dbrank < m
        error("Numerics:realize:rankDeficient","generated rank %d < %d data matrix",Dbrank,m);
    end
    X=Xf(:,1:m); Sigma=Sigmaf(1:m,1:m); Y=Yf(:,1:m);
    [S,Lambda] = eig(sqrt(Sigma)\(X'*Ds*Y)/sqrt(Sigma));
    Lambda = diag(Lambda); V = ((C*Y)/sqrt(Sigma))*S; W = (sqrt(Sigma)*S)\(X'*B);
end

