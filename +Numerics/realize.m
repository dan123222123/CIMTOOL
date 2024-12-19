function [Lambda,V] = realize(m,Db,Ds,C)
    [X,Sigma,Y] = svd(Db,"matrix");
    X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
    % [S,Lambda] = eig(X'*Ds*Y/Sigma);
    [S,Lambda] = eig(X'*Ds*Y,Sigma);
    Lambda = diag(Lambda);
    V = C*Y*(Sigma\S);
end

