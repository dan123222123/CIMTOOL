%% Three-bus system with delayed PSS: Milano et al. (2020), Example 11.1
%
%     E x'(t) = A0 x(t) + A1 x(t - tau),    E = I (23 states)
%
% States 1-19 follow Appendix B (state 2 = omega_r1, state 16 = v_a1).
% States 20-23 are the PSS wash-out and three lag states of eqs. (1.144)-(1.145).
% A1 is printed in Table 11.1, Kw = 10.9.

% --8<-- [start:setup]
As_base_3bus;   % 19x19 state matrix of Appendix B, without the PSS

Kw = 10.9; Tw = 14; Tz = 0.5056; Tp = 0.1007; gAVR = 40/0.055;
r = Tz/Tp;

% PSS from omega_r1(t - tau) to v_s: x' = Ap x + Bp u, v_s = Cp x + Dp u
Ap = zeros(4); Bp = zeros(4,1);
Ap(1,1) = -1/Tw; Bp(1) = Kw/Tw;
Cp = [-1 0 0 0]; Dp = Kw;
for k = 2:4
    Ap(k,:) = Cp/Tp; Ap(k,k) = Ap(k,k) - 1/Tp; Bp(k) = Dp/Tp;
    Cp = r*Cp; Cp(k) = Cp(k) + (1 - r); Dp = r*Dp;
end

% v_s enters the AVR of machine 1; the delayed omega_r1 enters the PSS
n = 23; iw = 2; iva = 16; ip = 20:23;
E  = eye(n);
A0 = blkdiag(As, Ap); A0(iva,ip) = gAVR*Cp;
A1 = zeros(n); A1(ip,iw) = Bp; A1(iva,iw) = gAVR*Dp;
T  = @(s,tau) s*E - A0 - A1*exp(-s*tau);
% --8<-- [end:setup]
