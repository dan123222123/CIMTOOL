##
using LinearAlgebra
using MATLAB
using MAT
using KernelAbstractions
using Plots, LaTeXStrings
#using DoubleFloats

using AMDGPU
backend = ROCBackend()

using KAPseudospectra
mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL')"
mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL/experiments/allpass')"

function cpsa(Db,Ds,ereig,γ,δ)
    T = ComplexF64
    Db = convert.(T,Db)
    Ds = convert.(T,Ds)
    ereig = convert.(T,ereig)
    #
    U,Σ,V = svd(Db);
    Σ = diagm(Σ);
    Dbpsa = Σ
    Dspsa = U'*Ds*V
    pewfull = eigvals(Dspsa, Dbpsa)
    pew = filter!(!isnan,pewfull)
    #
    wgs = 1024
    g = 1000
    nit = 4
    padscale = (-minimum(abs.(pew)),minimum(abs.(pew)))
    rwind = (minimum(real.([ereig;pew])),maximum(real.([ereig;pew]))).+padscale
    iwind = (minimum(imag.([ereig;pew])),maximum(imag.([ereig;pew]))).+(4 .* padscale)
    gx, gy, zg = qgrid(T, rwind, iwind, (g, g))
    P = MatrixPencil(schur(Dspsa, Dbpsa))
    srg = ihlpsa(backend, zg, P, nit, γ, δ; wgs, zpd=10000,progress=true)

    return srg,pew,gx,gy,rwind,iwind
end

function ppsa(srg, gx, gy, rwind, iwind, pew, ereig; tv=(-10:0.1:-1))
    pyplot()
    tl = [L"10^{%$i}" for i in tv]
    levels = tv
    plt = plot(size=(1000, 1000))
    color = :darkrainbow
    clabels = false
    contourf!(gx, gy, log10.(srg); color,
    colorbar_ticks=(tv, tl), levels,
    line=(1, :solid), clabels, legend=:outertop, legend_column = -1)
    scatter!(pew, markershape=:octagon, markersize=7, label="cmp")
    scatter!(ComplexF64.(ereig), markershape=:diamond, label="ref")
    xlims!(rwind...)
    ylims!(iwind...)

    return plt

end

function pcpsa(Db,Ds,ereig,γ,δ;tv=-7:0.1:-1)
    srg,pew,gx,gy,rwind,iwind = cpsa(Db,Ds,ereig,γ,δ)
    ppsa(srg,gx,gy,rwind,iwind,pew,ereig;tv)
end
##

##
n = 4.0
Db,Ds,ereig = mxcall(:test_allpass_error_mploewner,3,n,2)
pcpsa(Db,Ds,ereig,1,1)
##

##
tv=-5:0.05:-2
d = (@__DIR__) * "/"
savefig(pcpsa(Db,Ds,ereig,1,0;tv),d*"srg1_0.png")
savefig(pcpsa(Db,Ds,ereig,0.75,0.25;tv),d*"srg0.75_0.25.png")
savefig(pcpsa(Db,Ds,ereig,0.5,0.5;tv),d*"srg0.5_0.5.png")
savefig(pcpsa(Db,Ds,ereig,0.25,0.75;tv),d*"srg0.25_0.75.png")
savefig(pcpsa(Db,Ds,ereig,0,1;tv),d*"srg0_1.png")
##

##
mat"ex2"
@mget Db
@mget Ds
ereig = @mget errpoles
##

##
srg,pew,gx,gy,rwind,iwind = cpsa(Db,Ds,ereig,0.5,0.5)
savefig(ppsa(srg,gx,gy,rwind,iwind,pew,ereig; tv=-7:0.05:-5),d*"noisy_srg0.5_0.5.png")
##