function tsplot(S,T,Pref,sigma)

% USAGE: tsplot(S,T,Pref,sigma)

% Samar Khatiwala (spk@ldeo.columbia.edu)

% grid points for contouring
sg=linspace(S(1),S(2),30);
tg=linspace(T(1),T(2),30);
[SG,TG]=meshgrid(sg,tg);
TG=flipud(TG);

PDEN=sw_pden(SG,TG,0*TG,Pref)-1000;
figure
[c,h]=contour(SG,TG,PDEN,sigma,'-k');
clabel(c,h,'manual','FontSize',12)




