function [Lambda,V,Lbsw,Lssw] = realize(X,Sigma,Y,Ls,C)
    M = X'*Ls*Y / Sigma;
    [S,Lambda] = eig(M);
    Lambda = diag(Lambda);
    V = C*Y*(Sigma\S);
    Lbsw = diag(Sigma);
    Lssw = svd(Ls);
end

