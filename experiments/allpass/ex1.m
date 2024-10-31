format long
axis equal
%%
n = 4;
lr = linspace(-n,-1,n);
refeig = lr;
% refeig = -1 + 1i*lr;
A = diag(refeig); 

%%
B = rand(n,n); C = B'; D = 0;
% B = eye(n); C = B'; D = 0;

%%
rsv = 2; [Ess,Etf] = allpass_error_ssin_sstfout(A,B,C,D,rsv);

%%
K = n+n-1;
% K = 2*n;
% K = 100*n;
[Db,Ds,refeig,cmpeig,nmderr,pairedeigs] = allpass_realization_exact_mploewner_sstfin(Ess,Etf,K);
%
scatter(real(refeig),imag(refeig),200,MarkerFacecolor='r');
hold on;
pairedcmpeigs = pairedeigs(:,2);
scatter(real(pairedcmpeigs),imag(pairedcmpeigs),50,'b');
hold off;
%
% display(pairedeigs)
display(abs(pairedeigs(:,1)-pairedeigs(:,2)))
display(nmderr)

% try irka interpolants
% optimal weighting of interpolation points
% pseudospectra of "real-world" example -- imaginary axis, etc.
% optimization of weights given some data -- no more tf evaluations
% another idea, perturb interpolation points a bit and try to backtrace to
% recover weights that solve the slightly perturbed interpolants