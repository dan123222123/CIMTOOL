function HinfN = linfnumnorm_siso(H)

    cfun = @(w) abs(feval(H,1i*w)); ccfun = @(z) arrayfun(cfun,z);
    HinfN = max(ccfun([-logspace(-6,6) logspace(-6,6)]));

end