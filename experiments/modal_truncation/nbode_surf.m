function nbode_surf(H,x,y)
    arguments
        H
        x
        y = []
    end
    if isempty(y)
        y = x;
    end
    [X,Y] = meshgrid(x,y);
    Hg = arrayfun(H,X+1i*Y,'UniformOutput',false); nHg = cellfun(@norm,Hg);
    %
    surf(X,Y,nHg);
    title("Response Surface",'Interpreter','latex');
    xlabel("$\bf{R}$",'Interpreter','latex');
    ylabel("$i \bf{R}$",'Interpreter','latex');
    zlabel("$\Vert H(z) \Vert_F$",'Interpreter','latex');
    zscale log; %set(get(gca,'zlabel'),'rotation',0);
end
