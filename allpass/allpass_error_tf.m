function [Epsilon,xi] = allpass_error_tf(n,rsv)
arguments
    n
    rsv = 2
end
lspc = linspace(-2,-1,n);
A = diag(lspc); B = rand(n,n); C = B'; D = 0;
sysorg = ss(A,B,C,D);
sysbt = getrom(reducespec(sysorg,"balanced"));
sysbr = balreal(sysbt);

% check observability and reachability of the balanced+"reduced" system
assert(rank(obsv(sysbr)) == rank(ctrb(sysbr)));
assert(rank(obsv(sysbr)) == n);

% matlab bt
A = sysbr.A; B = sysbr.B; C = sysbr.C; D = sysbr.D;
Gram = gram(sysbr, 'c');
G = @(s) C*((s*speye(size(A)) - A)\B) + D;

% partition + permute, assumed that rsv is simple
%rsv = 2;
ord = 1;

% perm mat
[Gramhat,P] = shuffleend(Gram,rsv);
Ahat = P*A*P'; Bhat = P*B; Chat = C*P'; Dhat = D;
%
Sigmahat = Gramhat(1:end-1,1:end-1);
xi = Gramhat(end,end);

% check that the lyapunov equations are satisfied by original and
% permuted system
assert(norm(A'*Gram + Gram*A + C'*C) < sqrt(eps));
assert(norm(A*Gram + Gram*A' + B*B') < sqrt(eps));
assert(norm(Ahat'*Gramhat + Gramhat*Ahat + Chat'*Chat) < sqrt(eps));
assert(norm(Ahat*Gramhat + Gramhat*Ahat' + Bhat*Bhat') < sqrt(eps));

% construct SigmaTilde
A11 = Ahat(1:end-ord,1:end-ord); A12 = Ahat(1:end-ord,end-ord+1:end);
A21 = Ahat(end-ord+1,1:end-ord); A22 = Ahat(end-ord+1:end,end-ord+1:end);
%
B1 = Bhat(1:end-ord,:); B2 = Bhat(end-ord+1:end,:);
%
C1 = Chat(:,1:end-ord); C2 = Chat(:,end-ord+1:end);
%
Gamma = Sigmahat^2 - xi^2*eye(n-ord);
U = pinv(C2')*B2;
%
Atilde = Gamma\(xi^2*A11' + Sigmahat*A11*Sigmahat + xi*C1'*U*B1');
Btilde = Gamma\(Sigmahat*B1 - xi*C1'*U);
Ctilde = C1*Sigmahat - xi*U*B1';
Dtilde = Dhat + xi*U;
systilde = ss(Atilde,Btilde,Ctilde,Dtilde);

% tf of SigmaTilde
Gtilde = @(s) Ctilde*((s*eye(size(Atilde)) - Atilde) \ Btilde) + Dtilde;
Epsilon = @(s) G(s) - Gtilde(s);
end