function [Db,Ds,ereig] = test_allpass_error_mploewner(n,theta,sigma)
    arguments
        n
        theta = missing
        sigma = missing
    end

    % create error system
    [Ess,Etf] = allpass_error_sstf(n,1);
    % know, by construction, that there will be 2*n - 1 poles in the state-space
    %m = 2*n - 1;
    n = length(Etf(0));
    m = length(Ess.A);

    % poles of the error system
    ereig = eig(Ess.A);

    %% quick visual check that Etf "looks" all-pass
    %y = linspace(-2*n,2*n,100);
    %nvals = zeros(length(y),length(y));
    %for i=1:length(y)
    %   parfor j=1:length(y)
    %       s = y(i) + y(j)*1i;
    %       nvals(i,j) = norm(Etf(s)*Etf(-s)');
    %   end
    %end
    %surf(y,y,nvals)
    %xlabel("R")
    %ylabel("iR")

    % oversampling, perhaps?
    %K = 2*m-2; % why does this seem to work more often? so confusing...
    K = m+floor(m/2);
    %K = m;

    % set interpolation points, if unset
    if ismissing(theta) && ismissing(sigma)
        contour = Contour.Circle(0,max(abs(ereig))*1.01,1024);
        [theta,sigma] = Numerics.interlevedshifts(contour.z,K);
    end

    % sample data matrices
    L = Numerics.SampleData.sampleMatrix(n,K);
    R = Numerics.SampleData.sampleMatrix(n,K);

    % repeated sampling, if desired
    ell = K; r = ell;
    Lt = L(:,1:ell); Rt = R(:,1:r);

    % building the data matrices
    [Db,Ds] = Numerics.build_mploewner_data(Etf,theta,sigma,Lt,Rt);

end