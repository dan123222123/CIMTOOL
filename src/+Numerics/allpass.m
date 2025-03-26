function [A,B,C,D] = allpass(n)
    % """Allpass.
    % 
    % Parameters:
    %     n: This is n
    % """
    A = gallery('tridiag',n,-1,0,1);
    A(1,1) = -0.5;
    B = sparse(1,1,1,n,1);
    C = -B';
    D = 1;
end
