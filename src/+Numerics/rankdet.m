function [Dbrank,X,Sigma,Y] = rankdet(Db,abstol,reltol)
% Numerical rank of Db: the number of singular values at or above the larger of abstol and reltol*sigma_1, or above max(size(Db))*eps(sigma_1) when both are NaN.
    arguments
        Db
        abstol = NaN;
        reltol = NaN;
    end
    [X, Sigma, Y] = svd(Db,"matrix");
    s1 = 0;
    if ~isempty(Sigma); s1 = Sigma(1,1); end
    if isnan(abstol) && isnan(reltol)
        tol = max(size(Sigma))*eps(s1);
    else
        tol = max(abstol,reltol*s1); % max omits the NaN one
    end
    Dbrank = sum(diag(Sigma)>=tol);
end
