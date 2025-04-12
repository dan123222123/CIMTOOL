function [Lambda,V,W] = tf_dbsvd(m,X,Sigma,Y,Ds,B,C,abstol)
    if isnan(abstol)
        tol = max(size(Sigma))*eps(Sigma(1,1));
    else
        tol = abstol;
    end
    r = sum(diag(Sigma)>=tol);
    if r < m
        error("Given SVD has numerical rank %d < %d. Cannot recover TF!",r,m);
    end
    X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
    [S,Lambda] = eig(sqrt(Sigma)\(X'*Ds*Y)/sqrt(Sigma));
    V = ((C*Y)/sqrt(Sigma))*S; W = (sqrt(Sigma)*S)\(X'*B);
end

