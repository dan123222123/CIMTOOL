##
using LinearAlgebra
using MAT
using KernelAbstractions
using Plots, LaTeXStrings
using Measures

using AMDGPU
backend = ROCBackend()

using KAPseudospectra

function cpsa(Db,Ds,ereig,γ,δ)
    T = ComplexF64
    Db = convert.(T,Db)
    Ds = convert.(T,Ds)
    ereig = complex(ereig)
    m = length(ereig);
    #
    U,Σ,V = svd(Db); Σ = diagm(Σ);
    U=U[:,1:m]; Σ=Σ[1:m,1:m]; V=V[:,1:m];
    Dbpsa = Σ
    Dspsa = U'*Ds*V
    pew = eigvals(Dspsa / Dbpsa)
    #pew = filter!(!isnan,pewfull)
    #
    wgs = 1024
    g = 300
    nit = min(size(Db,1),4)
    padscale = (-minimum(abs.(pew)),minimum(abs.(pew)))
    rwind = (minimum(real.([ereig;pew])),maximum(real.([ereig;pew]))).+padscale
    iwind = (minimum(imag.([ereig;pew])),maximum(imag.([ereig;pew]))).+(4 .* padscale)
    gx, gy, zg = qgrid(T, rwind, iwind, (g, g))
    P = MatrixPencil(schur(Dspsa, Dbpsa))
    srg = ihlpsa(backend, zg, P, nit, γ, δ; wgs, zpd=10000,progress=true)

    return srg,pew,gx,gy,rwind,iwind
end

function ppsa(srg, gx, gy, rwind, iwind, pew, ereig; tv=missing, clims=missing, colorbar=true)
    pyplot()
    if ismissing(clims)
        clims = extrema(log10.(srg))
    end
    if ismissing(tv)
        tv = floor(Int,clims[1]):0.1:ceil(Int,clims[2])
    end
    tl = [L"10^{%$i}" for i in tv]
    levels = tv
    plt = plot(size=(2000, 2000))
    color = :darkrainbow
    clabels = false
    contourf!(gx, gy, log10.(srg); clims, color,
    levels, colorbar_ticks=(tv, tl), colorbar,
    line=(1, :solid), clabels, legend=:outertop, legend_column = -1)
    #contourf!(gx, gy, log10.(srg); color=:darkrainbow, clims=clims, colorbar=false,
    #line=(1, :solid), legend=:outertop, legend_column = -1)
    scatter!(pew, markershape=:octagon, markersize=7, label="cmp")
    scatter!(complex([Iterators.flatten(ereig)...]), markershape=:diamond, label="ref")
    xlims!(rwind...)
    ylims!(iwind...)

    return plt

end

function pcpsa(Db,Ds,ereig,γ,δ;tv=missing,clims=missing,colorbar=true)
    srg,pew,gx,gy,rwind,iwind = cpsa(Db,Ds,ereig,γ,δ)
    ppsa(srg,gx,gy,rwind,iwind,pew,ereig;tv,clims,colorbar)
end

function rcpsa(fname)
    vars = matread(fname);
    pcpsa(vars["Db"],vars["Ds"],vars["rew"],1,1)
    #srg1,pew1,gx,gy,rwind,iwind = cpsa(vars["Db"],vars["Ds"],vars["rew"],1,1)
    #clims = extrema(log10.(srg1))
    #tv = floor(Int,clims[1]):0.1:ceil(Int,clims[2])
    #tl = [L"10^{%$i}" for i in tv]
    #p1 = ppsa(srg1,gx,gy,rwind,iwind,pew1,vars["rew"];tv,clims);
    #cb = scatter([0,0], [0,1], zcolor=[0,3], color=:darkrainbow, clims=(floor(Int,clims[1]),ceil(Int,clims[2])), colorbar_ticks=(tv, tl),
    #             xlims=(1,1.1), framestyle=:none, grid=false, label="", yticks=tv)
    #l = @layout [p1{0.9w} cb{0.1w}]
    #plot(p1, cb, layout = l, link=:all, margin=0mm)
end

function rcpsass(ddir,exname)
    exHankel = ddir * exname * "Hankel.mat"
    exMPLoewner = ddir * exname * "MPLoewner.mat"
    vars1 = matread(exHankel);
    vars2 = matread(exMPLoewner);
    srg1,pew1,gx,gy,rwind,iwind = cpsa(vars1["Db"],vars1["Ds"],vars1["rew"],1,1)
    srg2,pew2,_,_,_,_ = cpsa(vars2["Db"],vars2["Ds"],vars2["rew"],1,1)
    clims = extrema([log10.(srg1);log10.(srg2)])
    tv = floor(Int,clims[1]):0.1:ceil(Int,clims[2])
    p1 = ppsa(srg1,gx,gy,rwind,iwind,pew1,vars1["rew"];tv,clims,colorbar=true);
    p2 = ppsa(srg2,gx,gy,rwind,iwind,pew2,vars2["rew"];tv,clims,colorbar=true);
    plot(p1,p2,link=:all,layout=grid(1,2))

    #tl = [L"10^{%$i}" for i in tv]
    #cb = scatter([0,0], [0,1], zcolor=[0,3], color=:darkrainbow, clims=(floor(Int,clims[1]),ceil(Int,clims[2])), colorbar_ticks=(tv, tl),
    #             xlims=(1,1.1), framestyle=:none, grid=false, label="", yticks=tv)
    #l = @layout [p1{0.4w} p2{0.4w} cb{0.1w}]
    #plot(p1, p2, cb, layout = l, link=:all, margin=0mm)
end
##

## side by side
ddir = (@__DIR__) * "/ex5Data/"
ex = "ex2"
rcpsass(ddir, ex)
##

## single
ddir = (@__DIR__) * "/ex5Data/"
ex = "ex1"
#vars = matread(ddir*ex*"Hankel.mat")
#rcpsa(ddir * ex * "MPLoewner.mat")
rcpsa(ddir * ex * "Hankel.mat")
##