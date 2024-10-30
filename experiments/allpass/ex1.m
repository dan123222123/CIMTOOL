format long
%%
n = 4;
lr = linspace(-n,-1,n);
refeig = lr;
% refeig = -1 + 1i*lr;
A = diag(refeig); 

%%
B = randn(n,n); C = B'; D = 0;
% B = eye(n); C = B'; D = 0;

%%
rsv = 1; [Ess,Etf] = allpass_error_ssin_sstfout(A,B,C,D,rsv);
refeig = eig(Ess.A);
%
scatter(real(refeig),imag(refeig),200,MarkerFacecolor='r');
hold on;

%%
% K = n+n-1;
K = 2*n;
[Db,Ds,refeig,cmpeig,nmderr,pairedeigs] = allpass_realization_exact_mploewner_sstfin(Ess,Etf,K);
%
pairedcmpeigs = pairedeigs(:,2);
scatter(real(pairedcmpeigs),imag(pairedcmpeigs),50,'b');
hold off;
%
% display(pairedeigs)
display(abs(pairedeigs(:,1)-pairedeigs(:,2)))
display(nmderr)