function [theta,sigma] = interlevedshifts(z,nsw,ShiftScale)
arguments
    z 
    nsw 
    ShiftScale = 1.25
end
    % get the geometric center
    c = sum(z)/length(z);
    % get the maximum distance between c and quad nodes
    r = max(abs(c - z));
    % nodes on a circle around the current quad nodes
    z = Contour.Circle.trapezoid(c,r*ShiftScale,2*nsw);
    theta = double.empty();
    sigma = double.empty();
    for i=1:length(z)
        if mod(i,2) == 1
            theta(end+1) = z(i);
        else
            sigma(end+1) = z(i);
        end
    end
    theta = theta.';
    sigma = sigma.';
end