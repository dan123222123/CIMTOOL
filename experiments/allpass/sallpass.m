function [A,B,C,D] = sallpass(n)
% allpass (all-pass system)
% by Christian Himpe, 2020
% released under BSD 2-Clause License
%*

    A = gallery('tridiag',n,-1,0,1);
    A(1,1) = -0.5;
    A = full(A);
    B = full(sparse(1,1,1,n,1));
    C = -B';
    D = 1;
end
