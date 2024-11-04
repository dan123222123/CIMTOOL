% theta and sigma should have nsw shifts each!
function [theta,sigma] = interlevedshifts(z,nsw,d,mode,variant)
arguments
    z 
    nsw 
    d = 1.25
    mode = 'scale'
    variant = 'cconj' % or 'trap'
end

    % get the geometric center
    c = sum(z)/length(z);
    % get the maximum distance between c and quad nodes
    r = max(abs(c - z));
    % nodes on a circle around the current quad nodes
    switch mode
        case 'scale'
            rs = r*d;
        case 'shift'
            rs = r+d;
    end

    theta = double.empty();
    sigma = double.empty();

    switch variant
        case 'cconj'
            z = circquad(c,rs,2*(nsw+1));
        case 'trap'
            z = Numerics.Contour.Circle.trapezoid(c,rs,2*nsw);
    end

    for i=1:length(z)
        cz = z(i);
        if ismissing(cz)
            continue;
        end
        if mod(i,2) == 1
            theta(end+1) = z(i);
        else
            sigma(end+1) = z(i);
        end
    end

    theta = theta.';
    sigma = sigma.';
end

function z = circquad(gamma,rho,N)
    assert(mod(N,2) == 0);
    q = [((2*pi)/N)*(1:(N/2-1)) missing ((2*pi)/N)*((N/2+1):(N-1))];
    f = @(theta) gamma + rho*exp(1i*theta);
    z = f(q);
end