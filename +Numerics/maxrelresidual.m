function [mres,wl] = maxrelresidual(cim)
    relres = zeros(cim.RealizationData.m,1);
    for j = 1:cim.RealizationData.m
        cew = cim.ResultData.ew(j);
        % normalize the ev
        cev = cim.ResultData.ev(:,j)/norm(cim.ResultData.ev(:,j));
        ceval = cim.SampleData.NLEVP.T(cew);
        relres(j) = norm(ceval*cev)/norm(ceval,"fro");
    end
    [mres,li] = max(relres(j));
    wl = cim.ResultData.ew(li);
end