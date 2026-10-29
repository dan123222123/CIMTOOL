function computeRealization(obj)
% Builds the data matrices (as computeDataMatrices), then realizes them at RealizationSize.m or, under RealizationData.AutoRank, at the m
% that RealizationData.RankRule chooses: the numerical rank of Db under the tolerances in options (Tolerance), or its largest singular-value gap (Gap).
% Gap realizes at the largest gap, however small; its ratio sigma_m/sigma_{m+1} goes to ResultData.GapRatio (NaN for any other choice of m),
% and a ratio below options.GapMin, a weak gap, warns under options.Verbose.
% The m used goes to ResultData.m; an automatic m is never written to RealizationSize.m.
% Under AutoRank, a contour whose samples have moments at the noise level (Numerics.momentlevel below options.EmptyTol) encloses
% no eigenvalue: m = 0 before either rule sees Db, whose singular values are then noise that the relative rules would read as full rank.
% An m of 0 gives an empty realization, not an error.
% The SVD of Db is stored before m is checked, so a refused m leaves Db and its singular values in ResultData for choosing m;
% any failure clears the eigenpairs.
    rd = obj.ResultData;
    try
        obj.buildDataMatrices();
        reltol = NaN;
        if isfield(obj.options,"RelTol"); reltol = obj.options.RelTol; end
        [rk,X,Sigma,Y] = Numerics.rankdet(rd.Db,obj.options.AbsTol,reltol);
        [rd.X,rd.Sigma,rd.Y] = deal(X,Sigma,Y);
        auto = obj.RealizationData.AutoRank;
        emptytol = 1e-10;
        if isfield(obj.options,"EmptyTol"); emptytol = obj.options.EmptyTol; end
        gapratio = NaN;
        if ~auto
            m = obj.RealizationData.RealizationSize.m;
        elseif obj.contourMomentLevel() < emptytol
            m = 0;
        elseif obj.RealizationData.RankRule == Numerics.RankRule.Tolerance
            m = rk;
        else
            [m,gapratio] = Numerics.rankgap(Sigma);
            gapmin = 1e3;
            if isfield(obj.options,"GapMin"); gapmin = obj.options.GapMin; end
            if gapratio < gapmin && obj.options.Verbose
                warning("Numerics:rankgap:noGap", ...
                    "The largest singular-value gap of Db, sigma_%d/sigma_%d = %.1e, is below options.GapMin = %.1e; " + ...
                    "realizing at m = %d anyway. Refining the quadrature, or raising K, may open a gap.", m, m + 1, gapratio, gapmin, m);
            end
        end
        assert(m > 0 || auto, "# Eig Search should be > 0");
        if obj.RealizationData.ComputationalMode == Numerics.ComputationalMode.MPLoewner
            % as in mploewner_quadrature: the Loewner pencil is numel(theta)-by-numel(sigma)
            K = obj.RealizationData.K;
            [theta,sigma] = obj.RealizationData.getThetaSigma(K,K);
            if min(numel(theta),numel(sigma)) < m
                error("Numerics:mploewner:tooFewPoints", ...
                    "Need at least m=%d interpolation points on each side to recover %d poles; got numel(theta)=%d, numel(sigma)=%d.", ...
                    m, m, numel(theta), numel(sigma));
            end
        end
        if ~auto && rk < m   % as Numerics.realize, whose SVD this is
            error("Numerics:realize:rankDeficient","generated rank %d < %d data matrix",rk,m);
        end
        if m == 0   % shaped as realize_dbsvd's output
            ew = zeros(0,1); rev = zeros(size(rd.C,1),0); lev = zeros(0,size(rd.B,2));
        else
            [ew,rev,lev] = Numerics.realize_dbsvd(m,X,Sigma,Y,rd.Ds,rd.B,rd.C,0);   % rank checked above, or m chosen from Sigma
        end
    catch err
        obj.clearRealization();
        rethrow(err);
    end
    rd.GapRatio = gapratio;
    rd.m = m;   % before ew, so a listener on ew sees the m it was realized with
    [rd.ew,rd.rev,rd.lev] = deal(ew,rev,lev);
    obj.RealizationData.loaded = true;
end
