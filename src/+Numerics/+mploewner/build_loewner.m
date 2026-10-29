function [Lb,Ls] = build_loewner(BB,CC,theta,sigma)
    % construct base and shifted Loewner matrices from left and right interpolation data

    theta = theta(:); sigma = sigma(:).';
    Lb = (BB - CC)./(theta - sigma);
    Ls = (theta.*BB - sigma.*CC)./(theta - sigma);

end