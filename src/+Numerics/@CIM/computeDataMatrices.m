function computeDataMatrices(obj)
% Builds the data matrices from the current samples and stores them in ResultData
% if rank < m, they stay in ResultData for inspection
    obj.buildDataMatrices();
    rd = obj.ResultData;
    rd.X = []; rd.Sigma = []; rd.Y = [];   % the SVD of the replaced Db
    obj.clearRealization();
end
