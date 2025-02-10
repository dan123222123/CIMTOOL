%% construct fn in tf and pole-residue form
n = 2; m = 2; p = 2;
ewref = -1:-1:-n; A = diag(ewref);
% B = randn(n,m); C = randn(p,n);
B = eye(n,m); C = eye(p,n);
H = @(z) C*((z*eye(n) - A) \ B); G = @(z) ihml(z,n,ewref,B,C);
s = tf('s'); bode(H(s),G(s));
Th = @(z) inv(H(z)); Tg = @(z) inv(G(z)); %try with exact Loewner
%% setup CIMTOOL
nlevp = Numerics.NLEVPData(Th);
contour = Numerics.Contour.Ellipse(-2,0.8,0.5);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
c = CIMTOOL(CIM);
CIM.SampleData.NLEVP.refew = ewref;
%% check initial bode
CIM.SampleData.Contour.alpha = 0.5; nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
CIM.SampleData.Contour.N = 32; CIM.RealizationData.m = nec; CIM.RealizationData.K = 2;
CIM.compute();

CC = CIM.ResultData.C; BB = CIM.ResultData.B;
LLs = CIM.ResultData.Ds; LLb = CIM.ResultData.Db;
Hr = @(z) CC*((LLs - z*LLb) \ BB);
% Hr = @(z) real(CC)*((real(LLs) - z*real(LLb)) \ real(BB));
% Gr = @(z) ihml(z,nec,ewref,B,C);

clf; bode(H(s),Hr(s))
%% moving bode modal truncation, fixed N
x = linspace(0.8,2.5,100);

for i=1:length(x)
    CIM.SampleData.Contour.alpha = x(i);
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec;
    try
        CIM.compute();
    catch
        warning("failed at alpha=%d",x(i))
    end
    %
    CC = CIM.ResultData.C; BB = CIM.ResultData.B;
    LLs = CIM.ResultData.Ds; LLb = CIM.ResultData.Db;
    % Hr = @(z) CC*((z*LLb - LLs) \ BB);
    Hr = @(z) real(CC)*((real(LLs) - z*real(LLb)) \ real(BB));
    % Gr = @(z) ihml(z,nec,ewref,B,C);
    %
    clf; bode(H(s),Hr(s))
    drawnow;
end
%%
for N=4:256
    CIM.SampleData.Contour.N = N;
    nec = length(ewref(CIM.SampleData.Contour.inside(ewref)));
    CIM.RealizationData.m = nec; CIM.compute();
    %
    CC = CIM.ResultData.C; BB = CIM.ResultData.B;
    LLs = CIM.ResultData.Ds; LLb = CIM.ResultData.Db;
    Hr = @(z) CC*((z*LLb - LLs) \ BB); Gr = @(z) ihml(z,nec,ewref,B,C);
    %
    clf;
    % subplot(1,2,1); bode(H(s),Hr(s));
    % subplot(1,2,2); bode(G(s),Gr(s));
    bode(Hr(s),Gr(s))
    drawnow;
end