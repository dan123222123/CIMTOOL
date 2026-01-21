% setup
% I reckon these test problems can be defined in their own files that can
% be imported here (and elsewhere?!?) when desired!

import Visual.*;
n = 6; m = n; p = n; ewref = -1:-1:-n;
A = diag(ewref); B = randn(n,m); C = randn(p,n);
H = @(z) C*((z*eye(size(A)) - A) \ B);
rtf = OperatorData(H); rtf.refew = ewref;
rtf.sample_mode = Numerics.SampleMode.Direct;
%
contour = Contour.Ellipse(-(n+1)/2,((n+1)/2),0.5,8);
CIMStruct = CIM(rtf,contour);
CIMStruct.RealizationData.RealizationSize.m = length(ewref);
c = CIMTOOL(CIMStruct);

tol = sqrt(eps);

% might be a cleaner way to do this with a function-based unit test script,
% but this works in a pinch...

%% non-sketched Hankel -- TODO
assert(true)

%% sketched Hankel -- No blocked
CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
assert(ngmd < tol,fprintf("Normed Greedy Matching Distance: %e vs TOL: %e\n",ngmd,tol));

%% sketched Hankel -- 3x3 Moments, 2x2 Blocked Hankel
CIMStruct.SampleData.ell = 3; CIMStruct.SampleData.r = 3;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),2,2);
CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
assert(ngmd < tol,fprintf("Normed Greedy Matching Distance: %e vs TOL: %e\n",ngmd,tol));

%% sketched Hankel -- 2x2 Moments, 3x3 Blocked Hankel
CIMStruct.SampleData.ell = 2; CIMStruct.SampleData.r = 2;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),3,3);
CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
assert(ngmd < tol,fprintf("Normed Greedy Matching Distance: %e vs TOL: %e\n",ngmd,tol));

%% sketched Hankel -- 1x1 Moments, 6x6 Blocked Hankel
CIMStruct.SampleData.ell = 1; CIMStruct.SampleData.r = 1;
CIMStruct.RealizationData.RealizationSize = Numerics.RealizationSize(length(ewref),6,6);
CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
assert(~(ngmd < sqrt(tol)),fprintf("#Quad: %d -- Normed Greedy Matching Distance: %e vs TOL: %e\n",contour.N,ngmd,sqrt(tol)));
%
contour.N = 128; CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
assert(ngmd < sqrt(tol),fprintf("#Quad: %d -- Normed Greedy Matching Distance: %e vs TOL: %e\n",contour.N,ngmd,sqrt(tol)));

% %% SPLoewner -- No blocked
% CIMStruct.setComputationalMode(Numerics.ComputationalMode.SPLoewner)
% CIMStruct.compute(); ngmd = CIMStruct.greedyMatchingDistance();
% assert(ngmd < tol,fprintf("Normed Greedy Matching Distance: %e vs TOL: %e\n",ngmd,tol));