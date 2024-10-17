##
using LinearAlgebra
#using MATLAB
using MAT
using KernelAbstractions
using Plots, LaTeXStrings
using DoubleFloats

using AMDGPU
backend = ROCBackend()

using KAPseudospectra
#mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL')"
#mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL/allpass')"
##

##
n = 4.0
Db,Ds,ereig = mxcall(:test_allpass_error_mploewner,3,n)
#m = Int(3*n);
#m = Int(n);
#m = Int(n-1)
U,Σ,V = svd(Db);
Σ = diagm(Σ);
#U = U[:,1:m];
#Σ = Σ[1:m,1:m];
#V = V[:,1:m];
Dbpsa = Σ
Dspsa = U'*Ds*V
#Dbpsa = Db;
#Dspsa = Ds;
pewfull = eigvals(Dspsa, Dbpsa)
pew = filter!(!isnan,pewfull)
##

##
wgs = 1024
T = ComplexF64
g = 1000
nit = 4
padscale = (-minimum(abs.(pew)),minimum(abs.(pew)))
rwind = (minimum(real.(pew)),maximum(real.(pew))).+padscale
iwind = (minimum(imag.(pew)),maximum(imag.(pew))).+padscale
#rwind = (-3,3)
#iwind = (-1,3)
gx, gy, zg = qgrid(T, rwind, iwind, (g, g))
P = MatrixPencil(schur(Dspsa, Dbpsa))
#P = MatrixPencil(schur(Dbpsa))
srg = ihlpsa(backend, zg, P, nit; wgs)
#srg = ℂsvdpsa(zg,Dbpsa)
##

###
#zgeig = reshape(pew,length(pew),1);
#zgeig[37] = zgeig[37] + 0.1
#srgeig = vec(ihlpsa(backend,zgeig,P,nit;wgs))
#pewkeep = findall((eps()), srgeig)
#plt = scatter!(pew[pewkeep], markershape=:octagon, markersize=7, label="",markercolor=:red)
###

##
tv = -20:0.25:1
tl = [L"10^{%$i}" for i in tv]
levels = tv
plt = plot(size=(1000, 1000))
color = :darkrainbow
clabels = false
contour!(gx, gy, log10.(srg); color,
colorbar_ticks=(tv, tl), levels,
line=(1, :solid), clabels)
scatter!(pew, markershape=:octagon, markersize=7, label="")
scatter!(ComplexF64.(ereig), markershape=:diamond, label="")
xlims!(rwind...)
ylims!(iwind...)
###
