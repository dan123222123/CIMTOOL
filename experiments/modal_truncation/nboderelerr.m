function nboderelerr(H,Hr,w)
    arguments
        H
        Hr
        w = []
    end
    if isempty(w)
        w = logspace(-6,6,5000);
    end
    Herr = @(z) H(z) - Hr(z);
    Hw = arrayfun(H,1i*w,'UniformOutput',false); nHw = cellfun(@norm,Hw);
    Hwerr = arrayfun(Herr,1i*w,'UniformOutput',false); nHwerr = cellfun(@norm,Hwerr);
    loglog(w,(nHwerr./nHw));
    title("Pointwise Relative $\mathcal{L}_2$ Error", 'Interpreter','latex');
    xlabel("$\omega$","Interpreter","latex");
    ylabel("$\frac{\Vert H(i \omega) - H_r(i \omega) \Vert_F}{\Vert H(i \omega) \Vert_F}$","Interpreter","latex");
end
