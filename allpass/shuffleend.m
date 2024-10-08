% only 1 entry can be shuffled to the end
% M is assumed to be a square, diagonal matrix
% P is the permutation matrix s.t. Ms = P*M
% i <= size(M,[1,2])
function [Ms,P,Q] = shuffleend(M,idx)
    n = size(M,1); P = eye(n); Q = eye(n);
    for i = idx:n-1
        Z = permij(n,i);
        disp(Z)
        P = Z*P; Q = Q*Z;
    end
    Ms = P*M*Q;
end

% returns left(P) and right(Q) permutation matrices that swaps (i,j) and (i+1,j+1) entry of diagonal matrix
% i,j < n;
function P = permij(n,i)
    P = eye(n);
    P(i,i) = 0; P(i+1,i) = 1;
    P(i+1,i+1) = 0; P(i,i+1) = 1;
end