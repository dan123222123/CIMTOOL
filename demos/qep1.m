% From Tisseur&Meerbergen 2001, section 3.6

M = [1 0 0;0 1 0;0 0 0];
C = [-2 0 1;0 0 0;0 0 0];
K = [1 0 0;0 -1 0;0 0 1];
T = @(z) z.^2*M + z.*C + K;

nlevp = Numerics.NLEVPData(T);
contour = Numerics.Contour.Circle(0.8i,10);
CIM = Numerics.CIM(nlevp,contour);

CIM.SampleData.NLEVP.refew = [-1;1;1;1;Inf;Inf];

c = CIMTOOL(CIM);