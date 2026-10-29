function refineQuadrature(obj)
% refine the current contours's quadrature/sampling data try realization using the new data.

    % old auto values -- we set them back at the end
    aus = obj.auto_update_shifts;
    obj.auto_update_shifts = false;

    try
        obj.SampleData.refineQuadrature();
        obj.compute();
        obj.auto_update_shifts = aus;
    catch e
        obj.auto_update_shifts = aus;
        rethrow(e);
    end
end
