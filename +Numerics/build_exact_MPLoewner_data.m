function [Lb,Ls,B,C] = build_exact_MPLoewner_data(H,theta,sigma,L,R)
    n = size(H(0),1); elltheta = length(theta); rsigma = length(sigma);
    Lsize = size(L,2); Rsize = size(R,2);

    B = zeros(elltheta,n); C = zeros(n,rsigma);
    % construct B and C matrices
    for i=1:elltheta
        ldir = mod(i-1,Lsize)+1;
        B(i,:) = L(:,ldir)'*H(theta(i));
    end
    for j=1:rsigma
        rdir = mod(j-1,Rsize)+1;
        C(:,j) = H(sigma(j))*R(:,rdir);
    end

    Lb = zeros(elltheta,rsigma); Ls = zeros(elltheta,rsigma);
    for i=1:elltheta
        for j=1:rsigma
            ldir = mod(i-1,Lsize)+1;
            rdir = mod(j-1,Rsize)+1;
            Lb(i,j) = (B(i,:)*R(:,rdir) - L(:,ldir)'*C(:,j))/(theta(i)-sigma(j));
            Ls(i,j) = (theta(i)*B(i,:)*R(:,rdir) - sigma(j)*L(:,ldir)'*C(:,j))/(theta(i)-sigma(j));
        end
    end

end