function level = momentlevel(Q,z,w,kmax)
% Size of the contour moments sum_j w_j s_j^k Q(:,:,j), k = 0..kmax, relative to their bound max|Q|*sum|w|,
% where s_j = (z_j - c)/max|z - c| maps the nodes z into the unit disk around their mean c.
% The moments vanish, up to quadrature and roundoff error, when the contour encloses no eigenvalue, so a level near
% eps marks an empty contour. Moments beyond k = 0 keep a polynomial problem with all its eigenvalues enclosed,
% whose k = 0 moment cancels, from reading as empty. Q holds one sample per node along its third dimension.
    arguments
        Q (:,:,:)
        z (1,:)
        w (1,:)
        kmax (1,1) double = 8
    end
    scale = max(abs(Q(:)))*sum(abs(w));
    if isempty(Q) || scale == 0
        level = 0;
        return;
    end
    s = (z - mean(z))/max(abs(z - mean(z)));
    level = 0;
    for k = 0:kmax
        Mk = sum(Q .* reshape(w.*s.^k,1,1,[]),3);
        level = max(level,max(abs(Mk(:))));
    end
    level = level/scale;
end
