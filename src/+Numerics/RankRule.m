classdef RankRule
% How computeRealization chooses the realization order m when RealizationData.AutoRank is true.
    enumeration
        Tolerance   % m = the numerical rank of Db under options.AbsTol and options.RelTol (Numerics.rankdet)
        Gap         % m = the index of the largest singular-value gap of Db (Numerics.rankgap), also when the gap is below options.GapMin
    end
end
