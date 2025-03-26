%% roots of T
T = @(s) tan(s) - s;

tol = 10^-6; Ni = 5000; x = linspace(0,30,Ni); ew = zeros(size(x));
for i = 1:length(x)
    ew(i) = fzero(T,x(i));
end
ew = ew(ew > tol); ew = ew(ew < 30); ew = ew(abs(T(ew)) < tol); ew = uniquetol(ew,sqrt(tol));
%% roots of T and singularities of tan(z)
figure; hold on;
h1 = scatter(ew,0,'b',"DisplayName","Roots of $T$");
Tcz = (pi/2)*2*(1:9 + 1);
h2 = scatter(Tcz,0,'r',"DisplayName","Zeros of $\cos{(z)}$");
h3 = fplot(T,"DisplayName","$T$"); 
hold off; legend([h1(1),h2(1),h3(1)],"Interpreter","latex","Location","northoutside","Orientation","horizontal");
xlim([0,35]); ylim([-1,1]);
%% first 5 mode shapes of underlying wave equation
figure; hold on; xlim([-1,1]); ylim([-1,1]);
for i=1:5
    fplot(@(x) sin(ew(i)*x),"DisplayName",sprintf("$\\lambda_%d$",i));
end
legend("Interpreter","latex","Location","northoutside","Orientation","horizontal");
%%
nlevp = Numerics.NLEVPData(T);
contour = Numerics.Contour.Ellipse(ew(2),4,1);
CIM = Numerics.CIM(nlevp,contour);
CIM.SampleData.show_progress = false;
CIM.SampleData.NLEVP.refew = ew;
c = CIMTOOL(CIM);
%%
CIM.RealizationData.m = 3; CIM.RealizationData.K = 10; CIM.compute();
%%
for i = 4:32
    CIM.SampleData.Contour.N = i; CIM.compute();
    drawnow; pause(0.1);
end