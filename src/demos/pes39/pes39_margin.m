% --8<-- [start:margin]
function [tc, zc, nb] = pes39_margin(bank, u)
% Delay margin along the delay direction u (10 x 1): the smallest r at which
% the bank of pes39_bank.m trusts an eigenvalue with positive real part at
% tau = r u. Returns Inf when nothing crosses by 500 ms. zc is the rightmost
% trusted eigenvalue at the margin tc, and nb the number of bank evaluations.

% Step outward from 50 ms until the rightmost trusted eigenvalue crosses, then
% refine the crossing with fzero. The bank's fixed probes make the abscissa a
% deterministic function of r.
r = 0.05;  dr = 0.005;  rmax = 0.5;
[a, z] = abscissa(bank, r*u);  nb = 1;
assert(~isnan(z), 'pes39_margin:empty', 'the bank trusts no eigenvalue at tau = %g s', r);
assert(a < 0, 'pes39_margin:start', 'not stable at tau = %g s', r);
while a <= 0
    r = r + dr;
    if r > rmax, tc = Inf;  zc = NaN;  return; end
    a = abscissa(bank, r*u);  nb = nb + 1;
end
[tc, ~, ~, out] = fzero(@(x) abscissa(bank, x*u), [r - dr, r]);
[~, zc] = abscissa(bank, tc*u);
nb = nb + out.funcCount + 1;
end
% --8<-- [end:margin]

% --8<-- [start:abscissa]
function [a, z] = abscissa(bank, tau)
% The rightmost trusted eigenvalue z in the bank at the delays tau and its real
% part a; a = -1 and z = NaN when the bank trusts none.
[ew, ~, trusted] = bank(tau);
ew = ew(trusted);
if isempty(ew), a = -1;  z = NaN;  return; end
[a, i] = max(real(ew));  z = ew(i);
end
% --8<-- [end:abscissa]
