function [s,Epsilon] = allpass_2()
    a = 5; b = -3;
    c = sqrt(2*a*((a+b)/(a-b)));
    d = sqrt(-2*b*((a+b)/(a-b)));
    A = [a 0; 0 b]; B = [c;d]; C = [c -d]; D = 1;
    s = ss(A,B,C,D);
    Epsilon = @(s) C*((s*eye(size(A)) - A)\B) + D;
    %
    P = lyap(s.A,-s.B*s.B');
    assert(max(abs(svd(P))) - min(abs(svd(P))) < 2*eps)
end