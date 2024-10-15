function [Db,Ds] = test_allpass_mploewner(n)
    [Epsilon,xi] = allpass_error_tf(n);

    %E = @(s) Epsilon(s)*Epsilon(-s)';
    %%E = @(s) Epsilon(s);
    %y = linspace(50,100,100);
    %cvals = zeros(length(y),length(y));
    %nvals = zeros(length(y),length(y));
    %for i=1:length(y)
    %    parfor j=1:length(y)
    %        s = i + j*1i;
    %        nvals(i,j) = norm(E(s));
    %    end
    %end
    %display(max(max(nvals)));

    T = @(s) inv(Epsilon(s));
    N = 256; contour = Contour.Circle(0,inv(xi)^2*1.25,N);
    K = n;
    [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
    L = Numerics.SampleData.sampleMatrix(n,K);
    R = Numerics.SampleData.sampleMatrix(n,K);
    ell = K; r = ell;
    Lt = L(:,1:ell); Rt = R(:,1:r);
    [Db,Ds] = Numerics.build_mploewner_data(T,theta,sigma,Lt,Rt);
end