function [Dbrank,X,Sigma,Y] = rankdet(Db,abstol)
    arguments
        Db 
        abstol = NaN;
    end
    [X, Sigma, Y] = svd(Db,"matrix");
    if isnan(abstol)
        tol = max(size(Sigma))*eps(Sigma(1,1));
    else
        tol = abstol;
    end
    Dbrank = sum(diag(Sigma)>=tol);
end