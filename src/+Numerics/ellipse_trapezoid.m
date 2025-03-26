function [z,w] = ellipse_trapezoid(N,gamma,alpha,beta)
    q = @(N) ((2*pi)/N)*((1:N) - (1/2));
    f = @(theta) gamma + (alpha*cos(theta) + 1i*beta*sin(theta));
    wfun = @(theta) (beta*cos(theta) + 1i*alpha*sin(theta))/N;
    
    z = f(q(N));
    w = wfun(q(N));
end

