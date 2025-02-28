function nboderelerr_surf(H,Hr,x,y)
    arguments
        H
        Hr
        x 
        y = []
    end
    if isempty(y)
        y = x;
    end
    [X,Y] = meshgrid(x,y); Herr = @(z) H(z) - Hr(z);
    Hg = arrayfun(H,X+1i*Y,'UniformOutput',false); nHg = cellfun(@norm,Hg);
    Hgerr = arrayfun(Herr,X+1i*Y,'UniformOutput',false); nHgerr = cellfun(@norm,Hgerr);
    %
    surf(X,Y,(nHgerr ./ nHg));
    title("Pointwise Relative Error Surface",'Interpreter','latex');
    xlabel("$\bf{R}$",'Interpreter','latex'); 
    ylabel("$i \bf{R}$",'Interpreter','latex');
    zlabel("$\frac{\Vert H(z) - H_r(z) \Vert_F}{\Vert H(z) \Vert_F}$",'Interpreter','latex');
    zscale log; %set(get(gca,'zlabel'),'rotation',0);
end
    