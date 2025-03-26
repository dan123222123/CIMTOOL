% issue here is that Loewner does significantly worse than Hankel for
% modestly sized N -- we examine how exact Loewner would fare with a
% linearized omnicam problem
%%
nlevp = Numerics.NLEVPData(missing,'omnicam1');
contour = Numerics.Contour.Circle(0.4,0.2,8);
CIM = Numerics.CIM(nlevp,contour);
CIM.RealizationData.m = 3;
L = Numerics.SampleData.sampleMatrix(nlevp.n,nlevp.n);
R = Numerics.SampleData.sampleMatrix(nlevp.n,nlevp.n);
%%
coeffs = nlevp.coeffs;
coeffsT = cellfun(@transpose,coeffs,'UniformOutput',false);

% get left and right eigenvectors of omnicam1
[V,er] = polyeig(coeffs{:});
[W,el] = polyeig(coeffsT{:});

% sort the eigenvalues and permute the eigenvectors accordingly
% omicam1 itself has a non-simple ew at 0, but it shouldn't be degenerate,
% afaik
[er,ero] = sort(er); V = V(:,ero);
[el,elo] = sort(el); W = W(:,elo);

% check that the left and right eigenvectors match up as indended
for i=1:length(el)
    assert(norm(nlevp.T(er(i))*V(:,i)) < 10^-10);
    assert(norm(transpose(W(:,i))*nlevp.T(el(i))) < 10^-10);
end

% find only ew inside the contour and create local lti tf from them+l/r ev
innerewidx = contour.inside(er);
Hi = @(z) V(:,innerewidx) * inv(z*eye(nnz(innerewidx)) - diag(er(innerewidx))) * W(:,innerewidx)';
%%
c = CIMTOOL(CIM);
ell = 3; r = ell;
Lt = L(:,1:ell); Rt = R(:,1:r);
CIM.SampleData.Lf = L; CIM.SampleData.Rf = R;
CIM.SampleData.ell = ell; CIM.SampleData.r = r;
%% Hankel
K = 1;
M = Numerics.build_moments(diag(er(innerewidx)),W(:,innerewidx)'*Rt,Lt'*V(:,innerewidx),K);
[Db,Ds] = Numerics.build_sploewner_data(M,Inf);
refew = eig(Ds,Db);
CIM.SampleData.NLEVP.refew = refew;
CIM.RealizationData.K = K;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.Hankel;
CIM.compute();
%% Loewner
K = 3;
[theta,sigma] = Numerics.interlevedshifts(contour.z,K);
CIM.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
[Lb,Ls] = Numerics.build_mploewner_data(Hi,theta,sigma,Lt,Rt);
refew = eig(Ls,Lb);
CIM.SampleData.NLEVP.refew = refew;
CIM.RealizationData.K = K;
CIM.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
CIM.compute();
