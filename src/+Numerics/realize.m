function [Lambda,V,W,Xf,Sigmaf,Yf] = realize(m,Db,Ds,B,C,abstol)
    [Dbrank,Xf,Sigmaf,Yf] = Numerics.rankdet(Db,abstol);
    if Dbrank < m
        error("generated rank %d < %d data matrix",Dbrank,m);
    end
    X=Xf(:,1:m); Sigma=Sigmaf(1:m,1:m); Y=Yf(:,1:m);
    [S,Lambda] = eig(X'*Ds*Y,Sigma);
    Lambda = diag(Lambda); V = C*Y*S; W = (Sigma*S)\(X'*B);
end

