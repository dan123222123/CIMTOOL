function buildDataMatrices(obj)
% Builds the data matrices from the current samples (the leading ell and r directions) and stores them in ResultData
% Errors (Numerics:SampleData:stale) when the samples are not current, e.g. after raising ell or r above the sampled count.
    import Numerics.sploewner.sploewner_quadrature_data Numerics.mploewner.mploewner_quadrature_data;
    K = obj.RealizationData.K;
    [theta,sigma] = obj.RealizationData.getThetaSigma(K,K);
    sd = obj.SampleData;
    sd.checkSamples();   % current, and covering ell and r; the build reads the leading ones in place
    switch(obj.RealizationData.ComputationalMode)
        case Numerics.ComputationalMode.Hankel   % sigma = Inf by definition, whatever InterpolationData holds
            [Db,Ds,B,C] = sploewner_quadrature_data(Inf,sd.Contour.z,sd.Contour.w,sd.Ql,sd.Qr,sd.Qlr,K,sd.ell,sd.r);
            BB = []; CC = [];
        case Numerics.ComputationalMode.SPLoewner
            [Db,Ds,B,C] = sploewner_quadrature_data(sigma(1),sd.Contour.z,sd.Contour.w,sd.Ql,sd.Qr,sd.Qlr,K,sd.ell,sd.r);
            BB = []; CC = [];
        case Numerics.ComputationalMode.MPLoewner
            [Db,Ds,B,BB,C,CC] = mploewner_quadrature_data(sd.Contour.z,sd.Contour.w,sd.Ql,sd.Qr,sd.L,sd.R,theta,sigma, ...
                obj.options.PadStrategy,obj.options.Verbose);
    end
    rd = obj.ResultData;
    rd.Db = Db; rd.Ds = Ds; rd.B = B; rd.BB = BB; rd.C = C; rd.CC = CC;
end
