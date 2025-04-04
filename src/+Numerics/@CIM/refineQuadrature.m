function refineQuadrature(obj)
    % old auto values -- we set them back at the end
    acs = obj.auto_compute_samples; acr = obj.auto_compute_realization; aem = obj.auto_estimate_m; aus = obj.auto_update_shifts;
    obj.auto_compute_samples = false; obj.auto_compute_realization = false; obj.auto_estimate_m = false; obj.auto_update_shifts = false;

    % refine the quadrature and compute
    try
        obj.SampleData.refineQuadrature();
        obj.compute();
        obj.auto_compute_samples = acs; obj.auto_compute_realization = acr; obj.auto_estimate_m = aem; obj.auto_update_shifts = aus;
    catch e
        obj.auto_compute_samples = acs; obj.auto_compute_realization = acr; obj.auto_estimate_m = aem; obj.auto_update_shifts = aus;
        rethrow(e);
    end
end