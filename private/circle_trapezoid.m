function [z,w] = circle_trapezoid(N,gamma,rho)
    q = @(N) ((2*pi)/N)*((1:N) - (1/2));
    f = @(theta) gamma + rho*exp(1i*theta);
    wfun = @(theta) (rho/N)*exp(1i*theta);
    
    z = f(q(N));
    w = wfun(q(N));
end

