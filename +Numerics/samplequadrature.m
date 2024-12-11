function [Ql,Qr,Qlr] = samplequadrature(T,L,R,z)
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
[l1,ell] = size(L);
[l2,r] = size(R);
assert(all([l1,l2]==[n,n]));
% assert(ell <= n && r <= n);
% END SANITY CHECKS

% BEGIN NUMERICS
Ql = zeros(ell,n,N);
Qr = zeros(n,r,N);
Qlr = zeros(ell,r,N);
tic
f(1:N) = parallel.FevalFuture;
for i=1:N
    f(i) = parfeval(@sample,1,T(z(i)),L,R);
end
function updateWaitbar(~)
    waitbar(mean({f.State} == "finished"),h)
end
h = waitbar(0, 'Sampling Quadrature Data...', 'CreateCancelBtn', ...
                   @(src, event) setappdata(gcbf(), 'Cancelled', true));
setappdata(h, 'Cancelled', false);
afterEach(f,@(~)updateWaitbar(),0);
% this loop is very slow for large N since fetchNext is slow and its in
% serial. I should make another futures array 
for i=1:N
    if getappdata(h, 'Cancelled')
        cancel(f); delete(h);
        error("Canceled Quadrature Sampling...");
    end
    [idx,s] = fetchNext(f);
    Ql(:,:,idx) = s.Ql;
    Qr(:,:,idx) = s.Qr;
    Qlr(:,:,idx) = s.Qlr;
end
delete(h);
% END NUMERICS
end

function s = sample(Tz,L,R)
    Ql = L' / Tz;
    Qr = Tz \ R;
    Qlr = L' * Qr;
    s.Ql = Ql;
    s.Qr = Qr;
    s.Qlr = Qlr;
end

