function [m,ratio] = rankgap(Sigma)
% Numerical rank of a matrix from its singular values Sigma (as returned by svd): the m with the largest ratio sigma_m/sigma_{m+1},
% after raising each singular value to the floor max(size(Sigma))*eps(sigma_1) of Numerics.rankdet, so exact zeros and the roundoff tail tie.
% ratio is that largest ratio (Inf for a single singular value, NaN when sigma_1 = 0); m = 0 when Sigma is empty or zero.
    k = min(size(Sigma));
    s = diag(Sigma(1:k,1:k));   % diag of a vector would build a matrix
    if isempty(s) || s(1) == 0
        m = 0; ratio = NaN;
        return;
    end
    if isscalar(s)
        m = 1; ratio = Inf;
        return;
    end
    t = max(s,max(size(Sigma))*eps(s(1)));
    g = log10(t(1:end-1)) - log10(t(2:end));
    [~,m] = max(g);   % the first maximum on ties
    ratio = t(m)/t(m+1);
end
