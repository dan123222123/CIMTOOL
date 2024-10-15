##
using LinearAlgebra
using MATLAB
using KernelAbstractions
using Plots, LaTeXStrings

using AMDGPU
backend = ROCBackend()

using KAPseudospectra
mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL')"
mat"addpath('/home/dfolescu/version_control/git/math/code/packages/CIMTOOL/allpass')"
##

##
wgs = 1024
T = ComplexF64
g = 1000
nit = 5
##

##
# I can't pass n to the matlab engine...OMGGGGGG
mat"[Db,Ds] = test_allpass_mploewner(30)"
n = 30

Db = @mget Db
Ds = @mget Ds

pev = eigvals(Ds, Db)
##

##
padscale = 2
rwind = (minimum(real.(pev)),maximum(real.(pev))).*padscale
iwind = (minimum(imag.(pev)),maximum(imag.(pev))).*padscale
#rwind = (-0.5,0.5)
#iwind = (-0.5,0.5)
gx, gy, zg = qgrid(T, rwind, iwind, (g, g))
P = MatrixPencil(schur(Ds, Db))
srg = ihlpsa(backend, zg, P, nit; wgs)
##

##
tv = -5:0.05:5
tl = [L"10^{%$i}" for i in tv]
levels = tv
plt = plot(size=(1000, 1000))
color = :darkrainbow
clabels = false
contour!(gx, gy, log10.(srg); color, colorbar_ticks=(tv, tl), levels, line=(1, :solid), clabels)
scatter!(eigvals(Ds, Db), markershape=:diamond, label="")
xlims!(rwind...)
ylims!(iwind...)
###