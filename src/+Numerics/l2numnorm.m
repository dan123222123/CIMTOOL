function H2N = l2numnorm(H)

    % cfun = @(w) trace(feval(H,1i*w)'*feval(H,1i*w));
    cfun = @(w) norm(feval(H,1i*w),"fro")^2; ccfun = @(z) arrayfun(cfun,z);
    H2N = sqrt(integral(ccfun,-Inf,Inf,'RelTol',0,'AbsTol',1e-12));

end