function [Lb,Ls] = build_loewner(BB,CC,theta,sigma)
    % construct base and shifted Loewner matrices from left and right interpolation data

    elltheta = length(theta); rsigma = length(sigma);
    Lb = zeros(elltheta,rsigma); Ls = zeros(elltheta,rsigma);

    for i=1:elltheta
        for j=1:rsigma
            Lb(i,j) = (BB(i,j) - CC(i,j))/(theta(i)-sigma(j));
            Ls(i,j) = (theta(i)*BB(i,j) - sigma(j)*CC(i,j))/(theta(i)-sigma(j));
        end
    end

end