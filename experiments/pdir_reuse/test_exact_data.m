%% construct system of interest
n = 10; K = 22;
A = randn(n);
[C,A,B] = eig(A);
H = @(z) (C*inv(z*eye(n) - A))*B';
T = @(z) z*eye(n) - A;
N = 128; contour = Contour.Circle(0,10,N);
[theta,sigma] = Numerics.interlevedshifts(contour.z,K);
L = Numerics.SampleData.sampleMatrix(n,K);
R = Numerics.SampleData.sampleMatrix(n,K);
%% exact MPLoewner realization using the exact transfer function
ell = 2; r = ell;
Lt = L(:,1:ell); Rt = R(:,1:r);
[Lbe,Lse,Be,Ce] = Numerics.build_exact_MPLoewner_data(H,theta,sigma,Lt,Rt);
Lbswe = svd(Lbe); Lsswe = svd(Lse);
[Xe,Sigmae,Ye] = svd(Lbe,"matrix");
Xe=Xe(:,1:n); Sigmae=Sigmae(1:n,1:n); Ye=Ye(:,1:n);
[Lambdae,Ve] = Numerics.realize(Xe,Sigmae,Ye,Lse,Ce);
%% Make Axes
f1 = figure(1);
clf(f1);
ax1 = axes(f1,DataAspectRatioMode="manual");
title(ax1,"Complex Plane")

f2 = figure(2);
clf(f2);
ax2 = axes(f2,'yscale','log');
cla(ax2);
title(ax2,"Db/Ds Singular Values")
legend(ax2);
semilogy(ax2,1:length(Lbswe),Lbswe,'DisplayName','refLbsw','Marker',"o")
%semilogy(ax2,1:length(Lsswe),Lsswe,'DisplayName','refLssw')

f3 = figure(3);
clf(f3);
ax3 = axes(f3,'yscale','log');
cla(ax3);
title(ax3,"2-norm Eigenvalue Matching Distance")
xlabel(ax3,"N")
merral = animatedline(ax3);

f4 = figure(4);
clf(f4);
ax4 = axes(f4,'yscale','log');
cla(ax4);
title(ax4,"best relative rank drop ratio")
xlabel(ax4,"N")
rrd = animatedline(ax4);

f5 = figure(5);
clf(f5);
ax5 = axes(f5);
cla(ax5);
title(ax5,"best guess of m (based on relative rank drop ratio)")
xlabel(ax5,"N")
bgm = animatedline(ax5,"Marker","o");
%%
evp = Numerics.NLEVPData(T);
c = Numerics.CIM(evp,contour,ax1,ax2);
c.RealizationData.ComputationalMode = Numerics.ComputationalMode.MPLoewner;
c.RealizationData.InterpolationData = Numerics.InterpolationData(theta,sigma);
c.SampleData.Contour.plot_quadrature = true;
c.SampleData.L = Lt;
c.SampleData.R = Rt;
c.RealizationData.K = K;
ylim(ax5,[0,c.RealizationData.K])
c.RealizationData.m = n;
%c.auto = true;
c.SampleData.NLEVP.refew = diag(A);
c.RealizationData.ShiftScale = 1.1;
c.compute();
%%
clearpoints(merral);

plength=0.1; y = 10:1:150; steps = length(y);
for i=1:length(y)
    title(ax1,sprintf("N = %d",y(i)));
    c.SampleData.Contour.N = y(i);
    if mod(y(i),2*c.RealizationData.K)==0
        xline(ax3,y(i),"Color","r");
        xline(ax4,y(i),"Color","r");
    end
    try
        c.compute();
    catch E
        warning("issue at N = %d",y(i));
        rethrow(E);
    end
    pause(plength);
    crefew = c.SampleData.NLEVP.refew;
    cew = c.ResultData.ew;
    merr = maxeigmderror(crefew,cew);
    addpoints(merral,y(i),merr);
    chsv = c.ResultData.Dbsw;
    [m,d] = findrankdrop(chsv);
    addpoints(rrd,y(i),d);
    addpoints(bgm,y(i),m);
    drawnow limitrate
end

%%
% for j = 1:n
%     Lt = L(:,1:j); Rt = R(:,1:j);
%     c.SampleData.L = Lt;
%     c.SampleData.R = Rt;
%     Col = ColOrd(j,:);
%     merral = [];
%     rrd = [];
%     bgm = [];
%     Nsteps = 10:1:100; steps = length(Nsteps);
%     intN = [10,40,70,150];
%     for i=1:length(Nsteps)
%         title(ax1,sprintf("N = %d",Nsteps(i)));
%         c.SampleData.Contour.N = Nsteps(i);
%         if any(Nsteps(i) == intN(:))
%             saveas(f2,sprintf("%s_m%d_pdir%d_DbDssw_N%d.png",prob,c.RealizationData.m,j,Nsteps(i)));
%         end
%         try
%             c.compute();
%         catch E
%             warning("issue at N = %d",Nsteps(i));
%             rethrow(E);
%         end
%         if any(Nsteps(i) == intN(:))
%             saveas(f2,sprintf("%s_m%d_pdir%d_DbDssw_N%d.png",prob,c.RealizationData.m,j,Nsteps(i)));
%         end
%         crefew = c.SampleData.NLEVP.refew;
%         cew = c.ResultData.ew;
%         merral(i) = maxeigmderror(crefew,cew);
%         chsv = c.ResultData.Dbsw;
%         [m,d] = findrankdrop(chsv);
%         rrd(i) = d;
%         bgm(i) = m;
%     end
%     l = sprintf("$\\ell'=r'=%d$",j);
%     plot(ax3,Nsteps,mresal,'DisplayName',l,'Color',Col);
%     plot(ax4,Nsteps,rrd,'DisplayName',l,'Color',Col);
%     plot(ax5,Nsteps,bgm,'DisplayName',l,'Color',Col);
% end
% axis(ax1,"equal");
% saveas(f1,sprintf("%s_m%d_cplane.png",prob,c.RealizationData.m))
% saveas(f3,sprintf("%s_m%d_rre.png",prob,c.RealizationData.m))
% saveas(f4,sprintf("%s_m%d_rrd.png",prob,c.RealizationData.m))
% saveas(f5,sprintf("%s_m%d_bgm.png",prob,c.RealizationData.m))