function [Ql,Qr,Qlr] = samplequadrature(T,L,R,z,show_progress,smode)
arguments
    T 
    L 
    R 
    z 
    show_progress = false
    smode = []
end
% INPUTS
%   T -- function handle from C -> nXn matrices, meromorphic on domain D
%   L -- left nXell probing/sketching matrix
%   R -- right nXr probing/sketching matrix
%   z -- points on the boundary of D (coming from some quadrature rule)
% OUTPUTS
%   Ql -- vector of one-sided samples L*T^{-1} at z_k in z
%   Qr -- vector of one-sided samples T^{-1}R at z_k in z
%   Qlr -- vector of two-sided samples L*T^{-1}R at z_k in z
% BEGIN

% BEGIN SANITY CHECKS
% check that T yields square matrices
orig_state = warning;
warning('off','all');
[n1,n2] = size(T(0));
warning(orig_state);

assert(n1==n2);
n = n1;

% number of quadrature nodes
N = length(z);

% verify that L and R are compatible with T
% further, the outer dimensions should be <= n!
[l1,~] = size(L);
[l2,~] = size(R);
assert(all([l1,l2]==[n,n]));
% assert(ell <= n && r <= n);
% END SANITY CHECKS

if smode == "direct"
    sample_function = sample_T;
else
    sample_function = sample_Ti;
end

% BEGIN NUMERICS
f(1:N) = parallel.FevalFuture;
% start function evaluations

if show_progress
    h = waitbar(0, 'Sampling Quadrature Data...', 'CreateCancelBtn', ...
                       @(src, event) setappdata(gcbf(), 'Cancelled', true));
    setappdata(h, 'Cancelled', false);
end
% don't see a way to delay execution of futures... >:(
for i=1:N
    f(i) = parfeval(backgroundPool,@sample_Ti,1,T(z(i)),L,R);
end
if show_progress
    while mean({f.State} == "finished") < 1
        if getappdata(h, 'Cancelled')
            cancel(f); delete(h);
            error("Canceled Quadrature Sampling...");
        end
        waitbar(mean({f.State} == "finished"),h);
    end
    delete(h);
end
s = fetchOutputs(f); Ql = cat(3,s.Ql); Qr = cat(3,s.Qr); Qlr = cat(3,s.Qlr);
% END NUMERICS
end

function s = sample_Ti(Tz,L,R)
    Ql = L' / Tz;
    Qr = Tz \ R;
    Qlr = L' * Qr;
    s.Ql = Ql;
    s.Qr = Qr;
    s.Qlr = Qlr;
end

function s = sample_T(Tz,L,R)
    Ql = L' / Tz;
    Qr = Tz \ R;
    Qlr = L' * Qr;
    s.Ql = Ql;
    s.Qr = Qr;
    s.Qlr = Qlr;
end