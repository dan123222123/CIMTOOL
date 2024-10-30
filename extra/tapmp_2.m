function [Db,Ds] = tapmp_2()
    [s,Epsilon] = allpass_2();
    m = 2;

    P = lyap(s.A,-s.B*s.B');
    assert(max(abs(svd(P))) - min(abs(svd(P))) < 2*eps)

    %T = @(s) inv(Epsilon(s));
    T = @(s) Epsilon(s);
    N = 1024; contour = Contour.Circle(0,5,N);
    K = 2;
    [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
    L = Numerics.SampleData.sampleMatrix(1,K);
    R = Numerics.SampleData.sampleMatrix(1,K);
    ell = K; r = ell;
    Lt = L(:,1:ell); Rt = R(:,1:r);
    [Db,Ds,B,C] = Numerics.build_mploewner_data(T,theta,sigma,Lt,Rt);
    [X,Sigma,Y] = svd(Db,"matrix");
    X=X(:,1:m); Sigma=Sigma(1:m,1:m); Y=Y(:,1:m);
    [Lambda,V] = Numerics.realize(X,Sigma,Y,Ds,C);
end