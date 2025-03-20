function plot_gdresidues(refew,obsew,V,W,tol)
arguments
    refew 
    obsew 
    V 
    W 
    tol = 10^-2
end
    nres = nresidues(V,W); [gd,uc] = gdist(refew,obsew,tol);
    scatter(gd,nres); hold on; scatter(gd(uc),nres(uc),'red');
    xscale("log"); yscale("log");
    xlabel(sprintf("Greedy & Converged (tol=%.0d)\n Eigenvalue Matching Distance",tol));
    ylabel("Norm of Residue");
    title("GCEMD vs Residue Norm");
end