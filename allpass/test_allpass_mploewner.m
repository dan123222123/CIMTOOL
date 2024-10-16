function [Db,Ds] = test_allpass_mploewner(n)
    [Epsilon,xi] = allpass_error_tf(n);

    E = @(s) Epsilon(s)*Epsilon(-s)';
    %E = @(s) Epsilon(s);
    y = linspace(n+1,4*n,100);
    nvals = zeros(length(y),length(y));
    for i=1:length(y)
       parfor j=1:length(y)
           s = y(i) + y(j)*1i;
           nvals(i,j) = norm(E(s));
       end
    end
    %display(max(max(nvals))-xi^2);
    surf(nvals)
    display(xi^2);

    %T = @(s) inv(Epsilon(s));
    %N = 1024; contour = Contour.Circle(0,inv(xi)^2*1.5,N);
    T = @(s) Epsilon(s);
    N = 1024; contour = Contour.Circle(0,xi^2*1.5,N);
    K = n;
    [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
    L = Numerics.SampleData.sampleMatrix(n,K);
    R = Numerics.SampleData.sampleMatrix(n,K);
    ell = K; r = ell;
    Lt = L(:,1:ell); Rt = R(:,1:r);
    [Db,Ds] = Numerics.build_mploewner_data(T,theta,sigma,Lt,Rt);
end