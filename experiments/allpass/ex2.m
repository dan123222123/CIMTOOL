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

L = Numerics.SampleData.sampleMatrix(n,1000*n);
R = Numerics.SampleData.sampleMatrix(n,1000*n);

%%
rsv = 2; [Ess,Etf] = allpass_error_ssin_sstfout(A,B,C,D,rsv);
errpoles = sort(eig(Ess.A));

%% construct theta and sigma so that irka points are the majority
K = n+n-1; % the number of poles in the allpass error system
% K = 2*n;
% K = 2*n+2;
% K = 10*n;

ell = K; r = ell; Lt = L(:,1:ell); Rt = R(:,1:r);

theta = double.empty(); sigma = double.empty();

tol = 10^-2;
for i=1:length(errpoles)
    ceig = errpoles(i);
    cerrpoles = errpoles;
    cerrpoles(i) = [];
    md = min(abs(cerrpoles+ceig));
    if md >= tol
        if mod(i,2) == 1
            theta(end+1) = -ceig;
        else
            sigma(end+1) = -ceig;
        end
    end
end

figure(1)

scatter(real(theta),imag(theta),"DisplayName","theta-irka");
hold on;
scatter(real(sigma),imag(sigma),"DisplayName","sigma-irka");

thetaextra = theta; sigmaextra = sigma;

while (length(thetaextra) < K || length(sigmaextra) < K)

    mith = min(min(thetaextra),min(errpoles)); misi = min(min(sigmaextra),min(errpoles));
    math = max(max(thetaextra),max(errpoles)); masi = max(max(sigmaextra),max(errpoles));
    
    lth = length(thetaextra); lsi = length(sigmaextra);

    if lth < lsi
        if abs(mith) >= abs(math)
            thetaextra(end + 1) = ceil(masi) + 1;
        else
            thetaextra(end + 1) = floor(misi) - 1;
        end
    else
        if abs(misi) >= abs(masi)
            sigmaextra(end + 1) = ceil(math) + 1;
        else
            sigmaextra(end + 1) = floor(mith) - 1;
        end
    end

end

thetaint = setdiff(thetaextra,theta);
sigmaint = setdiff(sigmaextra,sigma);

scatter(real(thetaint),imag(thetaint),"DisplayName","theta-extra");
scatter(real(sigmaint),imag(sigmaint),"DisplayName","sigma-extra");
scatter(real(errpoles),imag(errpoles),"DisplayName","Aug A Eigs",Marker="+")
legend(gca)
hold off;
%%

theta = sort(thetaextra); sigma = sort(sigmaextra);
% theta = sort(thetaextra)*1i; sigma = sort(sigmaextra)*1i;

% delta = 10^-3;
% Eb = randn(K); DbE = delta*(Eb / norm(Eb));
% Es = randn(K); DsE = delta*(Es / norm(Es));

DbE = 0;
DsE = 0;

[Db,Ds,refeig,cmpeig,nmderr,pairedeigs] = allpass_realization_exact_mploewner_sstfin(Ess,Etf,K,theta,sigma,Lt,Rt,DbE,DsE);

figure(2);
scatter(real(refeig),imag(refeig),200,MarkerFacecolor='r');
hold on;
pairedcmpeigs = pairedeigs(:,2);
scatter(real(pairedcmpeigs),imag(pairedcmpeigs),50,'b');
hold off;
axis(gca,"equal")

% display(pairedeigs)
% display(abs(pairedeigs(:,1)-pairedeigs(:,2)))
display(nmderr)

%

% figure(3); imagesc(log(abs(Db))); colorbar; clim([-10 1]); title("Db");
% figure(4); imagesc(log(abs(Ds))); colorbar; clim([-10 1]); title("Ds");

%%% -7 days
% try irka interpolants
% optimal weighting of interpolation points
% pseudospectra of "real-world" example -- imaginary axis, etc.
% optimization of weights given some data -- no more tf evaluations
% another idea, perturb interpolation points a bit and try to backtrace to
% recover weights that solve the slightly perturbed interpolants
%%% 11/6/2024
