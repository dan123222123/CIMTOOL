%% Setup SISO system
n = 6; A = diag(-n:-1); B = (1:n)'; C = 1:n;
K = n; % data matrix size/half number of moments
%% ERA
sigma = Inf;
M = Numerics.sploewner.build_exact_moments(sigma,A,B,C,2*K);
[Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
ERA_err = norm(sort(eig(Ds,Db),"descend")-diag(A));
%% realize system on a grid of shifts
N = 160; x = linspace(-10,5,N); y = linspace(-7.5,7.5,N);
[X,Y] = meshgrid(x,y); G = X + 1i*Y;
SPLoewner_err = zeros(N,N);
parfor i=1:N
    for j=1:N
        sigma = G(i,j);
        M = Numerics.sploewner.build_exact_moments(sigma,A,B,C,2*K);
        [Db,Ds] = Numerics.sploewner.build_sploewner(sigma,M,M,M,K);
        SPLoewner_err(i,j) = norm(sort(eig(Ds,Db),"descend")-diag(A));
    end
end
%% Heatmap of Ratio between ERA and SPLoewner
h = heatmap(x,y,log10(ERA_err./SPLoewner_err),Colormap=cool);
% make better labels
CustomXLabels = string(x); CustomYLabels = string(y);
CustomXLabels(mod(x,1) ~= 0) = " "; CustomYLabels(mod(y,0.5) ~= 0) = " ";
h.XDisplayLabels = CustomXLabels; h.YDisplayLabels = CustomYLabels;
grid off;
